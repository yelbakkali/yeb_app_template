# slippery runway takeoff.py
import re
import sys
from pathlib import Path
from collections import defaultdict
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, assign_by_x, run_extraction, run_main

SUBCHAPTER = "Slippery Runway Takeoff"
CHAPTER    = "PI"


def table_keys(reverse):
    prefix = "Maximum Reverse Thrust" if reverse == "max" else "No Reverse Thrust"
    return {
        "weight": prefix + " - Weight Adjustment",
        "v1mcg":  prefix + " - V1(MCG) Limit Weight",
        "v1adj":  prefix + " - V1 Adjustment (KIAS)",
    }


def extract_contamination_table(page, lines, start_idx, index_col):
    words = page.extract_words()

    cat_idx = None
    for i in range(start_idx, min(start_idx + 8, len(lines))):
        line = lines[i]
        if ('mm' in line.lower() and 'INCHES' in line) or \
           ('GOOD' in line and 'MEDIUM' in line) or \
           ('GOOD' in line and 'POOR' in line):
            cat_idx = i
            break
    if cat_idx is None:
        return None, []

    if 'mm' in lines[cat_idx].lower():
        categories = re.findall(r'\d+\s*mm', lines[cat_idx])
    else:
        categories = re.findall(r'GOOD|MEDIUM|POOR', lines[cat_idx])
    if not categories:
        return None, []

    alt_idx = None
    for i in range(cat_idx, min(cat_idx + 4, len(lines))):
        if 'S.L.' in lines[i] and '5000' in lines[i]:
            alt_idx = i
            break
    if alt_idx is None:
        return None, []

    all_parts = lines[alt_idx].strip().split()
    all_alts  = [p for p in all_parts if p == 'S.L.' or re.match(r'^\d+$', p)]
    n_alts    = len(all_alts) // len(categories)
    altitudes = all_alts[:n_alts]

    alt_y = None
    for w in words:
        if w['text'] == 'S.L.' and alt_y is None:
            y_words = [ww['text'] for ww in words if abs(ww['top'] - w['top']) < 3]
            if '5000' in y_words:
                alt_y = w['top']
                break
    if alt_y is None:
        return None, []

    alt_words_sorted = sorted(
        [w for w in words if abs(w['top'] - alt_y) < 3 and
         (w['text'] == 'S.L.' or re.match(r'^\d+$', w['text']))],
        key=lambda w: w['x0']
    )
    col_xs = [w['x0'] for w in alt_words_sorted]

    end_y = None
    for w in words:
        if w['text'] == '1.' and w['top'] > alt_y:
            end_y = w['top']
            break

    lines_by_y = defaultdict(list)
    for w in words:
        if w['top'] > alt_y and (end_y is None or w['top'] < end_y):
            lines_by_y[round(w['top'], 1)].append(w)

    header = [index_col]
    for cat in categories:
        for alt in altitudes:
            header.append(cat + ' / ' + alt)

    n_cols       = len(categories) * n_alts
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
        rest      = parts[1:]

        if len(rest) == n_cols:
            rows.append([index_val] + rest)
        else:
            row_words = None
            for y, ws in lines_by_y.items():
                ws_sorted = sorted(ws, key=lambda w: w['x0'])
                if ws_sorted[0]['text'] == index_val:
                    row_words = ws_sorted[1:]
                    break
            if row_words and col_xs:
                positioned = assign_by_x(col_xs, row_words, n_cols)
                rows.append([index_val] + positioned)
            else:
                while len(rest) < n_cols:
                    rest.append('')
                rows.append([index_val] + rest[:n_cols])

    notes = extract_notes(lines, data_end_idx)
    return (rows if len(rows) > 1 else None), notes


def extract_slippery_page(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        page = pdf.pages[page_num]
        text = page.extract_text()
    lines = text.splitlines()

    results = {}

    reverse = "max"
    for line in lines[:10]:
        if 'No Reverse' in line:
            reverse = "no"
            break

    keys = table_keys(reverse)

    with pdfplumber.open(pdf_path) as pdf:
        page = pdf.pages[page_num]

        for i, line in enumerate(lines):
            if 'Weight Adjust' in line or ('Table 1' in line and 'Weight' in line):
                data, notes = extract_contamination_table(page, lines, i + 1, 'WEIGHT (1000 KG)')
                if data:
                    results[keys["weight"]]            = data
                    results[keys["weight"] + '_notes'] = notes
                break

        for i, line in enumerate(lines):
            if 'V1(MCG) Limit Weight' in line or ('Table 2' in line and 'V1' in line):
                data, notes = extract_contamination_table(page, lines, i + 1, 'FIELD LENGTH (M)')
                if data:
                    results[keys["v1mcg"]]            = data
                    results[keys["v1mcg"] + '_notes'] = notes
                break

        for i, line in enumerate(lines):
            if ('Table 3' in line and 'V1' in line) or 'V1 Adjustment (KIAS)' in line:
                data, notes = extract_contamination_table(page, lines, i + 1, 'WEIGHT (1000 KG)')
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
        if 'Slippery' not in text:
            break
        page_data = extract_slippery_page(pdf_path, p)
        results.update(page_data)

    return results if results else None


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
