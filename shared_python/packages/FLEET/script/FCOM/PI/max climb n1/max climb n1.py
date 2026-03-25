# max climb n1.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, run_extraction, run_main

SUBCHAPTER = "Max Climb %N1"
CHAPTER    = "PI"
KEY_N1     = "Max Climb %N1"
KEY_BLEED  = "%N1 Adjustments for Engine Bleeds"


def extract_climb_n1_table(lines, start_idx):
    based_on = ""
    for i in range(start_idx, min(start_idx + 4, len(lines))):
        if lines[i].strip().startswith('Based on'):
            based_on = lines[i].strip()
            break

    alt_idx   = None
    altitudes = None
    for i in range(start_idx, min(start_idx + 10, len(lines))):
        line  = lines[i].strip()
        clean = re.sub(r'^(TAT\s*\(.*?\)|TAT)\s+', '', line)
        parts = clean.split()
        if not parts:
            continue
        if re.match(r'^\d+$', parts[0]) and len(parts) >= 5:
            if not re.match(r'^\d+\.\d+', parts[1] if len(parts) > 1 else ''):
                alt_idx   = i
                altitudes = parts
                break

    if alt_idx is None or altitudes is None:
        return None, len(lines), based_on

    speeds     = None
    data_start = alt_idx + 1
    for i in range(alt_idx + 1, min(alt_idx + 4, len(lines))):
        line  = lines[i].strip()
        parts = line.split()
        if parts and (re.match(r'^\d+$', parts[0]) or re.match(r'^0\.\d+$', parts[0])):
            speeds     = parts
            data_start = i + 1
            break
        elif parts and re.match(r'^\(', parts[0]):
            continue
        else:
            data_start = i
            break

    while data_start < len(lines):
        parts = lines[data_start].strip().split()
        if parts and re.match(r'^-?\d+$', parts[0]):
            break
        data_start += 1

    header = ['TAT (C)']
    for j, alt in enumerate(altitudes):
        spd = speeds[j] if speeds and j < len(speeds) else ''
        header.append('ALT ' + alt + ' / ' + spd if spd else 'ALT / ' + alt)

    n_cols       = len(altitudes)
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
        tat    = parts[0]
        values = parts[1:]
        while len(values) < n_cols:
            values.append('')
        rows.append([tat] + values[:n_cols])

    return (rows if len(rows) > 1 else None), data_end_idx, based_on


def extract_climb_bleed_table(lines, start_idx):
    alt_idx   = None
    altitudes = None
    for i in range(start_idx, min(start_idx + 5, len(lines))):
        line = lines[i].strip()
        if 'CONFIGURATION' in line:
            clean = line.replace('CONFIGURATION', '').split()
            if clean and re.match(r'^\d+$', clean[0]):
                alt_idx   = i
                altitudes = clean
                break
        clean = re.sub(r'^(BLEED\s+)?(CONFIGURATION\s+)?', '', line)
        parts = clean.split()
        if parts and re.match(r'^\d+$', parts[0]) and len(parts) >= 3:
            alt_idx   = i
            altitudes = parts
            break

    if alt_idx is None or altitudes is None:
        return None, len(lines)

    header = ['BLEED CONFIG'] + ['ALT / ' + a for a in altitudes]
    n_cols       = len(altitudes)
    rows         = [header]
    data_end_idx = len(lines)

    i = alt_idx + 1
    while i < len(lines):
        line  = lines[i].strip()
        parts = line.split()

        if not parts or parts[0] in ('Boeing', 'Copyright', '*Dual', '*Wing'):
            data_end_idx = i
            break

        if parts[0] in ('ENGINE', 'PACKS', 'WING'):
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
                   next_parts[0] not in ('Boeing', 'Copyright'):
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

    for i, line in enumerate(lines):
        if 'Max Climb' in line or 'Climb %N1' in line:
            data, end, based_on = extract_climb_n1_table(lines, i + 1)
            if data:
                notes = extract_notes(lines, end)
                if based_on:
                    notes = [based_on] + notes
                results[KEY_N1]            = data
                results[KEY_N1 + '_notes'] = notes
            else:
                success = False
            break

    for i, line in enumerate(lines):
        if 'Adjustment' in line and 'Bleed' in line.title():
            data, end = extract_climb_bleed_table(lines, i + 1)
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
