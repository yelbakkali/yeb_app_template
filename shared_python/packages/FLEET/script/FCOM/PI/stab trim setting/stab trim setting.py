"""
stab trim setting.py
Extraction des tableaux du sous-chapitre Stab Trim Setting.
Gere a la fois "Stab Trim Setting" (NG) et "Stabilizer Trim Setting" (MAX).

Emplacement : PI/stab trim setting/stab trim setting.py

Peut etre lance seul :
  python3 "stab trim setting.py"

Dependances : pip install pdfplumber
"""

import re
import sys
from pathlib import Path

import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import safe_name, load_toc, find_subchapters, extract_notes
from fcom_utils import load_fcom_data, save_fcom_data, set_data, export_subchapter_html

SUBCHAPTER = "Stab Trim Setting"
CHAPTER    = "PI"

KEY_FLAPS_1_5    = "Flaps 1 and 5"
KEY_FLAPS_10_25  = "Flaps 10, 15 and 25"


def parse_stab_tokens(parts):
    result = []
    i = 0
    while i < len(parts):
        token = parts[i]
        if i + 1 < len(parts) and '/' in parts[i + 1]:
            result.append(token + ' ' + parts[i + 1])
            i += 2
        else:
            result.append(token)
            i += 1
    return result


def extract_flaps_table(lines, start_idx):
    cg_values  = None
    data_start = None

    for i in range(start_idx, min(start_idx + 8, len(lines))):
        line  = lines[i].strip()
        parts = line.split()
        if not parts:
            continue

        if parts[0] == '(1000' and len(parts) > 2:
            cg_values  = parts[2:]
            data_start = i + 1
            break

        if line == '(1000 KG)' and i + 1 < len(lines):
            next_parts = lines[i + 1].strip().split()
            if next_parts and re.match(r'^\d+$', next_parts[0]) and not any('/' in p for p in next_parts):
                cg_values  = next_parts
                data_start = i + 2
                break

    if cg_values is None or data_start is None:
        return None, [], len(lines)

    header = ['WEIGHT (1000 KG)'] + ['CG / ' + c for c in cg_values]
    n_cols = len(cg_values)
    rows   = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[data_start:], start=data_start):
        line = lines[i].strip() if i < len(lines) else ''
        if not line:
            continue
        parts = line.split()
        if not parts or not re.match(r'^\d{2,3}$', parts[0]):
            data_end_idx = i
            break
        weight = parts[0]
        tokens = parse_stab_tokens(parts[1:])
        while len(tokens) < n_cols:
            tokens.append('')
        rows.append([weight] + tokens[:n_cols])

    notes = extract_notes(lines, data_end_idx)
    return rows, notes, data_end_idx


def extract_stab_trim(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    results = {}
    for i, line in enumerate(lines):
        line_s = line.strip()
        if 'Flaps 1' in line_s and '5' in line_s and '10' not in line_s:
            data, notes, _ = extract_flaps_table(lines, i + 1)
            if data:
                results[KEY_FLAPS_1_5]              = data
                results[KEY_FLAPS_1_5 + '_notes']   = notes
        elif 'Flaps 10' in line_s:
            data, notes, _ = extract_flaps_table(lines, i + 1)
            if data:
                results[KEY_FLAPS_10_25]             = data
                results[KEY_FLAPS_10_25 + '_notes']  = notes

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

        tables = extract_stab_trim(pdf_path, page)
        if tables:
            for key, data in tables.items():
                set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                         key, section_title, data)
                if not key.endswith('_notes'):
                    n_notes = len(tables.get(key + '_notes', []))
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
