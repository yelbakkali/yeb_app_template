# flap maneuver speeds.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER = "Flap Maneuver Speeds"
CHAPTER    = "PI"
KEY_FLAP   = "Flap Maneuver Speeds"


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

    header       = ['FLAP POSITION', 'MANEUVER SPEED']
    rows         = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[header_idx + 1:], start=header_idx + 1):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts:
            continue
        if parts[0] == 'UP' or re.match(r'^\d+$', parts[0]):
            rows.append([parts[0], ' '.join(parts[1:])])
        else:
            data_end_idx = i
            break

    notes = extract_notes(lines, data_end_idx)
    return (rows if len(rows) > 1 else None), notes


def extract_all(pdf_path, page_num, page_end=None):
    data, notes = extract_flap_maneuver(pdf_path, page_num)
    if not data:
        return None
    return {
        KEY_FLAP:            data,
        KEY_FLAP + '_notes': notes,
    }


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
