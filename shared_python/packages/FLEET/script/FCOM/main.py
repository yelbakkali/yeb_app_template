"""
main.py
Point d'entree unique — orchestre toute l'extraction FCOM.
  1. Verifie les versions via metadata.json
  2. Extrait TOC + flotte (extract_fcom.py)
  3. Cree l'arborescence PI et lance les scripts de tableaux (extract_pi_tables.py)
"""

import json
import sys
import os
from pathlib import Path

# Ajouter le dossier du script au path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import extract_fcom
import extract_pi_tables


FCOM_DIR      = Path(".")
METADATA_JSON = FCOM_DIR / "metadata.json"
TOC_JSON      = FCOM_DIR / "toc.json"
CSV_PATH      = FCOM_DIR / "flotte_RAM_consolidee.csv"
PI_DIR        = FCOM_DIR / "PI"


def delete_if_exists(path):
    p = Path(path)
    if p.exists():
        p.unlink()


def main():
    print("=" * 60)
    print("  Extracteur FCOM Royal Air Maroc - 737 NG / MAX")
    print("=" * 60)

    needed, reason = extract_fcom.needs_extraction(FCOM_DIR, METADATA_JSON)

    if not needed:
        print("Fichiers a jour - aucune extraction necessaire.")
        print("(" + str(METADATA_JSON.name) + " correspond aux FCOMs presents)")
        return

    print("Extraction necessaire : " + reason)

    # ── 1. TOC + flotte ───────────────────────────────────────────────────────
    all_metas, all_tocs, all_records = extract_fcom.process_directory(FCOM_DIR)

    if not all_records:
        print("Aucune donnee extraite.")
        return

    delete_if_exists(METADATA_JSON)
    extract_fcom.write_metadata_file(all_metas, METADATA_JSON)
    print("Metadonnees : " + str(METADATA_JSON.name))

    delete_if_exists(TOC_JSON)
    with open(TOC_JSON, "w", encoding="utf-8") as f:
        json.dump(all_tocs, f, ensure_ascii=False, indent=2)
    print("TOC         : " + str(TOC_JSON.name))

    delete_if_exists(CSV_PATH)
    extract_fcom.write_csv(all_records, CSV_PATH)
    print("Flotte      : " + str(CSV_PATH.name) + "  (" + str(len(all_records)) + " avions)")

    # ── 2. Arborescence PI + extraction tableaux ──────────────────────────────
    extract_pi_tables.main(
        fcom_dir    = FCOM_DIR,
        pi_dir      = PI_DIR,
        run_scripts = True
    )


if __name__ == "__main__":
    main()
