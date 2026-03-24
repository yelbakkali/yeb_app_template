"""
slush standing water takeoff.py
Extraction des tableaux du sous-chapitre Slush/Standing Water Takeoff.

Emplacement : PI/slush-standing water takeoff/slush standing water takeoff.py

Peut etre lance seul :
  python3 "slush standing water takeoff.py"

Dependances : pip install pdfplumber
"""

import re
import sys
from pathlib import Path

import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import safe_name, load_toc, find_subchapters, extract_notes
from fcom_utils import load_fcom_data, save_fcom_data, set_data, export_subchapter_html

SUBCHAPTER = "Slush/Standing Water Takeoff"
CHAPTER    = "PI"


def table_keys(reverse):
    """Retourne les cles exactes selon le type de reverse thrust."""
    prefix = "Maximum Reverse Thrust" if reverse == "max" else "No Reverse Thrust"
    return {
        "weight":  prefix + " - Weight Adjustment",
        "v1mcg":   prefix + " - V1(MCG) Limit Weight",
        "v1adj":   prefix + " - V1 Adjustment (KIAS)",
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

    n_cols = len(depths) * n_alts
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
                results[keys["weight"]]              = data
                results[keys["weight"] + '_notes']   = notes
            break

    for i, line in enumerate(lines):
        if 'V1(MCG) Limit Weight' in line or ('Table 2' in line and 'V1' in line):
            data, notes = extract_contamination_table(lines, i + 1, 'FIELD LENGTH (M)')
            if data:
                results[keys["v1mcg"]]             = data
                results[keys["v1mcg"] + '_notes']  = notes
            break

    for i, line in enumerate(lines):
        if ('Table 3' in line and 'V1' in line) or 'V1 Adjustment (KIAS)' in line:
            data, notes = extract_contamination_table(lines, i + 1, 'WEIGHT (1000 KG)')
            if data:
                results[keys["v1adj"]]             = data
                results[keys["v1adj"] + '_notes']  = notes
            break

    return results


def extract_slush(pdf_path, page_num, page_end):
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

        tables = extract_slush(pdf_path, page, page_end)
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
