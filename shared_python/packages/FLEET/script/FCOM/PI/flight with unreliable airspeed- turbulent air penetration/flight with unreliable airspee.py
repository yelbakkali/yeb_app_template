# flight with unreliable airspeed.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER = "Flight With Unreliable Airspeed/ Turbulent Air Penetration"
CHAPTER    = "PI"
KEY_CLIMB  = "Climb (280/.76)"
KEY_CRUISE = "Cruise (.76/280)"


def extract_unreliable_table(lines, start_idx, end_keyword):
    weight_idx = None
    weights    = None
    for i in range(start_idx, min(start_idx + 6, len(lines))):
        line = lines[i].strip()
        if 'ALTITUDE' in line and re.search(r'\d{2}', line):
            parts = line.split()
            w = [p for p in parts if re.match(r'^\d{2,3}$', p)]
            if w:
                weight_idx = i
                weights    = w
                break

    if weight_idx is None or weights is None:
        return None, len(lines)

    header       = ['PRESSURE ALTITUDE (FT)', 'PARAMETER'] + ['WEIGHT ' + w for w in weights]
    n_cols       = len(weights)
    rows         = [header]
    data_end_idx = len(lines)
    current_alt  = None

    i = weight_idx + 1
    while i < len(lines):
        line  = lines[i].strip()
        parts = line.split()

        if not parts:
            i += 1
            continue

        if parts[0] in (end_keyword, 'Boeing', 'Copyright') or \
           (end_keyword and line.startswith(end_keyword)):
            data_end_idx = i
            break

        # Ligne SEA LEVEL
        if parts[0] == 'SEA':
            current_alt = 'SEA LEVEL'
            rest = parts[1:]
            param_parts = []
            val_parts   = []
            for p in rest:
                if re.match(r'^-?\d+\.?\d*$', p):
                    val_parts.append(p)
                else:
                    if not val_parts:
                        param_parts.append(p)
            param = ' '.join(param_parts)
            while len(val_parts) < n_cols:
                val_parts.append('')
            rows.append([current_alt, param] + val_parts[:n_cols])
            i += 1
            continue

        # Ligne d'altitude : entier 5 chiffres
        if re.match(r'^\d{5}$', parts[0]):
            current_alt = parts[0]
            i += 1
            continue

        # Ligne de parametre : PITCH ATT, V/S, %N1
        if parts[0] in ('PITCH', 'V/S', '%N1'):
            param_parts = []
            val_parts   = []
            for p in parts:
                if re.match(r'^-?\d+\.?\d*$', p):
                    val_parts.append(p)
                else:
                    if not val_parts:
                        param_parts.append(p)
            param = ' '.join(param_parts)
            while len(val_parts) < n_cols:
                val_parts.append('')
            rows.append([current_alt or '', param] + val_parts[:n_cols])
            i += 1
            continue

        i += 1

    return (rows if len(rows) > 1 else None), data_end_idx


def extract_all(pdf_path, page_num, page_end=None):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    results = {}
    success = True

    for i, line in enumerate(lines):
        if 'CLIMB' in line and '280' in line:
            data, end = extract_unreliable_table(lines, i + 1, 'CRUISE')
            if data:
                notes = extract_notes(lines, end)
                results[KEY_CLIMB]            = data
                results[KEY_CLIMB + '_notes'] = notes
            else:
                success = False
            break

    for i, line in enumerate(lines):
        if 'CRUISE' in line and '280' in line:
            data, end = extract_unreliable_table(lines, i + 1, 'Boeing')
            if data:
                notes = extract_notes(lines, end)
                results[KEY_CRUISE]            = data
                results[KEY_CRUISE + '_notes'] = notes
            else:
                success = False
            break

    return results if success else None


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
