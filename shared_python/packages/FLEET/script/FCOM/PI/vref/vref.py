# vref.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER = "VREF"
CHAPTER    = "PI"
KEY_VREF   = "VREF"


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

    n_cols       = len(flaps_values)
    rows         = [header]
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


def extract_all(pdf_path, page_num, page_end=None):
    data, notes = extract_vref(pdf_path, page_num)
    if not data:
        return None
    return {
        KEY_VREF:            data,
        KEY_VREF + '_notes': notes,
    }


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
