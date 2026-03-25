# go-arround n1.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER = "Go-around %N1"
CHAPTER    = "PI"
KEY_N1     = "Go-Around %N1"
KEY_BLEED  = "%N1 Adjustments for Engine Bleeds"


def extract_goaround_n1_table(lines, start_idx):
    based_on = ""
    for i in range(start_idx, min(start_idx + 4, len(lines))):
        if lines[i].strip().startswith('Based on'):
            based_on = lines[i].strip()
            break

    alt_idx   = None
    altitudes = None
    for i in range(start_idx, min(start_idx + 10, len(lines))):
        line  = lines[i].strip()
        clean = re.sub(r'^(\(.*?\)\s+)*', '', line)
        clean = re.sub(r'^(TAT|OAT|REPORTED)\s+', '', clean)
        clean = re.sub(r'^[A-Za-z/\s]+\s+', '', clean)
        parts = clean.split()
        if not parts:
            continue
        if re.match(r'^-?\d+$', parts[0]) and len(parts) >= 5:
            if not re.match(r'^\d+\.\d+', parts[1] if len(parts) > 1 else ''):
                alt_idx   = i
                altitudes = parts
                break

    if alt_idx is None or altitudes is None:
        return None, len(lines), based_on

    data_start = alt_idx + 1
    while data_start < len(lines):
        parts = lines[data_start].strip().split()
        if parts and re.match(r'^-?\d+$', parts[0]):
            break
        data_start += 1

    is_max = False
    if data_start < len(lines):
        test_parts = lines[data_start].strip().split()
        if len(test_parts) >= 3 and len(test_parts[-1]) > 8 and '.' in test_parts[-1]:
            is_max = True

    header = ['TAT (C)', 'OAT (C)'] + ['ALT / ' + a for a in altitudes]
    n_alts       = len(altitudes)
    rows         = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[data_start:], start=data_start):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts or not re.match(r'^-?\d+$', parts[0]):
            data_end_idx = i
            break

        if is_max:
            tat    = parts[0]
            oat    = parts[1] if len(parts) > 1 else ''
            blob   = parts[2] if len(parts) > 2 else ''
            values = [blob[j:j+4] for j in range(0, len(blob), 4) if len(blob[j:j+4]) == 4]
            while len(values) < n_alts:
                values.append('')
            rows.append([tat, oat] + values[:n_alts])
        else:
            tat    = parts[0]
            oat    = parts[2] if len(parts) >= 3 else ''
            values = parts[3:] if len(parts) >= 3 else parts[1:]
            while len(values) < n_alts:
                values.append('')
            rows.append([tat, oat] + values[:n_alts])

    return (rows if len(rows) > 1 else None), data_end_idx, based_on


def extract_goaround_bleed_table(lines, start_idx):
    alt_idx = None
    for i in range(start_idx, min(start_idx + 5, len(lines))):
        if 'CONFIGURATION' in lines[i]:
            alt_idx = i
            break
    if alt_idx is None:
        return None, len(lines)

    parts     = lines[alt_idx].strip().split()
    conf_idx  = parts.index('CONFIGURATION') if 'CONFIGURATION' in parts else 0
    altitudes = parts[conf_idx + 1:]

    header = ['BLEED CONFIG'] + ['ALT / ' + a for a in altitudes]
    n_cols       = len(altitudes)
    rows         = [header]
    data_end_idx = len(lines)

    i = alt_idx + 1
    while i < len(lines):
        line  = lines[i].strip()
        parts = line.split()

        if not parts or parts[0] in ('Boeing', 'Copyright', '*Single', '*Dual'):
            data_end_idx = i
            break

        if parts[0] in ('PACKS', 'ENGINE', 'WING', 'A/C'):
            config = parts[0]
            rest   = parts[1:]

            j = 0
            while j < len(rest) and not re.match(r'^-?\d+\.?\d*$', rest[j]):
                config += ' ' + rest[j]
                j += 1
            values = rest[j:]

            if len(values) < n_cols and i + 1 < len(lines):
                next_parts = lines[i + 1].strip().split()
                if next_parts and not re.match(r'^-?\d+\.?\d*$', next_parts[0]) and \
                   next_parts[0] not in ('Boeing', 'Copyright', '*Single', '*Dual'):
                    config += ' ' + next_parts[0]
                    values  = next_parts[1:]
                    i += 1
                elif next_parts and re.match(r'^-?\d+\.?\d*$', next_parts[0]):
                    values = next_parts
                    i += 1

            clean_values = []
            for v in values:
                sub = re.findall(r'-?\d+\.?\d*', v)
                clean_values.extend(sub)

            while len(clean_values) < n_cols:
                clean_values.append('')
            rows.append([config.strip()] + clean_values[:n_cols])

        else:
            data_end_idx = i
            break

        i += 1

    return (rows if len(rows) > 1 else None), data_end_idx


def extract_all(pdf_path, page_num, page_end=None):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    results = {}
    success = True

    n1_start = None
    for i, line in enumerate(lines):
        if ('Go-around' in line or 'Go-Around' in line or
                'around %N1' in line.lower() or
                'ight-Around' in line):
            n1_start = i
            break
    if n1_start is None:
        for i, line in enumerate(lines):
            if line.strip().startswith('Based on'):
                n1_start = max(0, i - 1)
                break

    if n1_start is not None:
        data, end, based_on = extract_goaround_n1_table(lines, n1_start + 1)
        if data:
            notes = extract_notes(lines, end)
            if based_on:
                notes = [based_on] + notes
            results[KEY_N1]            = data
            results[KEY_N1 + '_notes'] = notes
        else:
            success = False

    for i, line in enumerate(lines):
        line_clean = line.replace('forEngine', 'for Engine')
        if 'Adjustment' in line_clean and 'Bleed' in line_clean:
            data, end = extract_goaround_bleed_table(lines, i + 1)
            if data:
                notes = extract_notes(lines, end)
                results[KEY_BLEED]            = data
                results[KEY_BLEED + '_notes'] = notes
            else:
                success = False
            break

    return results if success else None


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
