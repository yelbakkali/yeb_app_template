"""
flap maneuver speeds.py
Extraction du tableau Flap Maneuver Speeds.

Emplacement : PI/flap maneuver speeds/flap maneuver speeds.py

Peut etre lance seul :
  python3 "flap maneuver speeds.py"

Dependances : pip install pdfplumber
"""

import re
import sys
from pathlib import Path

import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import safe_name, load_toc, find_subchapters, extract_notes
from fcom_utils import load_fcom_data, save_fcom_data, set_data, export_subchapter_html

SUBCHAPTER = "Flap Maneuver Speeds"
CHAPTER    = "PI"

KEY_FLAP = "Flap Maneuver Speeds"


def extract_flap_maneuver(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    header_idx = None
    for i, line in enumerate(lines):
        if 'FLAP POSITION' in line and 'MANEUVER SPEED' in line:
            header_idx = i
            break
    if header_idx is None:
        return None, []

    header = ['FLAP POSITION', 'MANEUVER SPEED']
    rows   = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[header_idx + 1:], start=header_idx + 1):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts:
            continue
        if parts[0] == 'UP' or re.match(r'^\d+$', parts[0]):
            flap  = parts[0]
            speed = ' '.join(parts[1:])
            rows.append([flap, speed])
        else:
            data_end_idx = i
            break

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

        data, notes = extract_flap_maneuver(pdf_path, page)
        if data:
            set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                     KEY_FLAP, section_title, data)
            set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                     KEY_FLAP + '_notes', section_title, notes)
            print("    " + KEY_FLAP + "  (" + str(len(data) - 1) + " lignes)" +
                  ("  [" + str(len(notes)) + " notes]" if notes else ""))
        else:
            print("    " + KEY_FLAP + "  ECHEC")
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
