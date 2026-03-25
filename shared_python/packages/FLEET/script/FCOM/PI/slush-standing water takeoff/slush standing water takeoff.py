# slush standing water takeoff.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER = "Slush/Standing Water Takeoff"
CHAPTER    = "PI"


def table_keys(reverse):
    prefix = "Maximum Reverse Thrust" if reverse == "max" else "No Reverse Thrust"
    return {
        "weight": prefix + " - Weight Adjustment",
        "v1mcg":  prefix + " - V1(MCG) Limit Weight",
        "v1adj":  prefix + " - V1 Adjustment (KIAS)",
    }


def extract_contamination_table(lines, start_idx, index_col):
    depth_idx = None
    for i in range(start_idx, min(start_idx + 8, len(lines))):
        if 'mm' in lines[i].lower() and 'INCHES' in lines[i]:
            depth_idx = i
            break
    if depth_idx is None:
        return None, []

    depths = re.findall(r'\d+\s*mm', lines[depth_idx])

    alt_idx = None
    for i in range(depth_idx, min(depth_idx + 4, len(lines))):
        if 'S.L.' in lines[i] and '5000' in lines[i]:
            alt_idx = i
            break
    if alt_idx is None:
        return None, []

    all_parts = lines[alt_idx].strip().split()
    all_alts  = [p for p in all_parts if p == 'S.L.' or re.match(r'^\d+$', p)]
    n_alts    = len(all_alts) // len(depths)
    altitudes = all_alts[:n_alts]

    header = [index_col]
    for depth in depths:
        for alt in altitudes:
            header.append(depth + ' / ' + alt)

    n_cols       = len(depths) * n_alts
    rows         = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[alt_idx + 1:], start=alt_idx + 1):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts or not re.match(r'^\d+', parts[0]) or parts[0].endswith('.'):
            data_end_idx = i
            break
        index_val = parts[0]
        values    = parts[1:]
        while len(values) < n_cols:
            values.append('')
        rows.append([index_val] + values[:n_cols])

    notes = extract_notes(lines, data_end_idx)
    return (rows if len(rows) > 1 else None), notes


def extract_slush_page(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    results = {}

    reverse = "max"
    for line in lines[:10]:
        if 'No Reverse' in line:
            reverse = "no"
            break

    keys = table_keys(reverse)

    for i, line in enumerate(lines):
        if 'Weight Adjust' in line or ('Table 1' in line and 'Weight' in line):
            data, notes = extract_contamination_table(lines, i + 1, 'WEIGHT (1000 KG)')
            if data:
                results[keys["weight"]]            = data
                results[keys["weight"] + '_notes'] = notes
            break

    for i, line in enumerate(lines):
        if 'V1(MCG) Limit Weight' in line or ('Table 2' in line and 'V1' in line):
            data, notes = extract_contamination_table(lines, i + 1, 'FIELD LENGTH (M)')
            if data:
                results[keys["v1mcg"]]            = data
                results[keys["v1mcg"] + '_notes'] = notes
            break

    for i, line in enumerate(lines):
        if ('Table 3' in line and 'V1' in line) or 'V1 Adjustment (KIAS)' in line:
            data, notes = extract_contamination_table(lines, i + 1, 'WEIGHT (1000 KG)')
            if data:
                results[keys["v1adj"]]            = data
                results[keys["v1adj"] + '_notes'] = notes
            break

    return results


def extract_all(pdf_path, page_num, page_end=None):
    results = {}
    with pdfplumber.open(pdf_path) as pdf:
        total = len(pdf.pages)

    end = min(page_end if page_end else page_num + 4, total)

    for p in range(page_num, end):
        with pdfplumber.open(pdf_path) as pdf:
            text = pdf.pages[p].extract_text() or ""
        if 'Slush' not in text and 'Standing Water' not in text:
            break
        page_data = extract_slush_page(pdf_path, p)
        results.update(page_data)

    return results if results else None


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
