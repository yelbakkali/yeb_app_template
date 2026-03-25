# stab trim setting.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER      = "Stab Trim Setting"
CHAPTER         = "PI"
KEY_FLAPS_1_5   = "Flaps 1 and 5"
KEY_FLAPS_10_25 = "Flaps 10, 15 and 25"


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


def extract_all(pdf_path, page_num, page_end=None):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    results = {}
    success = True

    for i, line in enumerate(lines):
        line_s = line.strip()
        if 'Flaps 1' in line_s and '5' in line_s and '10' not in line_s:
            data, notes, _ = extract_flaps_table(lines, i + 1)
            if data:
                results[KEY_FLAPS_1_5]            = data
                results[KEY_FLAPS_1_5 + '_notes'] = notes
            else:
                success = False
        elif 'Flaps 10' in line_s:
            data, notes, _ = extract_flaps_table(lines, i + 1)
            if data:
                results[KEY_FLAPS_10_25]            = data
                results[KEY_FLAPS_10_25 + '_notes'] = notes
            else:
                success = False

    return results if success and results else None


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
