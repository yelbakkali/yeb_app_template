# =============================================================
# FLEET W&B EXTRACTOR - Royal Air Maroc B737 Fleet
# =============================================================
# Environnement : Juno (iPad) + iCloud Drive
# Python : 3.x
# =============================================================

# --- IMPORTS ---
import re
import pathlib
import pdfplumber
from data_extract import (
    extract_ac_id,
    extract_ac_weights,
    extract_equipment,
    extract_section_index_var,
    extract_pax_distribution,
    fit_distribution,
    build_dataframe,
    build_cn_roc_manual
)

# =============================================================
# VARIABLES GLOBALES
# =============================================================

ICLOUD_BASE = pathlib.Path("/var/mobile/Library/Mobile Documents/com~apple~CloudDocs")
FLEET_DIR   = ICLOUD_BASE / "ATPL YE" / "PREPA VOL" / "FLEET"

# =============================================================
# FONCTIONS
# =============================================================

def load_pdf(filepath: str | pathlib.Path) -> pdfplumber.PDF | None:
    """
    Ouvre un fichier PDF avec pdfplumber et retourne l'objet PDF.
    """
    filepath = pathlib.Path(filepath)
    if not filepath.exists():
        print(f"[ERREUR] Fichier introuvable : {filepath}")
        return None
    try:
        pdf = pdfplumber.open(filepath)
        print(f"[OK] '{filepath.name}' — {len(pdf.pages)} page(s) chargée(s)")
        return pdf
    except Exception as e:
        print(f"[ERREUR] Impossible d'ouvrir '{filepath.name}' : {e}")
        return None

def check_and_fix(ac_data: dict) -> dict:
    """
    Contrôle de cohérence et correction des données extraites.
    """
    eq  = ac_data["equipment"]
    w   = ac_data["weights"]
    reg = ac_data["ac_id"]["registration"]

    # --- 1. Chemical fluid None ---
    # BW = MEW + FAK_perm + Chem
    # → Chem = BW - MEW - FAK_perm
    # → Chem_index = BW_index - MEW_index - FAK_perm_index
    if eq["chem_weight"] is None:
        try:
            bw    = int(w["bw"])
            mew   = int(w["mew_oew"])
            bw_i  = float(w["bw_index"].replace(",", "."))
            mew_i = float(w["mew_oew_index"].replace(",", "."))
            fak_perm = int(eq["fak_perm_weight"]) \
                       if eq["fak_perm_weight"] is not None else None

            if fak_perm is not None:
                fak_i             = float(eq["fak_perm_index"].replace(",", "."))
                eq["chem_weight"] = str(bw - mew - fak_perm)
                eq["chem_index"]  = str(
                    round(bw_i - mew_i - fak_i, 2)
                ).replace(".", ",")
                print(f"[FIX 1] {reg} chem recalculé : "
                      f"{eq['chem_weight']} / {eq['chem_index']}")
            else:
                CHEM_STD   = 23
                CHEM_I_STD = 0.29
                fak_w = bw - mew - CHEM_STD
                fak_i = round(bw_i - mew_i - CHEM_I_STD, 2)
                eq["chem_weight"]     = str(CHEM_STD)
                eq["chem_index"]      = "+0,29"
                eq["fak_perm_weight"] = str(fak_w)
                eq["fak_perm_index"]  = str(fak_i).replace(".", ",")
                print(f"[FIX 1] {reg} chem=23/+0,29 (standard) "
                      f"fak_perm={fak_w}/"
                      f"{str(fak_i).replace('.', ',')}")

        except (TypeError, ValueError) as e:
            print(f"[WARN 1] {reg} chem non calculable : {e}")

    # --- 2. Vérification cohérence BW ---
    try:
        bw     = int(w["bw"])
        mew    = int(w["mew_oew"])
        fak_w  = int(eq["fak_perm_weight"])
        chem_w = int(eq["chem_weight"])
        bw_i   = float(w["bw_index"].replace(",", "."))
        mew_i  = float(w["mew_oew_index"].replace(",", "."))
        fak_i  = float(eq["fak_perm_index"].replace(",", "."))
        chem_i = float(eq["chem_index"].replace(",", "."))

        calc_bw   = mew + fak_w + chem_w
        calc_bw_i = round(mew_i + fak_i + chem_i, 2)
        diff_w    = abs(bw - calc_bw)
        diff_i    = abs(bw_i - calc_bw_i)

        if diff_w > 1:
            print(f"[WARN 2] {reg} BW incohérent : "
                  f"BW={bw} MEW+FAK+chem={calc_bw} "
                  f"(écart={bw - calc_bw} kg)")
        if diff_i > 0.05:
            print(f"[WARN 2] {reg} BW_index incohérent : "
                  f"BW_index={bw_i} MEW+FAK+chem={calc_bw_i} "
                  f"(écart={round(bw_i - calc_bw_i, 2)})")

    except (TypeError, ValueError):
        pass

    # --- 3. Pantry masses absolues (rétrocal) ---
    # DOW = BW + CPT(85) + FO(85) + 4×PNC(75) + Pantry + Water
    # → Pantry = DOW - BW - 470 - Water
    if eq.get("pantry_source") == "retrocal" and eq.get("dow_a_full"):
        try:
            bw      = int(w["bw"])
            bw_i    = float(w["bw_index"].replace(",", "."))
            water   = int(eq["water_full_weight"])
            water_i = float(eq["water_full_index"].replace(",", "."))

            # crew standard fixe : CPT + FO + 4 PNC
            crew   = 85 + 85 + 75 + 75 + 75 + 75  # = 470
            cpt_i  = float(eq["cpt_index"].replace(",", "."))
            fo_i   = float(eq["fo_index"].replace(",", "."))
            fwd_i  = float(eq["cc_fwd_lh_index"].replace(",", "."))
            aft_i  = float(eq["cc_aft_lh_index"].replace(",", "."))
            crew_i = round(cpt_i + fo_i + fwd_i * 2 + aft_i * 2, 2)

            crew_water   = bw + crew + water
            crew_water_i = round(bw_i + crew_i + water_i, 2)

            for dow_key, doi_key, wk, ik in [
                ("dow_a_full",     "doi_a_full",     "pantry_a_weight", "pantry_a_index"),
                ("dow_b_full",     "doi_b_full",     "pantry_b_weight", "pantry_b_index"),
                ("dow_c_full",     "doi_c_full",     "pantry_c_weight", "pantry_c_index"),
                ("dow_d_full",     "doi_d_full",     "pantry_d_weight", "pantry_d_index"),
                ("dow_ferry_full", "doi_ferry_full", "pantry_ferry_weight", "pantry_ferry_index"),
            ]:
                if eq.get(dow_key) is not None:
                    dow = int(eq[dow_key])
                    doi = float(eq[doi_key].replace(",", "."))
                    eq[wk] = str(dow - crew_water)
                    eq[ik] = str(
                        round(doi - crew_water_i, 2)
                    ).replace(".", ",")

            print(f"[FIX 3] {reg} "
                  f"pantry_a={eq['pantry_a_weight']} "
                  f"pantry_b={eq['pantry_b_weight']} "
                  f"pantry_c={eq['pantry_c_weight']} "
                  f"pantry_d={eq['pantry_d_weight']} "
                  f"pantry_ferry={eq['pantry_ferry_weight']}")

        except (TypeError, ValueError) as e:
            print(f"[WARN 3] {reg} pantry absolu non calculable : {e}")

    # --- 4. Vérification cohérence DOW ---
    # DOW = BW + CPT + FO + 4×PNC + Pantry_A + Water
    try:
        bw       = int(w["bw"])
        bw_i     = float(w["bw_index"].replace(",", "."))
        pantry_a = int(eq["pantry_a_weight"])
        water    = int(eq["water_full_weight"])
        water_i  = float(eq["water_full_index"].replace(",", "."))
        cpt_i    = float(eq["cpt_index"].replace(",", "."))
        fo_i     = float(eq["fo_index"].replace(",", "."))
        fwd_i    = float(eq["cc_fwd_lh_index"].replace(",", "."))
        aft_i    = float(eq["cc_aft_lh_index"].replace(",", "."))
        pantry_i = float(eq["pantry_a_index"].replace(",", "."))

        crew     = 470  # CPT + FO + 4 PNC
        crew_i   = round(cpt_i + fo_i + fwd_i * 2 + aft_i * 2, 2)

        calc_dow   = bw + crew + pantry_a + water
        calc_dow_i = round(bw_i + crew_i + pantry_i + water_i, 2)

        dow_ref = None
        doi_ref = None
        if eq.get("dow_a_full"):
            dow_ref = int(eq["dow_a_full"])
            doi_ref = float(eq["doi_a_full"].replace(",", "."))

        if dow_ref is not None:
            diff_w = abs(calc_dow - dow_ref)
            diff_i = abs(calc_dow_i - doi_ref)
            if diff_w > 1:
                print(f"[WARN 4] {reg} DOW incohérent : "
                      f"calculé={calc_dow} page1={dow_ref} "
                      f"(écart={calc_dow - dow_ref} kg)")
            else:
                print(f"[OK 4] {reg} DOW cohérent : "
                      f"{calc_dow} ≈ {dow_ref} "
                      f"(écart={calc_dow - dow_ref} kg)")
            if diff_i > 0.05:
                print(f"[WARN 4] {reg} DOI incohérent : "
                      f"calculé={calc_dow_i} page1={doi_ref} "
                      f"(écart={round(calc_dow_i - doi_ref, 2)})")
            else:
                print(f"[OK 4] {reg} DOI cohérent : "
                      f"{calc_dow_i} ≈ {doi_ref} "
                      f"(écart={round(calc_dow_i - doi_ref, 2)})")

    except (TypeError, ValueError) as e:
        print(f"[WARN 4] {reg} vérification DOW impossible : {e}")

    # --- 5. Normalisation des signes d'index ---
    # toutes les variations d'index doivent avoir un signe explicite + ou -
    for key, val in eq.items():
        if not key.endswith("_index"):
            continue
        if val is None:
            continue
        try:
            m = re.match(r"^([+-]*)(\d+,\d+)$", str(val).strip())
            if m:
                raw_signs  = m.group(1)
                value      = m.group(2)
                if not raw_signs:
                    eq[key] = "+" + value
                else:
                    neg_count  = raw_signs.count("-")
                    final_sign = "-" if neg_count % 2 == 1 else "+"
                    eq[key]    = final_sign + value
        except (TypeError, ValueError):
            pass

    ac_data["equipment"] = eq
    return ac_data


def check_bw_coherence(ac_data: dict) -> dict:
    """
    Vérifie la cohérence du Basic Weight.
    """
    eq  = ac_data["equipment"]
    w   = ac_data["weights"]
    reg = ac_data["ac_id"]["registration"]

    TOL_W = 1
    TOL_I = 0.05

    try:
        bw    = int(w["bw"])
        mew   = int(w["mew_oew"])
        fak_w = int(eq["fak_perm_weight"])
        chem_w = int(eq["chem_weight"])
        bw_i   = float(w["bw_index"].replace(",", "."))
        mew_i  = float(w["mew_oew_index"].replace(",", "."))
        fak_i  = float(eq["fak_perm_index"].replace(",", "."))
        chem_i = float(eq["chem_index"].replace(",", "."))

        calc_bw   = mew + fak_w + chem_w
        calc_bw_i = round(mew_i + fak_i + chem_i, 2)
        diff_w    = abs(bw - calc_bw)
        diff_i    = abs(bw_i - calc_bw_i)

        if diff_w > TOL_W:
            print(f"[WARN 2] {reg} BW incohérent : "
                  f"BW={bw} MEW+FAK+chem={calc_bw} "
                  f"(écart={bw - calc_bw} kg)")
        else:
            print(f"[OK 2] {reg} BW cohérent : "
                  f"{bw} ≈ {calc_bw} (écart={bw - calc_bw} kg)")

        if diff_i > TOL_I:
            print(f"[WARN 2] {reg} BW_index incohérent : "
                  f"BW_index={bw_i} MEW+FAK+chem={calc_bw_i} "
                  f"(écart={round(bw_i - calc_bw_i, 2)})")
        else:
            print(f"[OK 2] {reg} BW_index cohérent : "
                  f"{bw_i} ≈ {calc_bw_i} "
                  f"(écart={round(bw_i - calc_bw_i, 2)})")

    except (TypeError, ValueError) as e:
        print(f"[WARN 2] {reg} vérification BW impossible : {e}")

    return ac_data

def run_extraction() -> None:
    """
    Parcourt le dossier FLEET, extrait les données de chaque avion,
    gère les doublons, injecte les données manuelles et exporte le CSV.
    """
    # récupérer tous les PDF du dossier sauf flotte.pdf
    pdf_files = [
        f for f in FLEET_DIR.glob("*.pdf")
        if f.name != "flotte.pdf"
    ]

    if not pdf_files:
        print("[ERREUR] Aucun fichier PDF trouvé dans le dossier")
        return

    print(f"[OK] {len(pdf_files)} fichier(s) trouvé(s)")

    # dict registration → ac_data
    ac_dict = {}

    for pdf_path in sorted(pdf_files):

        # extraire la date depuis le nom de fichier
        m = re.search(r"(\d{2,3})-(\d{4})", pdf_path.stem)
        if m:
            file_month = int(m.group(1))
            file_year  = int(m.group(2))
            file_date  = (file_year, file_month)
        else:
            file_date = (0, 0)

        pdf = load_pdf(pdf_path)
        if not pdf:
            continue

        if len(pdf.pages) < 2:
            print(f"[WARN] {pdf_path.name} : moins de 2 pages, ignoré")
            pdf.close()
            continue

        p1 = pdf.pages[0].extract_text()
        p2 = pdf.pages[1].extract_text()
        pdf.close()

        if not p1 or not p2:
            print(f"[WARN] {pdf_path.name} : pages vides, ignoré")
            continue

        ac_id = extract_ac_id(p1)
        if not ac_id:
            print(f"[WARN] {pdf_path.name} : identification impossible, ignoré")
            continue

        if "WEIGHT AND INDEX CORRECTION" not in p2:
            print(f"[WARN] {pdf_path.name} : page 2 incorrecte, ignoré")
            continue

        reg = ac_id["registration"]

        # gérer les doublons : garder la plus récente, supprimer l'ancienne
        if reg in ac_dict:
            existing_date = ac_dict[reg]["file_date"]
            if file_date <= existing_date:
                pdf_path.unlink()
                print(f"[DELETE] {pdf_path.name} supprimé "
                      f"(plus ancien que {ac_dict[reg]['file_name']})")
                continue
            else:
                old_path = FLEET_DIR / ac_dict[reg]["file_name"]
                old_path.unlink()
                print(f"[DELETE] {ac_dict[reg]['file_name']} supprimé")
                print(f"[UPDATE] {reg} → nouvelle version : {pdf_path.name}")

        weights = extract_ac_weights(p1)
        eq      = extract_equipment(p2, p1)
        siv     = extract_section_index_var(p2)
        pax     = extract_pax_distribution(p2)

        ac_data = {
            "ac_id"    : ac_id,
            "weights"  : weights,
            "equipment": eq,
            "siv"      : siv,
            "pax"      : pax,
            "file_date": file_date,
            "file_name": pdf_path.name,
        }

        ac_data = check_and_fix(ac_data)
        ac_data = check_bw_coherence(ac_data)

        ac_dict[reg] = ac_data

    # injection manuelle CN-ROC (fichier mal formé)
    cn_roc = build_cn_roc_manual()
    cn_roc = check_and_fix(cn_roc)
    cn_roc = check_bw_coherence(cn_roc)
    ac_dict["CN-ROC"] = cn_roc
    print(f"\n[MANUAL] CN-ROC injecté manuellement")

    print(f"\n[OK] {len(ac_dict)} avion(s) extrait(s)")

    # construire le DataFrame et exporter
    ac_data_list = list(ac_dict.values())
    df = build_dataframe(ac_data_list)

    csv_path = FLEET_DIR / "fleet_data.csv"
    df.to_csv(csv_path, index=False)
    print(f"[OK] CSV exporté : {csv_path}")
    print(f"     {len(df)} avions / {len(df.columns)} colonnes")


if __name__ == "__main__":

    run_extraction()