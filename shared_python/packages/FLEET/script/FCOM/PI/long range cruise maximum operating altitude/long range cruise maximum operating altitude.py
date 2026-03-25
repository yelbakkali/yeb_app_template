# long range cruise maximum operating altitude.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER = "Long Range Cruise Maximum Operating Altitude"
CHAPTER    = "PI"
KEY_TABLE  = "Long Range Cruise Maximum Operating Altitude"


def extract_isa_tables(lines):
    results = {}
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        m = re.match(r'^(ISA\s*[+-]\s*\d+[^,]*)', line)
        if m:
            isa_label = m.group(1).strip()
            header_idx = None
            for j in range(i + 1, min(i + 4, len(lines))):
                if '(1000 KG)' in lines[j]:
                    header_idx = j
                    break
            if header_idx is None:
                i += 1
                continue

            col_line = lines[header_idx].strip()
            parts    = col_line.split()
            buffet_cols = [p for p in parts if re.match(r'^\d+\.\d+$', p)]

            header = ['WEIGHT (1000 KG)', 'OPTIMUM ALT (FT)', 'TAT (C)'] + \
                     ['BUFFET ' + c for c in buffet_cols]
            n_cols = len(buffet_cols)
            rows   = [header]

            data_end_idx = len(lines)
            for j in range(header_idx + 1, len(lines)):
                l = lines[j].strip()
                if not l:
                    continue
                p = l.split()
                if not p or not re.match(r'^\d{2,3}$', p[0]):
                    data_end_idx = j
                    break
                if len(p) >= 3 + n_cols:
                    weight  = p[0]
                    opt_alt = p[1]
                    tat     = p[2]
                    vals    = [v.replace('*', '') for v in p[3:3 + n_cols]]
                    rows.append([weight, opt_alt, tat] + vals)

            key = KEY_TABLE + ' - ' + isa_label
            results[key] = (rows, data_end_idx)
            i = data_end_idx
        else:
            i += 1

    return results


def extract_max_easa_table(lines):
    header_idx = None
    for i, line in enumerate(lines):
        if '(1000 KG)' in line and 'ALT' in line:
            header_idx = i
            break
    if header_idx is None:
        return {}

    # Reconstruire header depuis plusieurs lignes
    all_parts = []
    for j in range(header_idx, min(header_idx + 4, len(lines))):
        all_parts.extend(lines[j].strip().split())

    isa_cols = []
    k = 0
    while k < len(all_parts):
        if all_parts[k] == 'ISA' and k + 2 < len(all_parts):
            sign  = all_parts[k + 1]
            deg   = all_parts[k + 2]
            isa_cols.append('ISA ' + sign + ' ' + deg)
            k += 3
        else:
            k += 1

    if not isa_cols:
        return {}

    header = ['WEIGHT (1000 KG)', 'OPTIMUM ALT (FT)',
              'MAX CRUISE THRUST BUFFET LIMIT (FT)'] + isa_cols
    n_isa  = len(isa_cols)
    rows   = [header]

    data_start = header_idx + 1
    while data_start < len(lines):
        p = lines[data_start].strip().split()
        if p and re.match(r'^\d{2,3}$', p[0]):
            break
        data_start += 1

    data_end_idx = len(lines)
    for i, line in enumerate(lines[data_start:], start=data_start):
        line = line.strip()
        if not line:
            continue
        p = line.split()
        if not p or not re.match(r'^\d{2,3}$', p[0]):
            data_end_idx = i
            break
        if len(p) >= 3 + n_isa:
            rows.append([p[0], p[1], p[2]] + p[3:3 + n_isa])

    return {KEY_TABLE: (rows, data_end_idx)} if len(rows) > 1 else {}


def extract_all(pdf_path, page_num, page_end=None):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    # Detecter le type de page
    has_isa_buffet = any('ISA' in l and '1.20' in l for l in lines)
    has_max_easa   = any('BUFFET' in l and 'MAX CRUISE' in l for l in lines) and not has_isa_buffet

    if has_isa_buffet:
        tables = extract_isa_tables(lines)
    elif has_max_easa:
        tables = extract_max_easa_table(lines)
    else:
        return None

    if not tables:
        return None

    results = {}
    for key, (data, data_end) in tables.items():
        notes = extract_notes(lines, data_end)
        results[key]            = data
        results[key + '_notes'] = notes

    return results if results else None


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
