# takeoff n1.py
import re
import sys
from pathlib import Path
import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import extract_notes, assign_by_x, run_extraction, run_main

SUBCHAPTER = "Takeoff %N1"
CHAPTER    = "PI"
KEY_N1     = "Takeoff %N1"
KEY_BLEED  = "%N1 Adjustments for Engine Bleeds"


def extract_n1_table(lines, start_idx):
    based_on = ""
    for i in range(start_idx, min(start_idx + 4, len(lines))):
        if lines[i].strip().startswith('Based on'):
            based_on = lines[i].strip()
            break

    alt_idx = None
    for i in range(start_idx, min(start_idx + 6, len(lines))):
        line  = lines[i].strip()
        parts = line.split()
        if parts and re.match(r'^-?\d+', parts[0]) and len(parts) >= 5:
            if parts[0] in ('-2000', '-2') or len(parts) > 8:
                alt_idx = i
                break
    if alt_idx is None:
        return None, len(lines), based_on

    altitudes  = lines[alt_idx].strip().split()
    data_start = alt_idx + 1

    while data_start < len(lines):
        parts = lines[data_start].strip().split()
        if parts and re.match(r'^-?\d+$', parts[0]):
            break
        data_start += 1

    header = ['OAT (C)'] + ['ALT / ' + a for a in altitudes]
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
        oat    = parts[0]
        values = parts[1:]
        while len(values) < n_cols:
            values.append('')
        rows.append([oat] + values[:n_cols])

    return (rows if len(rows) > 1 else None), data_end_idx, based_on


def extract_bleed_table(lines, start_idx, words=None):
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

    col_xs = None
    conf_y = None
    if words:
        for w in words:
            if w['text'] == 'CONFIGURATION':
                conf_y = w['top']
                break
        if conf_y:
            skip = {'BLEED', 'CONFIGURATION', 'AIRPORT', 'PRESSURE',
                    'ALTITUDE', '(1000', 'FT)', '(FT)'}
            conf_words = sorted(
                [w for w in words if abs(w['top'] - conf_y) < 3
                 and w['text'] not in skip],
                key=lambda w: w['x0']
            )
            col_xs = [w['x0'] for w in conf_words]

    for i, line in enumerate(lines[alt_idx + 1:], start=alt_idx + 1):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts:
            continue

        if parts[0] in ('PACKS', 'ENGINE', 'WING'):
            if len(parts) > 1 and parts[1] in ('OFF', 'ANTI-ICE', 'AND'):
                config     = parts[0] + ' ' + parts[1]
                raw_values = parts[2:]
            else:
                config     = parts[0]
                raw_values = parts[1:]

            values = []
            for v in raw_values:
                sub = re.findall(r'-?\d+\.?\d*', v)
                values.extend(sub)

            if len(values) == n_cols:
                rows.append([config] + values)
            elif words and col_xs and conf_y:
                first_word = config.split()[0]
                line_y = None
                for w in words:
                    if w['text'] == first_word and w['top'] > conf_y:
                        line_y = w['top']
                        break
                if line_y:
                    skip_config = set(config.split())
                    row_words = sorted(
                        [w for w in words
                         if abs(w['top'] - line_y) < 3
                         and w['text'] not in skip_config],
                        key=lambda w: w['x0']
                    )
                    positioned = assign_by_x(col_xs, row_words, n_cols)
                    rows.append([config] + positioned)
                else:
                    while len(values) < n_cols:
                        values.append('')
                    rows.append([config] + values[:n_cols])
            else:
                while len(values) < n_cols:
                    values.append('')
                rows.append([config] + values[:n_cols])
        else:
            data_end_idx = i
            break

    return (rows if len(rows) > 1 else None), data_end_idx


def extract_all(pdf_path, page_num, page_end=None):
    with pdfplumber.open(pdf_path) as pdf:
        page  = pdf.pages[page_num]
        text  = page.extract_text()
        words = page.extract_words()
    lines = text.splitlines()

    results  = {}
    success  = True

    n1_start = None
    for i, line in enumerate(lines):
        if 'OAT' in line and 'PRESSURE ALTITUDE' in line:
            n1_start = i
            break
        if re.match(r'^-?\d+\s+-?\d+', line.strip()):
            n1_start = i
            break
    if n1_start is None:
        return None

    data, data_end, based_on = extract_n1_table(lines, n1_start)
    if data:
        notes = extract_notes(lines, data_end)
        if based_on:
            notes = [based_on] + notes
        results[KEY_N1]            = data
        results[KEY_N1 + '_notes'] = notes
    else:
        success = False

    for i, line in enumerate(lines):
        if 'Adjustment' in line and 'Bleed' in line.title():
            bleed_data, bleed_end = extract_bleed_table(lines, i + 1, words)
            if bleed_data:
                bleed_notes = extract_notes(lines, bleed_end)
                results[KEY_BLEED]            = bleed_data
                results[KEY_BLEED + '_notes'] = bleed_notes
            else:
                success = False
            break

    return results if success else None


def run(fcom_dir, pi_dir, subchapters):
    run_extraction(fcom_dir, pi_dir, subchapters, SUBCHAPTER, extract_all)


if __name__ == "__main__":
    run_main(run)
