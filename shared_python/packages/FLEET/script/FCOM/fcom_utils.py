"""
fcom_utils.py
Fonctions utilitaires partagees par tous les scripts d'extraction FCOM.

Emplacement : meme dossier que extract_fcom.py et main.py
"""

import csv
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))
from patterns import NOTES_STOP_PATTERNS

FCOM_DATA_FILE    = "fcom_data.json"
CHAPTERS_MAP_FILE = "pi_chapters_map.json"


# -- Noms de dossiers --

def safe_name(text):
    text = text.lower().strip()
    text = text.replace('/', '-').replace('\\', '-')
    text = re.sub(r'[\\/*?:"<>|%]', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text[:100]


# -- CSV --

def write_csv(data, path):
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    with open(path, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.writer(f)
        for row in data:
            writer.writerow([c if c is not None else '' for c in row])


# -- TOC --

def load_toc(fcom_dir):
    toc_path = Path(fcom_dir) / "toc.json"
    if not toc_path.exists():
        raise FileNotFoundError("toc.json introuvable : " + str(toc_path))
    with open(toc_path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_chapters_map(pi_dir):
    path = Path(pi_dir) / CHAPTERS_MAP_FILE
    if not path.exists():
        return {"subchapters": {}, "aliases": {}}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def find_subchapters(toc_data, pi_dir=None):
    IGNORE = ["derate", "22k", "24k", "to1", "to2"]

    aliases = {}
    if pi_dir:
        chapters_map = load_chapters_map(pi_dir)
        aliases = {k.lower(): v for k, v in chapters_map.get("aliases", {}).items()}

    subchapters = {}
    key_map = {}

    for fcom_name, tree in toc_data.items():
        for node in tree:
            if node["title"] != "Performance Inflight":
                continue
            sections = [s for s in node["children"] if s["title"].startswith("Section ")]
            for sec in sections:
                section_title = sec["title"][len("Section "):].strip()
                for chap in sec["children"]:
                    if chap["title"] in ("Pkg Model Identification", "Text"):
                        continue
                    pi_chapter = chap["title"]
                    subs = chap["children"]
                    for i, sub in enumerate(subs):
                        name = sub["title"].strip()
                        if any(p in name.lower() for p in IGNORE):
                            continue
                        page     = sub["page"]
                        page_end = subs[i + 1]["page"] if i + 1 < len(subs) else None

                        canonical = aliases.get(name.lower(), None)
                        if canonical:
                            folder = safe_name(canonical)
                            if folder not in key_map:
                                key_map[folder] = canonical
                        else:
                            folder = safe_name(name)
                            if folder not in key_map:
                                key_map[folder] = name
                            canonical = key_map[folder]

                        subchapters.setdefault(canonical, []).append({
                            "fcom":          fcom_name,
                            "section_title": section_title,
                            "pi_chapter":    pi_chapter,
                            "page":          page,
                            "page_end":      page_end,
                        })

    return subchapters


# -- fcom_data.json --

def load_fcom_data(fcom_dir):
    path = Path(fcom_dir) / FCOM_DATA_FILE
    if not path.exists():
        return {}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_fcom_data(data, fcom_dir):
    path = Path(fcom_dir) / FCOM_DATA_FILE
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def get_data(fcom_data, chapter, subchapter, table, section=None):
    try:
        node = fcom_data[chapter][subchapter][table]
        if section is None:
            return node
        return node.get(section)
    except KeyError:
        return None


def set_data(fcom_data, chapter, subchapter, table, section, values):
    fcom_data.setdefault(chapter, {})
    fcom_data[chapter].setdefault(subchapter, {})
    fcom_data[chapter][subchapter].setdefault(table, {})
    fcom_data[chapter][subchapter][table][section] = values


# -- assign_by_x --

def assign_by_x(col_xs, words_in_row, n_total):
    result = [''] * n_total
    for w in words_in_row:
        closest = min(range(len(col_xs)), key=lambda i: abs(col_xs[i] - w['x0']))
        result[closest] = w['text']
    return result


# -- Notes --

def extract_notes(lines, data_end_idx):
    notes   = []
    current = None

    for line in lines[data_end_idx:]:
        line = line.strip()
        if not line:
            continue
        if any(re.match(p, line) for p in NOTES_STOP_PATTERNS):
            break
        if re.match(r'^\d+\.', line):
            if current:
                notes.append(current)
            current = line
        elif line.startswith('*'):
            if current:
                notes.append(current)
            current = line
        elif re.match(r'^[A-Z][a-zA-Z0-9\s\(\)\.%/\-]+\.$', line) and len(line) < 80:
            if current:
                notes.append(current)
            current = line
        elif current:
            current += ' ' + line
        elif notes:
            break

    if current:
        notes.append(current)

    return notes


# -- run_extraction generique --

def run_extraction(fcom_dir, pi_dir, subchapters, subchapter, extract_fn, chapter="PI"):
    fcom_dir = Path(fcom_dir)
    pi_dir   = Path(pi_dir)

    entries = subchapters.get(subchapter, [])
    if not entries:
        print("Sous-chapitre non trouve : " + subchapter)
        return False

    fcom_data = load_fcom_data(fcom_dir)

    sub_key = safe_name(subchapter)
    if chapter in fcom_data and sub_key in fcom_data[chapter]:
        del fcom_data[chapter][sub_key]

    print("Extraction : " + subchapter)
    success = True

    for entry in entries:
        pdf_path      = fcom_dir / (entry["fcom"] + ".pdf")
        section_title = entry["section_title"]
        page          = entry["page"]
        page_end      = entry.get("page_end")

        if not pdf_path.exists():
            print("  PDF introuvable : " + str(pdf_path))
            success = False
            continue

        print("  " + safe_name(section_title) + "  (p." + str(page) + ")")

        tables = extract_fn(pdf_path, page, page_end)
        if tables:
            for key, data in tables.items():
                set_data(fcom_data, chapter, sub_key, key, section_title, data)
                if not key.endswith('_notes'):
                    n_notes = len(tables.get(key + '_notes', []))
                    if isinstance(data, list):
                        print("    " + key + "  (" + str(len(data) - 1) + " lignes)" +
                              ("  [" + str(n_notes) + " notes]" if n_notes else ""))
        else:
            print("    ECHEC")
            success = False

    if success:
        save_fcom_data(fcom_data, fcom_dir)
        print("  fcom_data.json mis a jour")
        html_name = "verify_" + sub_key.replace(' ', '_') + ".html"
        html_path = pi_dir / sub_key / html_name
        export_subchapter_html(fcom_data, chapter, sub_key, html_path)
    else:
        print("  Extractions incompletes -- fcom_data.json non modifie")

    return success


# -- run_main generique --

def run_main(run_fn):
    script_dir  = Path(run_fn.__code__.co_filename).parent
    fcom_dir    = script_dir.parent.parent
    pi_dir      = script_dir.parent
    toc_data    = load_toc(fcom_dir)
    subchapters = find_subchapters(toc_data, pi_dir)
    run_fn(fcom_dir, pi_dir, subchapters)


# -- Rendu HTML interne --

def _render_section_data(lines, data):
    if not data:
        lines.append('<p class="empty">Aucune donnee</p>')
        return

    if isinstance(data, list) and len(data) > 0 and isinstance(data[0], list):
        lines.append('<table>')
        for i, row in enumerate(data):
            if i == 0:
                cells = ''.join('<th>' + str(c) + '</th>' for c in row)
                lines.append('<tr>' + cells + '</tr>')
            else:
                cells = ''
                for c in row:
                    if str(c) == '':
                        cells += '<td class="empty">-</td>'
                    else:
                        cells += '<td>' + str(c) + '</td>'
                lines.append('<tr>' + cells + '</tr>')
        lines.append('</table>')

    elif isinstance(data, list) and len(data) > 0 and isinstance(data[0], str):
        lines.append('<ul class="notes">')
        for note in data:
            lines.append('<li>' + note + '</li>')
        lines.append('</ul>')

    else:
        lines.append('<p class="empty">Aucune donnee</p>')


def _html_styles():
    return [
        'body { font-family: Arial, sans-serif; font-size: 12px; margin: 0; padding: 10px; background: #f5f5f5; }',
        'h1 { font-size: 15px; color: #333; border-bottom: 2px solid #0066cc; padding-bottom: 6px; }',
        'h2 { font-size: 13px; color: #0066cc; margin-top: 20px; margin-bottom: 4px; }',
        'h3 { font-size: 11px; color: #666; margin-top: 12px; margin-bottom: 4px; font-style: italic; }',
        'h4 { font-size: 11px; color: #666; margin-top: 12px; margin-bottom: 4px; font-style: italic; }',
        'h5 { font-size: 11px; color: #888; margin-top: 8px; margin-bottom: 4px; }',
        '.chapter { background: #fff; border: 1px solid #ddd; border-radius: 6px; padding: 12px; margin-bottom: 20px; }',
        '.section { background: #f9f9f9; border-left: 3px solid #0066cc; padding: 8px 12px; margin: 8px 0; }',
        'table { border-collapse: collapse; margin: 6px 0 12px 0; font-size: 11px; white-space: nowrap; }',
        'th { background: #0066cc; color: #fff; padding: 4px 8px; text-align: center; border: 1px solid #005bb5; }',
        'td { padding: 3px 7px; border: 1px solid #ccc; text-align: center; }',
        'tr:nth-child(even) td { background: #eef4ff; }',
        'tr:hover td { background: #d0e8ff; }',
        '.empty { color: #bbb; }',
        '.nav { position: sticky; top: 0; background: #0066cc; padding: 6px 10px; margin: -10px -10px 12px -10px; }',
        '.nav a { color: #fff; text-decoration: none; margin-right: 12px; font-size: 12px; font-weight: bold; }',
        '.nav a:hover { text-decoration: underline; }',
        '.notes { margin: 6px 0 6px 16px; padding: 0; }',
        '.notes li { font-size: 11px; color: #445; margin-bottom: 3px; line-height: 1.4; }',
    ]


# -- Export HTML sous-chapitre --

def export_subchapter_html(fcom_data, chapter, subchapter, output_path):
    try:
        tables = fcom_data[chapter][subchapter]
    except KeyError:
        print("Aucune donnee pour : " + chapter + " / " + subchapter)
        return

    lines = []
    lines.append('<!DOCTYPE html>')
    lines.append('<html lang="fr">')
    lines.append('<head>')
    lines.append('<meta charset="UTF-8">')
    lines.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
    lines.append('<title>Verify - ' + subchapter + '</title>')
    lines.append('<style>')
    lines.extend(_html_styles())
    lines.append('</style>')
    lines.append('</head>')
    lines.append('<body>')

    nav = '<div class="nav"><a href="#">' + subchapter + '</a>'
    for table_key in tables:
        if not table_key.endswith('_notes'):
            nav += '<a href="#' + safe_name(table_key) + '">' + table_key + '</a>'
    nav += '</div>'
    lines.append(nav)
    lines.append('<h1>' + chapter + ' / ' + subchapter + '</h1>')

    for table_key, sections in tables.items():
        if table_key.endswith('_notes'):
            continue
        lines.append('<h2 id="' + safe_name(table_key) + '">' + table_key + '</h2>')
        for section_title, data in sections.items():
            lines.append('<div class="section">')
            lines.append('<h3>' + section_title + '</h3>')
            _render_section_data(lines, data)

            notes_key = table_key + '_notes'
            if notes_key in tables and section_title in tables[notes_key]:
                notes = tables[notes_key][section_title]
                if notes:
                    _render_section_data(lines, notes)

            lines.append('</div>')

    lines.append('</body>')
    lines.append('</html>')

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print('HTML genere : ' + str(output_path))


# -- Export HTML global --

def export_html(fcom_data, output_path):
    lines = []
    lines.append('<!DOCTYPE html>')
    lines.append('<html lang="fr">')
    lines.append('<head>')
    lines.append('<meta charset="UTF-8">')
    lines.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
    lines.append('<title>FCOM Data - Verification</title>')
    lines.append('<style>')
    lines.extend(_html_styles())
    lines.append('</style>')
    lines.append('</head>')
    lines.append('<body>')

    nav = '<div class="nav"><a href="#">FCOM Data</a>'
    for chapter in fcom_data:
        if chapter not in ('metadata_hash', '_pi_chapters'):
            nav += '<a href="#' + chapter + '">' + chapter + '</a>'
    nav += '</div>'
    lines.append(nav)
    lines.append('<h1>FCOM Data - Verification</h1>')

    for chapter, subchapters in fcom_data.items():
        if chapter in ('metadata_hash', '_pi_chapters'):
            continue
        lines.append('<div class="chapter" id="' + chapter + '">')
        lines.append('<h2>' + chapter + '</h2>')
        for subchapter, tables in subchapters.items():
            lines.append('<h3>' + subchapter + '</h3>')
            for table_key, sections in tables.items():
                if table_key.endswith('_notes'):
                    continue
                lines.append('<h4>' + table_key + '</h4>')
                for section_title, data in sections.items():
                    lines.append('<div class="section">')
                    lines.append('<h5>' + section_title + '</h5>')
                    _render_section_data(lines, data)

                    notes_key = table_key + '_notes'
                    if notes_key in tables and section_title in tables[notes_key]:
                        notes = tables[notes_key][section_title]
                        if notes:
                            _render_section_data(lines, notes)

                    lines.append('</div>')
        lines.append('</div>')

    lines.append('</body>')
    lines.append('</html>')

    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines))

    print('HTML genere : ' + str(output_path))
