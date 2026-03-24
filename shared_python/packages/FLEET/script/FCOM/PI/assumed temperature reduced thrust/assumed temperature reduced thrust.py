"""
assumed temperature reduced thrust.py
Extraction des tableaux du sous-chapitre Assumed Temperature Reduced Thrust.

Emplacement : PI/assumed temperature reduced thrust/assumed temperature reduced thrust.py

Peut etre lance seul :
  python3 "assumed temperature reduced thrust.py"

Dependances : pip install pdfplumber
"""

import re
import sys
from pathlib import Path

import pdfplumber

sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from fcom_utils import safe_name, load_toc, find_subchapters, extract_notes, assign_by_x
from fcom_utils import load_fcom_data, save_fcom_data, set_data, export_subchapter_html

SUBCHAPTER = "Assumed Temperature Reduced Thrust"
CHAPTER    = "PI"

KEY_MAX_TEMP = "Maximum Assumed Temperature"
KEY_N1       = "Takeoff %N1"
KEY_BLEED    = "%N1 Adjustments for Engine Bleeds"


def extract_oat_table(lines, start_idx, row_label):
    based_on = ""
    for i in range(start_idx, min(start_idx + 5, len(lines))):
        if lines[i].strip().startswith('Based on'):
            based_on = lines[i].strip()
            break

    alt_idx   = None
    altitudes = None
    for i in range(start_idx, min(start_idx + 10, len(lines))):
        line  = lines[i].strip()
        clean = re.sub(r'^(TEMP\s*\(.*?\)|OAT\s*\(.*?\)|ASSUMED\s+\S+\s*\(.*?\))\s+', '', line)
        parts = clean.split()
        if not parts:
            continue
        if re.match(r'^-?\d+', parts[0]) and len(parts) >= 5:
            next_val = parts[1] if len(parts) > 1 else ''
            if not re.match(r'^\d+\.\d+', next_val):
                alt_idx   = i
                altitudes = parts
                break

    if alt_idx is None or altitudes is None:
        return None, len(lines), based_on

    data_start = alt_idx + 1
    while data_start < len(lines):
        parts = lines[data_start].strip().split()
        if parts and re.match(r'^-?\d+', parts[0]):
            break
        data_start += 1

    header = [row_label] + ['ALT / ' + a for a in altitudes]
    n_cols = len(altitudes)
    rows   = [header]
    data_end_idx = len(lines)

    for i, line in enumerate(lines[data_start:], start=data_start):
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if not parts:
            continue

        if parts[0] in ('MINIMUM', 'Boeing', 'Copyright'):
            data_end_idx = i
            break

        if len(parts) >= 3 and parts[1] == '&' and parts[2] == 'BELOW':
            oat    = parts[0] + ' & BELOW'
            values = parts[3:]
        elif re.match(r'^-?\d+$', parts[0]):
            oat    = parts[0]
            values = parts[1:]
        else:
            data_end_idx = i
            break

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
    n_cols = len(altitudes)
    rows   = [header]
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
                    'ALTITUDE', '(1000', 'FT)', '(FT)', 'ASSUMED'}
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


def extract_assumed_temp_page(pdf_path, page_num):
    with pdfplumber.open(pdf_path) as pdf:
        page  = pdf.pages[page_num]
        text  = page.extract_text()
        words = page.extract_words()
    lines = text.splitlines()

    results = {}

    for i, line in enumerate(lines):
        if 'Maximum Assumed Temperature' in line or ('Table 1' in line and 'Temperature' in line):
            data, end, based_on = extract_oat_table(lines, i + 1, 'OAT (C)')
            if data:
                notes = extract_notes(lines, end)
                if based_on:
                    notes = [based_on] + notes
                results[KEY_MAX_TEMP]            = data
                results[KEY_MAX_TEMP + '_notes'] = notes
            break

    for i, line in enumerate(lines):
        if ('Takeoff %N1' in line or ('Table 2' in line and 'N1' in line)) and 'Assumed' not in line:
            data, end, based_on = extract_oat_table(lines, i + 1, 'ASSUMED TEMP (C)')
            if data:
                notes = extract_notes(lines, end)
                if based_on:
                    notes = [based_on] + notes
                results[KEY_N1]            = data
                results[KEY_N1 + '_notes'] = notes
            break

    for i, line in enumerate(lines):
        if 'Adjustment' in line and 'Bleed' in line.title():
            data, end = extract_bleed_table(lines, i + 1, words)
            if data:
                notes = extract_notes(lines, end)
                results[KEY_BLEED]            = data
                results[KEY_BLEED + '_notes'] = notes
            break

    return results


def extract_assumed_temp(pdf_path, page_num, page_end):
    results = {}
    with pdfplumber.open(pdf_path) as pdf:
        total = len(pdf.pages)

    end = min(page_end if page_end else page_num + 40, total)

    for p in range(page_num, end):
        with pdfplumber.open(pdf_path) as pdf:
            text = pdf.pages[p].extract_text() or ""
        if 'Assumed Temperature' not in text and 'Assumed Temp' not in text:
            break
        page_data = extract_assumed_temp_page(pdf_path, p)
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

        tables = extract_assumed_temp(pdf_path, page, page_end)
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
