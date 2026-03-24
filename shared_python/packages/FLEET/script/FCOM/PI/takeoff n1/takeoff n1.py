"""
takeoff n1.py
Extraction des tableaux du sous-chapitre Takeoff %N1.

Emplacement : PI/takeoff n1/takeoff n1.py

Peut etre lance seul :
  python3 "takeoff n1.py"

Dependances : pip install pdfplumber
"""

import re
import sys
from pathlib import Path

import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import safe_name, load_toc, find_subchapters, extract_notes, assign_by_x
from fcom_utils import load_fcom_data, save_fcom_data, set_data, export_subchapter_html

SUBCHAPTER = "Takeoff %N1"
CHAPTER    = "PI"

KEY_N1    = "Takeoff %N1"
KEY_BLEED = "%N1 Adjustments for Engine Bleeds"


def extract_n1_table(lines, start_idx):
    based_on = ""
    for i in range(start_idx, min(start_idx + 4, len(lines))):
        if lines[i].strip().startswith('Based on'):
            based_on = lines[i].strip()
            break

    alt_idx = None
    for i in range(start_idx, min(start_idx + 6, len(lines))):
        line  = lines[i].strip()
        parts = line.split()
        if parts and re.match(r'^-?\d+', parts[0]) and len(parts) >= 5:
            if parts[0] in ('-2000', '-2') or len(parts) > 8:
                alt_idx = i
                break
    if alt_idx is None:
        return None, len(lines), based_on

    altitudes  = lines[alt_idx].strip().split()
    data_start = alt_idx + 1

    while data_start < len(lines):
        parts = lines[data_start].strip().split()
        if parts and re.match(r'^-?\d+$', parts[0]):
            break
        data_start += 1

    header = ['OAT (C)'] + ['ALT / ' + a for a in altitudes]
    n_cols = len(altitudes)
    rows   = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[data_start:], start=data_start):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts or not re.match(r'^-?\d+$', parts[0]):
            data_end_idx = i
            break
        oat    = parts[0]
        values = parts[1:]
        while len(values) < n_cols:
            values.append('')
        rows.append([oat] + values[:n_cols])

    return (rows if len(rows) > 1 else None), data_end_idx, based_on


def extract_bleed_table(lines, start_idx, words=None):
    alt_idx = None
    for i in range(start_idx, min(start_idx + 5, len(lines))):
        if 'CONFIGURATION' in lines[i]:
            alt_idx = i
            break
    if alt_idx is None:
        return None, len(lines)

    parts     = lines[alt_idx].strip().split()
    conf_idx  = parts.index('CONFIGURATION') if 'CONFIGURATION' in parts else 0
    altitudes = parts[conf_idx + 1:]

    header = ['BLEED CONFIG'] + ['ALT / ' + a for a in altitudes]
    n_cols = len(altitudes)
    rows   = [header]
    data_end_idx = len(lines)

    col_xs = None
    conf_y = None
    if words:
        for w in words:
            if w['text'] == 'CONFIGURATION':
                conf_y = w['top']
                break
        if conf_y:
            skip = {'BLEED', 'CONFIGURATION', 'AIRPORT', 'PRESSURE',
                    'ALTITUDE', '(1000', 'FT)', '(FT)'}
            conf_words = sorted(
                [w for w in words if abs(w['top'] - conf_y) < 3
                 and w['text'] not in skip],
                key=lambda w: w['x0']
            )
            col_xs = [w['x0'] for w in conf_words]

    for i, line in enumerate(lines[alt_idx + 1:], start=alt_idx + 1):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts:
            continue

        if parts[0] in ('PACKS', 'ENGINE', 'WING'):
            if len(parts) > 1 and parts[1] in ('OFF', 'ANTI-ICE', 'AND'):
                config     = parts[0] + ' ' + parts[1]
                raw_values = parts[2:]
            else:
                config     = parts[0]
                raw_values = parts[1:]

            values = []
            for v in raw_values:
                sub = re.findall(r'-?\d+\.?\d*', v)
                values.extend(sub)

            if len(values) == n_cols:
                rows.append([config] + values)
            elif words and col_xs and conf_y:
                first_word = config.split()[0]
                line_y = None
                for w in words:
                    if w['text'] == first_word and w['top'] > conf_y:
                        line_y = w['top']
                        break
                if line_y:
                    skip_config = set(config.split())
                    row_words = sorted(
                        [w for w in words
                         if abs(w['top'] - line_y) < 3
                         and w['text'] not in skip_config],
                        key=lambda w: w['x0']
                    )
                    positioned = assign_by_x(col_xs, row_words, n_cols)
                    rows.append([config] + positioned)
                else:
                    while len(values) < n_cols:
                        values.append('')
                    rows.append([config] + values[:n_cols])
            else:
                while len(values) < n_cols:
                    values.append('')
                rows.append([config] + values[:n_cols])
        else:
            data_end_idx = i
            break

    return (rows if len(rows) > 1 else None), data_end_idx


def extract_takeoff_n1(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        page  = pdf.pages[page_num]
        text  = page.extract_text()
        words = page.extract_words()
    lines = text.splitlines()

    results = {}

    n1_start = None
    for i, line in enumerate(lines):
        if 'OAT' in line and 'PRESSURE ALTITUDE' in line:
            n1_start = i
            break
        if re.match(r'^-?\d+\s+-?\d+', line.strip()):
            n1_start = i
            break
    if n1_start is None:
        return None

    data, data_end, based_on = extract_n1_table(lines, n1_start)
    if data:
        notes = extract_notes(lines, data_end)
        if based_on:
            notes = [based_on] + notes
        results[KEY_N1]              = data
        results[KEY_N1 + '_notes']   = notes

    for i, line in enumerate(lines):
        if 'Adjustment' in line and 'Bleed' in line.title():
            bleed_data, bleed_end = extract_bleed_table(lines, i + 1, words)
            if bleed_data:
                bleed_notes = extract_notes(lines, bleed_end)
                results[KEY_BLEED]             = bleed_data
                results[KEY_BLEED + '_notes']  = bleed_notes
            break

    return results if results else None


def run(fcom_dir, pi_dir, subchapters):
    fcom_dir = Path(fcom_dir)
    pi_dir   = Path(pi_dir)

    entries = subchapters.get(SUBCHAPTER, [])
    if not entries:
        print("Sous-chapitre non trouve : " + SUBCHAPTER)
        return

    fcom_data = load_fcom_data(fcom_dir)

    if CHAPTER in fcom_data:
        if safe_name(SUBCHAPTER) in fcom_data[CHAPTER]:
            del fcom_data[CHAPTER][safe_name(SUBCHAPTER)]

    print("Extraction : " + SUBCHAPTER)
    success = True

    for entry in entries:
        pdf_path      = fcom_dir / (entry["fcom"] + ".pdf")
        section_title = entry["section_title"]
        page          = entry["page"]

        if not pdf_path.exists():
            print("  PDF introuvable : " + str(pdf_path))
            success = False
            continue

        print("  " + safe_name(section_title) + "  (p." + str(page) + ")")

        tables = extract_takeoff_n1(pdf_path, page)
        if tables:
            for key, data in tables.items():
                set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                         key, section_title, data)
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
        html_name = "verify_" + safe_name(SUBCHAPTER).replace(' ', '_') + ".html"
        html_path = pi_dir / safe_name(SUBCHAPTER) / html_name
        export_subchapter_html(fcom_data, CHAPTER, safe_name(SUBCHAPTER), html_path)
    else:
        print("  Extractions incompletes — fcom_data.json non modifie")


if __name__ == "__main__":
    script_dir = Path(__file__).parent
    fcom_dir   = script_dir.parent.parent
    pi_dir     = script_dir.parent

    toc_data    = load_toc(fcom_dir)
    subchapters = find_subchapters(toc_data, pi_dir)
    run(fcom_dir, pi_dir, subchapters)
