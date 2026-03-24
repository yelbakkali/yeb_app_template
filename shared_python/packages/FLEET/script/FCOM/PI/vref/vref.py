"""
vref.py
Extraction du tableau VREF.

Emplacement : PI/vref/vref.py

Peut etre lance seul :
  python3 vref.py

Dependances : pip install pdfplumber
"""

import re
import sys
from pathlib import Path

import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import safe_name, load_toc, find_subchapters, extract_notes
from fcom_utils import load_fcom_data, save_fcom_data, set_data, export_subchapter_html

SUBCHAPTER = "VREF"
CHAPTER    = "PI"

KEY_VREF = "VREF"


def extract_vref(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    ref_alt = ""
    for line in lines:
        if 'reference pressure altitude' in line.lower():
            m = re.search(r'(\d+)\s*ft', line, re.IGNORECASE)
            if m:
                ref_alt = m.group(1) + ' ft'
            break

    flaps_idx = None
    for i, line in enumerate(lines):
        parts = line.strip().split()
        if (len(parts) >= 2
                and all(re.match(r'^\d{2}$', p) for p in parts)
                and all(10 <= int(p) <= 50 for p in parts)):
            flaps_idx = i
            break
    if flaps_idx is None:
        return None, []

    flaps_values = lines[flaps_idx].strip().split()
    data_start   = flaps_idx + 1

    while data_start < len(lines):
        first = lines[data_start].strip().split()
        if first and re.match(r'^\d{2,3}$', first[0]):
            break
        data_start += 1

    ref_suffix = ' (' + ref_alt + ')' if ref_alt else ''
    header = ['WEIGHT (1000 KG)']
    for f in flaps_values:
        header.append('FLAPS ' + f + ref_suffix)

    n_cols = len(flaps_values)
    rows   = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[data_start:], start=data_start):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts or not re.match(r'^\d{2,3}$', parts[0]):
            data_end_idx = i
            break
        values = parts[1:]
        while len(values) < n_cols:
            values.append('')
        rows.append([parts[0]] + values[:n_cols])

    notes = extract_notes(lines, data_end_idx)
    return (rows if len(rows) > 1 else None), notes


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

        data, notes = extract_vref(pdf_path, page)
        if data:
            set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                     KEY_VREF, section_title, data)
            set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                     KEY_VREF + '_notes', section_title, notes)
            print("    " + KEY_VREF + "  (" + str(len(data) - 1) + " lignes)" +
                  ("  [" + str(len(notes)) + " notes]" if notes else ""))
        else:
            print("    " + KEY_VREF + "  ECHEC")
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
