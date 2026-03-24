"""
takeoff speeds - wet runway.py
Extraction des 4 tableaux du sous-chapitre Takeoff Speeds - Wet Runway.

Emplacement : PI/takeoff speeds - wet runway/takeoff speeds - wet runway.py

Peut etre lance seul :
  python3 "takeoff speeds - wet runway.py"

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

SUBCHAPTER = "Takeoff Speeds - Wet Runway"
CHAPTER    = "PI"

KEY_V1_VR_V2   = "V1, VR, V2 for Max Takeoff Thrust"
KEY_ADJ        = "V1, VR, V2 Adjustments"
KEY_SLOPE_WIND = "Slope and Wind V1 Adjustments"
KEY_V1MCG      = "V1(MCG)"


def extract_v1_vr_v2(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    header_idx = None
    for i, line in enumerate(lines):
        if 'FLAPS 1' in line and 'FLAPS 5' in line:
            header_idx = i
            break
    if header_idx is None:
        return None, []

    flaps = re.findall(r'FLAPS \d+', lines[header_idx])
    header = ['WEIGHT (1000 KG)']
    for f in flaps:
        header += [f + ' / V1', f + ' / VR', f + ' / V2']

    rows = [header]
    data_started = False
    data_end_idx = len(lines)
    for i, line in enumerate(lines[header_idx + 1:], start=header_idx + 1):
        line = line.strip()
        if not line:
            continue
        if line.startswith('V1') or line.startswith('(1000'):
            continue
        parts = line.split()
        if not parts:
            continue
        if re.match(r'^\d{2,3}$', parts[0]):
            data_started = True
            values = parts[1:]
            while len(values) < 15:
                values.append('')
            rows.append([parts[0]] + values[:15])
        elif data_started:
            data_end_idx = i
            break

    notes = extract_notes(lines, data_end_idx)
    return (rows if len(rows) > 1 else None), notes


def extract_adjustments(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        page  = pdf.pages[page_num]
        text  = page.extract_text()
        words = page.extract_words()

    lines = text.splitlines()

    adj_idx = None
    for i, line in enumerate(lines):
        if 'Adjustment' in line and 'Slope' not in line and 'Wind' not in line:
            adj_idx = i
            break
    if adj_idx is None:
        return None, []

    alt_idx = None
    for i in range(adj_idx, min(adj_idx + 8, len(lines))):
        parts = lines[i].split()
        if '-2' in parts and '0' in parts and '2' in parts:
            alt_idx = i
            break
    if alt_idx is None:
        return None, []

    alt_line_parts = lines[alt_idx].split()
    has_fahrenheit = alt_line_parts[0] in ('C', '°C')

    if has_fahrenheit:
        raw_alts = [p for p in alt_line_parts if p not in ('C', 'F', '°C', '°F')]
    else:
        raw_alts = alt_line_parts

    n           = len(raw_alts) // 3
    altitudes   = raw_alts[:n]
    n_data_cols = 3 * n

    header = ['TEMP (C)']
    for speed in ['V1', 'VR', 'V2']:
        for alt in altitudes:
            header.append(speed + ' / ' + alt)

    first_alt_word = '°C' if has_fahrenheit else '-2'
    alt_y = None
    for w in words:
        if w['text'] == first_alt_word:
            y_words = [ww['text'] for ww in words if abs(ww['top'] - w['top']) < 3]
            if '2' in y_words and '0' in y_words:
                alt_y = w['top']
                break
    if alt_y is None:
        return None, []

    alt_words = sorted([w for w in words if abs(w['top'] - alt_y) < 3],
                       key=lambda w: w['x0'])
    skip   = 2 if has_fahrenheit else 0
    col_xs = [w['x0'] for w in alt_words[skip:]]

    end_y = None
    for w in words:
        if w['text'] == 'Slope':
            end_y = w['top']
            break

    lines_by_y = defaultdict(list)
    for w in words:
        if w['top'] > alt_y and (end_y is None or w['top'] < end_y):
            lines_by_y[round(w['top'], 1)].append(w)

    rows = [header]
    data_end_idx = len(lines)
    for i, line in enumerate(lines[alt_idx + 1:], start=alt_idx + 1):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts or not re.match(r'^-?\d+$', parts[0]):
            data_end_idx = i
            break
        temp_c = parts[0]
        rest   = parts[1:]

        if has_fahrenheit and rest and re.match(r'^-?\d+$', rest[0]):
            rest = rest[1:]

        if len(rest) == n_data_cols:
            rows.append([temp_c] + rest)
        else:
            row_words = None
            for y, ws in lines_by_y.items():
                ws_sorted = sorted(ws, key=lambda w: w['x0'])
                if ws_sorted[0]['text'] == temp_c:
                    row_words = ws_sorted[1:]
                    if has_fahrenheit and row_words and re.match(r'^-?\d+$', row_words[0]['text']):
                        row_words = row_words[1:]
                    break

            if row_words and col_xs:
                positioned = assign_by_x(col_xs, row_words, n_data_cols)
                rows.append([temp_c] + positioned)
            else:
                while len(rest) < n_data_cols:
                    rest.append('')
                rows.append([temp_c] + rest[:n_data_cols])

        if temp_c == '-60':
            data_end_idx = i + 1
            break

    notes = extract_notes(lines, data_end_idx)
    return (rows if len(rows) > 1 else None), notes


def extract_slope_wind(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        text = pdf.pages[page_num].extract_text()
    lines = text.splitlines()

    slope_idx = None
    for i, line in enumerate(lines):
        if 'Slope' in line and 'Wind' in line:
            slope_idx = i
            break
    if slope_idx is None:
        return None, []

    col_idx = None
    for i in range(slope_idx, min(slope_idx + 6, len(lines))):
        if '-2' in lines[i] and '-1' in lines[i] and '-15' in lines[i]:
            col_idx = i
            break
    if col_idx is None:
        return None, []

    col_line  = re.sub(r'^\(1000\s+KG\)\s*', '', lines[col_idx]).strip()
    col_parts = col_line.split()
    wind_start = col_parts.index('-15')
    slope_cols = col_parts[:wind_start]
    wind_cols  = col_parts[wind_start:]

    header = ['WEIGHT (1000 KG)']
    for c in slope_cols:
        header.append('SLOPE / ' + c)
    for c in wind_cols:
        header.append('WIND / ' + c)

    n_cols = len(slope_cols) + len(wind_cols)
    rows   = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[col_idx + 1:], start=col_idx + 1):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts or not re.match(r'^\d{2,3}$', parts[0]):
            data_end_idx = i
            break
        values = parts[1:]
        while len(values) < n_cols:
            values.append('')
        rows.append([parts[0]] + values[:n_cols])

    notes = extract_notes(lines, data_end_idx)
    return (rows if len(rows) > 1 else None), notes


def extract_v1_mcg(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        total = len(pdf.pages)
        for p in [page_num, page_num + 1]:
            if p >= total:
                continue
            text  = pdf.pages[p].extract_text()
            lines = text.splitlines() if text else []

            mcg_idx = None
            for i, line in enumerate(lines):
                if 'V1(MCG)' in line and 'not' not in line and 'Check' not in line:
                    mcg_idx = i
                    break
            if mcg_idx is None:
                continue

            alt_idx = None
            for i in range(mcg_idx, min(mcg_idx + 8, len(lines))):
                if '-2000' in lines[i] and '2000' in lines[i]:
                    alt_idx = i
                    break
            if alt_idx is None:
                continue

            alt_line  = lines[alt_idx]
            has_f     = '°F' in alt_line or ('F' in alt_line and '°C' in alt_line)
            alt_match = re.search(r'(-2000.*)', alt_line)
            if not alt_match:
                continue
            altitudes = alt_match.group(1).split()

            header = ['TEMP (C)']
            for alt in altitudes:
                header.append('PRESS ALT / ' + alt)

            n_alt = len(altitudes)
            rows  = [header]
            data_end_idx = len(lines)

            for i, line in enumerate(lines[alt_idx + 1:], start=alt_idx + 1):
                line = line.strip()
                if not line:
                    continue
                parts = line.split()
                if not parts or not re.match(r'^-?\d+$', parts[0]):
                    data_end_idx = i
                    break
                temp_c = parts[0]
                rest   = parts[1:]
                if has_f and rest and re.match(r'^-?\d+$', rest[0]):
                    values = rest[1:]
                else:
                    values = rest
                while len(values) < n_alt:
                    values.append('')
                rows.append([temp_c] + values[:n_alt])
                if temp_c == '-60':
                    data_end_idx = i + 1
                    break

            notes = extract_notes(lines, data_end_idx)
            if len(rows) > 1:
                return rows, notes

    return None, []


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

        if not pdf_path.exists():
            print("  PDF introuvable : " + str(pdf_path))
            success = False
            continue

        print("  " + safe_name(section_title) + "  (p." + str(page) + ")")

        for fn, key in [
            (extract_v1_vr_v2,    KEY_V1_VR_V2),
            (extract_adjustments, KEY_ADJ),
            (extract_slope_wind,  KEY_SLOPE_WIND),
            (extract_v1_mcg,      KEY_V1MCG),
        ]:
            data, notes = fn(pdf_path, page)
            if data:
                set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                         key, section_title, data)
                set_data(fcom_data, CHAPTER, safe_name(SUBCHAPTER),
                         key + '_notes', section_title, notes)
                print("    " + key + "  (" + str(len(data) - 1) + " lignes)" +
                      ("  [" + str(len(notes)) + " notes]" if notes else ""))
            else:
                print("    " + key + "  ECHEC")
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
