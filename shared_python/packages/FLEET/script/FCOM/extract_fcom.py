"""
extract_fcom.py
Librairie d'extraction FCOM Boeing 737 NG / MAX — Royal Air Maroc
Dépendance : pip install pdfplumber
"""

import csv
import gc
import json
import logging
import re
from pathlib import Path

import pdfplumber
from pdfminer.pdftypes import resolve1, PDFObjRef

logging.getLogger("pdfminer").setLevel(logging.ERROR)

RE_HEADER = re.compile(r"Registry\s+Number", re.IGNORECASE)
RE_ROW    = re.compile(r"^\s*(CN-[A-Z]{3}|\d{4,6})\s+(\d{4,6})\s+([A-Z0-9]{4,6})\s*$")
RE_DOC    = re.compile(r"Document Number\s+(D6-[\w\-()+]+)")
RE_REV    = re.compile(r"Revision Number[:\s]+(\d+)")
RE_DATE   = re.compile(r"Revision Date[:\s]+(.+)")

PERF_CHAPTERS = {"Performance Dispatch", "Performance Inflight"}


# ── Metadata ──────────────────────────────────────────────────────────────────

def extract_metadata(pdf_path):
    """Lit les 5 premières pages pour les métadonnées du document."""
    meta = {"doc": "", "rev": "", "date": "", "model": "", "filename": Path(pdf_path).name}
    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages[:5]:
            for line in (page.extract_text() or "").splitlines():
                if not meta["doc"]:
                    m = RE_DOC.search(line)
                    if m: meta["doc"] = m.group(1).strip()
                if not meta["rev"]:
                    m = RE_REV.search(line)
                    if m: meta["rev"] = m.group(1).strip()
                if not meta["date"]:
                    m = RE_DATE.search(line)
                    if m: meta["date"] = m.group(1).strip()
            page.flush_cache()
    doc = meta["doc"].upper()
    meta["model"] = "737 MAX" if "MAX" in doc else ("737 NG" if "8B6" in doc else "737")
    gc.collect()
    return meta


def read_metadata_file(path):
    """Lit metadata.json. Retourne un dict {filename: {doc, rev, ...}} ou {}."""
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return {}


def write_metadata_file(metas, path):
    """Écrit metadata.json à partir d'une liste de metadata dicts."""
    data = {m["filename"]: {"doc": m["doc"], "rev": m["rev"],
                             "date": m["date"], "model": m["model"]}
            for m in metas}
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def needs_extraction(fcom_dir, metadata_path):
    """
    Compare les FCOMs présents dans fcom_dir avec metadata.json.
    Retourne (True, raison) si extraction nécessaire, (False, "") sinon.
    """
    pdfs = sorted(Path(fcom_dir).glob("*.pdf"))
    if not pdfs:
        return False, "Aucun PDF trouvé."

    stored = read_metadata_file(metadata_path)
    if not stored:
        return True, "metadata.json absent ou vide."

    current_filenames = {p.name for p in pdfs}
    stored_filenames  = set(stored.keys())

    if current_filenames != stored_filenames:
        added   = current_filenames - stored_filenames
        removed = stored_filenames  - current_filenames
        reasons = []
        if added:   reasons.append(f"nouveaux fichiers : {', '.join(added)}")
        if removed: reasons.append(f"fichiers supprimés : {', '.join(removed)}")
        return True, " | ".join(reasons)

    for pdf_path in pdfs:
        meta         = extract_metadata(pdf_path)
        stored_entry = stored.get(pdf_path.name, {})
        if (meta["doc"] != stored_entry.get("doc") or
                meta["rev"] != stored_entry.get("rev")):
            return True, (f"{pdf_path.name} : "
                          f"rev {stored_entry.get('rev')} → {meta['rev']}")

    return False, ""


# ── TOC ───────────────────────────────────────────────────────────────────────

def build_toc(pdf_path):
    """Construit le TOC complet sous forme d'arbre. Chaque nœud : {title, page, children}."""
    with pdfplumber.open(pdf_path) as pdf:
        doc = pdf.doc
        objid_to_page = {p.page_obj.pageid: i for i, p in enumerate(pdf.pages)}

        def dest_to_page(dest):
            try:
                resolved = resolve1(doc.get_dest(dest))
                d = resolved.get('D', resolved) if isinstance(resolved, dict) else resolved
                objid = d[0].objid if isinstance(d[0], PDFObjRef) else None
                return objid_to_page.get(objid)
            except:
                return None

        flat = [{"level": l, "title": t, "page": dest_to_page(d)}
                for l, t, d, _, __ in doc.get_outlines()]

    root, stack = [], []
    for entry in flat:
        node = {"title": entry["title"], "page": entry["page"], "children": []}
        while stack and stack[-1][0] >= entry["level"]:
            stack.pop()
        if stack:
            stack[-1][1]["children"].append(node)
        else:
            root.append(node)
        stack.append((entry["level"], node))

    gc.collect()
    return root


def find_pkg_sections(toc):
    """
    Retourne (preface_secs, perf_secs) depuis le TOC.
    preface_secs : [{chapter, section_title, page, page_end}]
    perf_secs    : [{chapter, section_title, page, page_end}]
    """
    preface, perf = [], []

    for node in toc:
        title = node["title"]

        if title == "Preface":
            for child in node["children"]:
                if child["title"] == "Model Identification":
                    next_pages = [c["page"] for c in node["children"]
                                  if c["page"] and c["page"] > child["page"]]
                    preface.append({
                        "chapter":       "Preface",
                        "section_title": "",
                        "page":          child["page"],
                        "page_end":      min(next_pages) if next_pages else child["page"] + 10,
                    })

        elif title in PERF_CHAPTERS:
            for sec in node["children"]:
                if not sec["title"].startswith("Section "):
                    continue
                clean_title = sec["title"][len("Section "):].strip()
                for sub in sec["children"]:
                    if sub["title"] == "Pkg Model Identification":
                        next_pages = [s["page"] for s in sec["children"]
                                      if s["page"] and s["page"] > sub["page"]]
                        perf.append({
                            "chapter":       title,
                            "section_title": clean_title,
                            "page":          sub["page"],
                            "page_end":      min(next_pages) if next_pages else sub["page"] + 10,
                        })

    return preface, perf


# ── Extraction ────────────────────────────────────────────────────────────────

def _parse_row(line):
    m = RE_ROW.match(line)
    if not m:
        return None
    col1, msn, tab = m.groups()
    immat = "" if re.fullmatch(r"\d{4,6}", col1) else col1
    msn   = col1 if immat == "" else msn
    return {"Immatriculation": immat, "MSN": msn, "Tabulation": tab}


def extract_section_aircraft(pdf_path, section):
    """Extrait les avions d'une section en lisant uniquement ses pages."""
    start = section["page"]
    stop  = min(section["page_end"], section["page"] + 15)
    records, seen = [], set()

    with pdfplumber.open(pdf_path) as pdf:
        for i in range(start, min(stop, len(pdf.pages))):
            for line in (pdf.pages[i].extract_text() or "").splitlines():
                if RE_HEADER.search(line):
                    continue
                r = _parse_row(line)
                if r is None:
                    continue
                key = (r["Immatriculation"] or r["MSN"], r["MSN"])
                if key not in seen:
                    seen.add(key)
                    records.append(r)
            pdf.pages[i].flush_cache()

    gc.collect()
    return records


# ── Fonctions publiques ───────────────────────────────────────────────────────

def write_csv(records, path):
    """Écrit le CSV trié par immatriculation."""
    fields = [
        "Immatriculation", "MSN", "Tabulation",
        "Section", "Modèle", "Version",
    ]
    sorted_records = sorted(
        records,
        key=lambda r: r.get("Immatriculation") or r.get("MSN", "")
    )
    with open(path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        w.writerows(sorted_records)


def process_fcom(pdf_path):
    """
    Traite un FCOM. Retourne (meta, toc, records).

    Ordre :
      1. Performance Dispatch → source de la colonne Section
      2. Preface              → avions sans section de performance
    """
    pdf_path = Path(pdf_path)
    version  = pdf_path.stem

    print(f"\n📄  {pdf_path.name}")

    meta                     = extract_metadata(pdf_path)
    toc                      = build_toc(pdf_path)
    preface_secs, perf_secs  = find_pkg_sections(toc)

    print(f"    Modèle   : {meta['model']}")
    print(f"    Document : {meta['doc']}  Rev.{meta['rev']}  {meta['date']}")

    all_records   = []
    seen_aircraft = set()

    # 1. Performance Dispatch
    pd_secs = [s for s in perf_secs if s["chapter"] == "Performance Dispatch"]
    for sec in pd_secs:
        records = extract_section_aircraft(pdf_path, sec)
        for r in records:
            key = (r["Immatriculation"] or r["MSN"], r["MSN"])
            if key not in seen_aircraft:
                seen_aircraft.add(key)
                r.update({
                    "Section": sec["section_title"],
                    "Modèle":  meta["model"],
                    "Version": version,
                })
                all_records.append(r)
        print(f"    [PD] p.{sec['page']:>4}-{sec['page_end']:>4}  "
              f"{sec['section_title'][:55]:55}  → {len(records)} avions")

    # 2. Preface — avions sans section de performance
    for sec in preface_secs:
        records = extract_section_aircraft(pdf_path, sec)
        new = 0
        for r in records:
            key = (r["Immatriculation"] or r["MSN"], r["MSN"])
            if key not in seen_aircraft:
                seen_aircraft.add(key)
                r.update({
                    "Section": "",
                    "Modèle":  meta["model"],
                    "Version": version,
                })
                all_records.append(r)
                new += 1
        if new:
            print(f"    [Preface] {new} avions sans section de performance")

    gc.collect()
    return meta, toc, all_records


def process_directory(fcom_dir):
    """Traite tous les PDFs du dossier. Retourne (all_metas, all_tocs, all_records)."""
    fcom_dir    = Path(fcom_dir)
    all_metas   = []
    all_tocs    = {}
    all_records = []

    for pdf_path in sorted(fcom_dir.glob("*.pdf")):
        try:
            meta, toc, records = process_fcom(pdf_path)
            all_metas.append(meta)
            all_tocs[pdf_path.stem] = toc
            all_records.extend(records)
        except Exception as e:
            print(f"    ❌  {pdf_path.name} : {e}")

    return all_metas, all_tocs, all_records
