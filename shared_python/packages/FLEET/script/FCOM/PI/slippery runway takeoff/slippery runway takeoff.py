"""
slippery runway takeoff.py
Extraction des tableaux du sous-chapitre Slippery Runway Takeoff.

Emplacement : PI/slippery runway takeoff/slippery runway takeoff.py

Peut etre lance seul :
  python3 "slippery runway takeoff.py"

Dependances : pip install pdfplumber
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import safe_name, load_toc, find_subchapters, extract_notes, assign_by_x
from fcom_utils import load_fcom_data, save_fcom_data, set_data, export_subchapter_html

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

    n_cols = len(categories) * n_alts
    rows   = [header]
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
                    results[keys["v1mcg"]]           = data
                    results[keys["v1mcg"] + '_notes'] = notes
                break

        for i, line in enumerate(lines):
            if ('Table 3' in line and 'V1' in line) or 'V1 Adjustment (KIAS)' in line:
                data, notes = extract_contamination_table(page, lines, i + 1, 'WEIGHT (1000 KG)')
                if data:
                    results[keys["v1adj"]]           = data
                    results[keys["v1adj"] + '_notes'] = notes
                break

    return results


def extract_slippery(pdf_path, page_num, page_end):
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
        page_end      = entry.get("page_end")

        if not pdf_path.exists():
            print("  PDF introuvable : " + str(pdf_path))
            success = False
            continue

        print("  " + safe_name(section_title) + "  (p." + str(page) + ")")

        tables = extract_slippery(pdf_path, page, page_end)
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
