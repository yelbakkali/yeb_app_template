# =============================================================
# DATA_EXTRACT - Fonctions d'extraction W&B
# Royal Air Maroc B737 Fleet
# =============================================================

# --- IMPORTS ---
import numpy as np
import pandas as pd
import re
from patterns import (
    AC_ID_PATTERNS,
    COCKPIT_PATTERNS,
    CABIN_PATTERNS,
    FAK_PATTERNS,
    CHEM_PATTERNS,
    STRETCHER_PATTERNS,
    WATER_PATTERNS,
    PANTRY_PATTERNS,
    RETROCAL_ROW_PATTERN,
    RETROCAL_PANTRY_MAP,
)


def extract_ac_id(page_text: str) -> dict | None:
    if not page_text or not page_text.strip():
        print("[INFO] Page vide, ignorée")
        return None
    if "WEIGHT AND INDEX CORRECTION" in page_text:
        print("[INFO] Page 2 (W&I Correction), ignorée")
        return None

    ac_id = {k: None for k in AC_ID_PATTERNS}
    for field, pattern in AC_ID_PATTERNS.items():
        m = re.search(pattern, page_text)
        if m:
            ac_id[field] = m.group(1).strip()
        else:
            print(f"[WARN] Champ non trouvé : {field}")
    return ac_id


def normalize_mass(token: str) -> str:
    return token.replace(".", "").replace(" ", "")


def extract_ac_weights(page_text: str) -> dict:
    weights = {
        "engine"        : None,
        "mtgw"          : None,
        "mtow"          : None,
        "mlw"           : None,
        "mzfw"          : None,
        "fuel_cap"      : None,
        "last_weighing" : None,
        "mew_oew_label" : None,
        "mew_oew"       : None,
        "mew_oew_index" : None,
        "bw"            : None,
        "bw_index"      : None,
    }

    for line in page_text.split("\n"):

        if "Last Weighing" in line:
            weights["mew_oew_label"] = "MEW" if "MEW" in line else "OEW"

        if not line.startswith("CFM"):
            continue

        parts = line.split()
        if parts[1] == "LEAP":
            weights["engine"] = f"{parts[0]} {parts[1]} {parts[2]}"
            data = parts[3:]
        else:
            weights["engine"] = parts[0]
            data = parts[1:]

        merged = []
        i = 0
        while i < len(data):
            token = data[i]
            if (
                token.isdigit()
                and i + 1 < len(data)
                and data[i+1].isdigit()
                and len(token) <= 3
                and len(data[i+1]) == 3
                and "/" not in token
            ):
                merged.append(token + data[i+1])
                i += 2
            else:
                merged.append(token)
                i += 1

        if len(merged) >= 10:
            weights["mtgw"]          = normalize_mass(merged[0])
            weights["mtow"]          = normalize_mass(merged[1])
            weights["mlw"]           = normalize_mass(merged[2])
            weights["mzfw"]          = normalize_mass(merged[3])
            weights["fuel_cap"]      = normalize_mass(merged[4])
            weights["last_weighing"] = merged[5]
            weights["mew_oew"]       = merged[6]
            weights["mew_oew_index"] = merged[7]
            weights["bw"]            = merged[8]
            weights["bw_index"]      = merged[9]

    return weights


def extract_equipment(page2_text: str, page1_text: str) -> dict:
    """
    Extrait les composantes équipement depuis la page 2.
    Les PNC sont toujours stockés individuellement (75kg chacun).
    """
    equipment = {
        "cpt_weight"          : None, "cpt_index"           : None,
        "fo_weight"           : None, "fo_index"            : None,
        "obs1_weight"         : None, "obs1_index"          : None,
        "obs2_weight"         : None, "obs2_index"          : None,
        # champs intermédiaires cabin crew
        "cc_fwd_weight"       : None, "cc_fwd_index"        : None,
        "cc_aft_weight"       : None, "cc_aft_index"        : None,
        # PNC individuels
        "cc_fwd_lh_weight"    : None, "cc_fwd_lh_index"     : None,
        "cc_fwd_rh_weight"    : None, "cc_fwd_rh_index"     : None,
        "cc_aft_lh_weight"    : None, "cc_aft_lh_index"     : None,
        "cc_aft_rh_weight"    : None, "cc_aft_rh_index"     : None,
        "fak_perm_weight"     : None, "fak_perm_index"      : None,
        "fak_occ_weight"      : None, "fak_occ_index"       : None,
        "fak_vip_weight"      : None, "fak_vip_index"       : None,
        "chem_weight"         : None, "chem_index"          : None,
        "water_full_weight"   : None, "water_full_index"    : None,
        "water_3q_weight"     : None, "water_3q_index"      : None,
        "water_half_weight"   : None, "water_half_index"    : None,
        "water_1q_weight"     : None, "water_1q_index"      : None,
        "str_right_weight"    : None, "str_right_index"     : None,
        "str_left_weight"     : None, "str_left_index"      : None,
        "pantry_a_weight"     : None, "pantry_a_index"      : None,
        "pantry_b_weight"     : None, "pantry_b_index"      : None,
        "pantry_c_weight"     : None, "pantry_c_index"      : None,
        "pantry_d_weight"     : None, "pantry_d_index"      : None,
        "pantry_ferry_weight" : None, "pantry_ferry_index"  : None,
        "water_source"        : None,
        "pantry_source"       : None,
        # champs intermédiaires pour rétrocal pantry
        "dow_a_full"          : None, "doi_a_full"          : None,
        "dow_b_full"          : None, "doi_b_full"          : None,
        "dow_c_full"          : None, "doi_c_full"          : None,
        "dow_d_full"          : None, "doi_d_full"          : None,
        "dow_ferry_full"      : None, "doi_ferry_full"      : None,
    }

    lines = page2_text.split("\n")

    # --- COCKPIT CREW ---
    for line in lines:
        for key, (pattern, wk, ik) in COCKPIT_PATTERNS.items():
            m = re.search(pattern, line)
            if m:
                equipment[wk] = m.group(1)
                equipment[ik] = m.group(2)

    # --- CABIN CREW ---
    # détection automatique individuel vs groupé depuis le label du pattern
    for line in lines:
        for key, (pattern, wk, ik) in CABIN_PATTERNS.items():
            m = re.search(pattern, line)
            if m:
                w_val = m.group(1)
                i_val = m.group(2)

                if key in ("fwd_4posts", "aft_4posts"):
                    # 1 PNC individuel par ligne (LH ou RH)
                    equipment[wk] = w_val
                    equipment[ik] = i_val
                    if "LH" in line or "Lh" in line:
                        if "Forward" in line:
                            equipment["cc_fwd_lh_weight"] = w_val
                            equipment["cc_fwd_lh_index"]  = i_val
                        else:
                            equipment["cc_aft_lh_weight"] = w_val
                            equipment["cc_aft_lh_index"]  = i_val
                    elif "RH" in line or "Rh" in line:
                        if "Forward" in line:
                            equipment["cc_fwd_rh_weight"] = w_val
                            equipment["cc_fwd_rh_index"]  = i_val
                        else:
                            equipment["cc_aft_rh_weight"] = w_val
                            equipment["cc_aft_rh_index"]  = i_val

                elif key in ("fwd_2pnc", "aft_2pnc"):
                    # 2 PNC groupés → diviser par 2
                    try:
                        w_ind = str(round(int(w_val) / 2))
                        i_ind = str(round(
                            float(i_val.replace(",", ".")) / 2, 2
                        )).replace(".", ",")
                    except (TypeError, ValueError):
                        w_ind = w_val
                        i_ind = i_val
                    equipment[wk] = w_ind
                    equipment[ik] = i_ind
                    if "Forward" in line:
                        equipment["cc_fwd_lh_weight"] = w_ind
                        equipment["cc_fwd_lh_index"]  = i_ind
                        equipment["cc_fwd_rh_weight"] = w_ind
                        equipment["cc_fwd_rh_index"]  = i_ind
                    else:
                        equipment["cc_aft_lh_weight"] = w_ind
                        equipment["cc_aft_lh_index"]  = i_ind
                        equipment["cc_aft_rh_weight"] = w_ind
                        equipment["cc_aft_rh_index"]  = i_ind

    # --- FLY AWAY KIT ---
    for line in lines:
        for key, (pattern, wk, ik) in FAK_PATTERNS.items():
            m = re.search(pattern, line)
            if m:
                equipment[wk] = m.group(1)
                equipment[ik] = m.group(2)

    # --- CHEMICAL FLUID ---
    chem_found   = False
    chem_context = False
    for i, line in enumerate(lines):
        if chem_found:
            break
        m = re.search(CHEM_PATTERNS["inline"], line)
        if m:
            equipment["chem_weight"] = m.group(1)
            equipment["chem_index"]  = m.group(2)
            chem_found = True
            continue
        if "Chimical Fluid" in line:
            chem_context = True
            continue
        if chem_context:
            m2 = re.search(CHEM_PATTERNS["crew_fused"], line)
            if m2:
                equipment["chem_weight"] = m2.group(1)
                equipment["chem_index"]  = m2.group(2)
                chem_found   = True
                chem_context = False
            elif line.startswith("Cabin") or line.startswith("Pantry"):
                chem_context = False

    # --- STRETCHER ---
    for line in lines:
        for key, (pattern, wk, ik) in STRETCHER_PATTERNS.items():
            m = re.search(pattern, line)
            if m:
                equipment[wk] = m.group(1)
                equipment[ik] = m.group(2)

    # --- POTABLE WATER ---
    water_found = False
    for line in lines:
        for label, (pattern, wk, ik) in WATER_PATTERNS.items():
            m = re.match(pattern, line)
            if m:
                equipment[wk] = m.group(1)
                equipment[ik] = m.group(2)
                water_found = True
    if water_found:
        equipment["water_source"] = "page2"

    # --- PANTRY ---
    pantry_found = False
    for line in lines:
        for label, (pattern, wk, ik) in PANTRY_PATTERNS.items():
            m = re.search(pattern, line)
            if m:
                equipment[wk] = m.group(1)
                sign_str = m.group(2)
                signs = re.match(r"^([+-]+)", sign_str)
                if signs:
                    raw_signs  = signs.group(1)
                    neg_count  = raw_signs.count("-")
                    final_sign = "-" if neg_count % 2 == 1 else "+"
                    value      = re.sub(r"^[+-]+", "", sign_str)
                    equipment[ik] = final_sign + value
                else:
                    equipment[ik] = sign_str
                pantry_found = True
    if pantry_found:
        equipment["pantry_source"] = "page2"

    # --- RETRO-CALCUL ---
    if not water_found or not pantry_found:
        equipment = _retrocal(equipment, page1_text, water_found, pantry_found)

    return equipment


def _retrocal(equipment: dict, page1_text: str,
              water_found: bool, pantry_found: bool) -> dict:
    """
    Rétro-calcul eau depuis les tableaux DOW/DOI page 1.
    Pour le pantry, on stocke les DOW/DOI bruts pour
    calcul des masses absolues dans check_and_fix.
    """
    kit_data    = {}
    current_kit = None

    for line in page1_text.split("\n"):
        if "Permanent Fly Away Kit" in line:
            current_kit = "Permanent"
            continue
        if "Occasional Fly Away Kit" in line or "VIP Fly Away Kit" in line:
            current_kit = None
            continue
        if current_kit != "Permanent":
            continue
        m = re.match(RETROCAL_ROW_PATTERN, line)
        if m:
            code = "C" if m.group(1).startswith("C") else m.group(1)
            kit_data[code] = {
                "Full": (m.group(2), m.group(3)),
                "3/4" : (m.group(4), m.group(5)),
                "1/2" : (m.group(6), m.group(7)),
                "1/4" : (m.group(8), m.group(9)),
            }

    def doi_diff(a: str, b: str) -> str:
        result = round(
            float(a.replace(",", ".")) - float(b.replace(",", ".")), 2
        )
        return str(result).replace(".", ",")

    # --- rétro-calcul eau ---
    if not water_found and "A" in kit_data:
        ref = kit_data["A"]

        w_1q   = int(ref["Full"][0]) - int(ref["3/4"][0])
        w_half = int(ref["Full"][0]) - int(ref["1/2"][0])
        w_3q   = int(ref["Full"][0]) - int(ref["1/4"][0])
        w_full = w_3q + w_1q

        i_1q   = doi_diff(ref["Full"][1], ref["3/4"][1])
        i_half = doi_diff(ref["Full"][1], ref["1/2"][1])
        i_3q   = doi_diff(ref["Full"][1], ref["1/4"][1])
        i_full = str(
            round(
                float(i_3q.replace(",", ".")) + float(i_1q.replace(",", ".")),
                2
            )
        ).replace(".", ",")

        equipment["water_full_weight"] = str(w_full)
        equipment["water_full_index"]  = i_full
        equipment["water_3q_weight"]   = str(w_3q)
        equipment["water_3q_index"]    = i_3q
        equipment["water_half_weight"] = str(w_half)
        equipment["water_half_index"]  = i_half
        equipment["water_1q_weight"]   = str(w_1q)
        equipment["water_1q_index"]    = i_1q
        equipment["water_source"]      = "retrocal"

    # --- rétro-calcul pantry ---
    if not pantry_found and "A" in kit_data:
        for code, dow_key, doi_key in [
            ("A",     "dow_a_full",     "doi_a_full"),
            ("B",     "dow_b_full",     "doi_b_full"),
            ("C",     "dow_c_full",     "doi_c_full"),
            ("D",     "dow_d_full",     "doi_d_full"),
            ("FERRY", "dow_ferry_full", "doi_ferry_full"),
        ]:
            if code in kit_data:
                equipment[dow_key] = kit_data[code]["Full"][0]
                equipment[doi_key] = kit_data[code]["Full"][1]

        equipment["pantry_source"] = "retrocal"

    return equipment


def extract_section_index_var(page2_text: str) -> dict:
    section_index_var = {
        "oa_adult"  : None, "oa_male"  : None,
        "oa_female" : None, "oa_child" : None,
        "ob_adult"  : None, "ob_male"  : None,
        "ob_female" : None, "ob_child" : None,
        "oc_adult"  : None, "oc_male"  : None,
        "oc_female" : None, "oc_child" : None,
    }

    for line in page2_text.split("\n"):
        m = re.match(
            r"^(OA|OB|OC)\s+"
            r"([+-]?\d+,\d+)\s+([+-]?\d+,\d+)\s+"
            r"([+-]?\d+,\d+)\s+([+-]?\d+,\d+)",
            line
        )
        if m:
            section = m.group(1).lower()
            section_index_var[f"{section}_adult"]  = m.group(2)
            section_index_var[f"{section}_male"]   = m.group(3)
            section_index_var[f"{section}_female"] = m.group(4)
            section_index_var[f"{section}_child"]  = m.group(5)

    return section_index_var


def extract_pax_distribution(page2_text: str) -> dict:
    pax_distribution = {}

    def try_parse(tokens: list) -> tuple | None:
        def generate_candidates(toks: list) -> list:
            if not toks:
                return [[]]
            results = []
            for rest in generate_candidates(toks[1:]):
                results.append([toks[0]] + rest)
            if (
                len(toks) >= 2
                and len(toks[0]) == 1
                and len(toks[1]) == 1
            ):
                fused = toks[0] + toks[1]
                for rest in generate_candidates(toks[2:]):
                    results.append([fused] + rest)
            return results

        candidates = generate_candidates(tokens)
        for candidate in candidates:
            for j in range(len(candidate) - 3):
                try:
                    total = int(candidate[j])
                    oa    = int(candidate[j+1])
                    ob    = int(candidate[j+2])
                    oc    = int(candidate[j+3])
                    if (
                        abs(oa + ob + oc - total) <= 1
                        and total > 0
                        and oa > 0
                        and ob > 0
                        and oc > 0
                    ):
                        return (total, oa, ob, oc)
                except (ValueError, IndexError):
                    continue
        return None

    capture = False
    for line in page2_text.split("\n"):

        if "Total. PAX" in line:
            capture = True
            continue
        if "Section Index" in line:
            capture = False
            continue
        if not capture:
            continue

        tokens = re.findall(r"\b(\d+)\b", line)
        tokens = [t for t in tokens if len(t) <= 3]

        if len(tokens) < 4:
            continue

        result = try_parse(tokens)
        if result:
            total, oa, ob, oc = result
            pax_distribution[str(total)] = {
                "oa": str(oa),
                "ob": str(ob),
                "oc": str(oc),
            }

    return pax_distribution


def fit_distribution(pax_distribution: dict) -> dict:
    if not pax_distribution:
        return None

    rows      = sorted(pax_distribution.items(), key=lambda x: -int(x[0]))
    max_oa    = int(rows[0][1]['oa'])
    max_ob    = int(rows[0][1]['ob'])
    max_oc    = int(rows[0][1]['oc'])
    total_max = max_oa + max_ob + max_oc

    manques  = np.array([total_max - int(r[0])       for r in rows if int(r[0]) != total_max])
    delta_oa = np.array([max_oa   - int(r[1]['oa'])  for r in rows if int(r[0]) != total_max])
    delta_ob = np.array([max_ob   - int(r[1]['ob'])  for r in rows if int(r[0]) != total_max])

    k_oa = float(np.dot(manques, delta_oa) / np.dot(manques, manques))
    k_ob = float(np.dot(manques, delta_ob) / np.dot(manques, manques))

    return {
        "k_oa"     : k_oa,
        "k_ob"     : k_ob,
        "max_oa"   : max_oa,
        "max_ob"   : max_ob,
        "max_oc"   : max_oc,
        "total_max": total_max,
    }


def distribution(n_pax: int, oa: int | None, coeffs: dict) -> dict:
    if coeffs is None:
        return {"oa": oa, "ob": None, "oc": None, "total": n_pax}

    max_oa    = coeffs["max_oa"]
    max_ob    = coeffs["max_ob"]
    max_oc    = coeffs["max_oc"]
    total_max = coeffs["total_max"]
    k_oa      = coeffs["k_oa"]
    k_ob      = coeffs["k_ob"]

    manque = total_max - n_pax

    if oa is None:
        oa = max(0, min(max_oa, round(max_oa - k_oa * manque)))

    ob = max(0, min(max_ob, round(max_ob - k_ob * manque)))
    oc = n_pax - oa - ob

    if oc > max_oc:
        diff = oc - max_oc
        oc   = max_oc
        ob   = ob - diff

    return {
        "oa"   : oa,
        "ob"   : ob,
        "oc"   : oc,
        "total": n_pax,
    }


def build_dataframe(ac_data_list: list) -> "pd.DataFrame":
    columns = [
        # identité
        ("AIRCRAFT",          "",                 ""         ),
        ("ABREV",             "",                 ""         ),
        ("REV",               "",                 ""         ),
        ("REV_DATE",          "",                 ""         ),
        ("VERSION",           "",                 ""         ),
        ("LOPA",              "",                 ""         ),
        # masses limites
        ("MAX TAXI",          "",                 ""         ),
        ("MAX TAKEOFF",       "",                 ""         ),
        ("MAX LANDING",       "",                 ""         ),
        ("MAX ZERO FUEL",     "",                 ""         ),
        ("FUEL CAPACITY",     "",                 ""         ),
        # empty
        ("EMPTY",             "WEIGHT",           ""         ),
        ("EMPTY",             "INDEX",            ""         ),
        # fly away kit
        ("FLY AWAY KIT",      "PERMANENT",        "WEIGHT"   ),
        ("FLY AWAY KIT",      "PERMANENT",        "INDEX VAR"),
        ("FLY AWAY KIT",      "OCCASIONNAL",      "WEIGHT"   ),
        ("FLY AWAY KIT",      "OCCASIONNAL",      "INDEX VAR"),
        ("FLY AWAY KIT",      "VIP",              "WEIGHT"   ),
        ("FLY AWAY KIT",      "VIP",              "INDEX VAR"),
        # chemical fluid
        ("CHEMICAL FLUID",    "WEIGHT",           ""         ),
        ("CHEMICAL FLUID",    "INDEX VAR",        ""         ),
        # crew
        ("CREW",              "Captain or FO",    "WEIGHT"   ),
        ("CREW",              "Captain or FO",    "INDEX VAR"),
        ("CREW",              "1ST OBS",          "WEIGHT"   ),
        ("CREW",              "1ST OBS",          "INDEX VAR"),
        ("CREW",              "2ND OBS",          "WEIGHT"   ),
        ("CREW",              "2ND OBS",          "INDEX VAR"),
        ("CREW",              "FWD LH",           "WEIGHT"   ),
        ("CREW",              "FWD LH",           "INDEX VAR"),
        ("CREW",              "FWD RH",           "WEIGHT"   ),
        ("CREW",              "FWD RH",           "INDEX VAR"),
        ("CREW",              "AFT LH",           "WEIGHT"   ),
        ("CREW",              "AFT LH",           "INDEX VAR"),
        ("CREW",              "AFT RH",           "WEIGHT"   ),
        ("CREW",              "AFT RH",           "INDEX VAR"),
        # stretcher
        ("STRETCHER",         "RIGHT",            "WEIGHT"   ),
        ("STRETCHER",         "RIGHT",            "INDEX VAR"),
        ("STRETCHER",         "LEFT",             "WEIGHT"   ),
        ("STRETCHER",         "LEFT",             "INDEX VAR"),
        # pantry
        ("PANTRY",            "A",                "WEIGHT"   ),
        ("PANTRY",            "A",                "INDEX VAR"),
        ("PANTRY",            "B",                "WEIGHT"   ),
        ("PANTRY",            "B",                "INDEX VAR"),
        ("PANTRY",            "C/E/F",            "WEIGHT"   ),
        ("PANTRY",            "C/E/F",            "INDEX VAR"),
        ("PANTRY",            "D",                "WEIGHT"   ),
        ("PANTRY",            "D",                "INDEX VAR"),
        # water
        ("WATER",             "DRINKING by 1/4",  "WEIGHT"   ),
        ("WATER",             "DRINKING by 1/4",  "INDEX VAR"),
        ("WATER",             "by 1/4",           "WEIGHT"   ),
        ("WATER",             "by 1/4",           "INDEX VAR"),
        # max pax
        ("MAX_PAX",           "",                 ""         ),
        # seating condition
        ("SEATING CONDITION", "OA",               "ADULT"    ),
        ("SEATING CONDITION", "OA",               "MALE"     ),
        ("SEATING CONDITION", "OA",               "FEMALE"   ),
        ("SEATING CONDITION", "OA",               "CHILD"    ),
        ("SEATING CONDITION", "OB",               "ADULT"    ),
        ("SEATING CONDITION", "OB",               "MALE"     ),
        ("SEATING CONDITION", "OB",               "FEMALE"   ),
        ("SEATING CONDITION", "OB",               "CHILD"    ),
        ("SEATING CONDITION", "OC",               "ADULT"    ),
        ("SEATING CONDITION", "OC",               "MALE"     ),
        ("SEATING CONDITION", "OC",               "FEMALE"   ),
        ("SEATING CONDITION", "OC",               "CHILD"    ),
        # distribution
        ("DISTRIBUTION",      "OA",               "MAX"      ),
        ("DISTRIBUTION",      "OA",               "COEFF"    ),
        ("DISTRIBUTION",      "OB",               "MAX"      ),
        ("DISTRIBUTION",      "OB",               "COEFF"    ),
        ("DISTRIBUTION",      "OC",               "MAX"      ),
        ("DISTRIBUTION",      "OC",               "COEFF"    ),
    ]

    multi_index = pd.MultiIndex.from_tuples(columns)
    rows = []

    for ac in ac_data_list:
        aid    = ac["ac_id"]
        w      = ac["weights"]
        eq     = ac["equipment"]
        siv    = ac["siv"]
        pax    = ac["pax"]
        coeffs = fit_distribution(pax)

        capt_fo_w = eq["cpt_weight"]
        capt_fo_i = eq["cpt_index"]

        max_pax = coeffs["total_max"] if coeffs else None
        k_oa    = round(coeffs["k_oa"], 6) if coeffs else None
        k_ob    = round(coeffs["k_ob"], 6) if coeffs else None
        max_oa  = coeffs["max_oa"]         if coeffs else None
        max_ob  = coeffs["max_ob"]         if coeffs else None
        max_oc  = coeffs["max_oc"]         if coeffs else None

        row = [
            # identité
            aid["registration"],
            aid["registration"].replace("CN-", "") if aid["registration"] else None,
            aid["revision"],
            aid["date"],
            aid["version"],
            aid["lopa"],
            # masses limites
            w["mtgw"],
            w["mtow"],
            w["mlw"],
            w["mzfw"],
            w["fuel_cap"],
            # empty
            w["mew_oew"],
            w["mew_oew_index"],
            # fly away kit
            eq["fak_perm_weight"],    eq["fak_perm_index"],
            eq["fak_occ_weight"],     eq["fak_occ_index"],
            eq["fak_vip_weight"],     eq["fak_vip_index"],
            # chemical fluid
            eq["chem_weight"],        eq["chem_index"],
            # crew
            capt_fo_w,                capt_fo_i,
            eq["obs1_weight"],        eq["obs1_index"],
            eq["obs2_weight"],        eq["obs2_index"],
            eq["cc_fwd_lh_weight"],   eq["cc_fwd_lh_index"],
            eq["cc_fwd_rh_weight"],   eq["cc_fwd_rh_index"],
            eq["cc_aft_lh_weight"],   eq["cc_aft_lh_index"],
            eq["cc_aft_rh_weight"],   eq["cc_aft_rh_index"],
            # stretcher
            eq["str_right_weight"],   eq["str_right_index"],
            eq["str_left_weight"],    eq["str_left_index"],
            # pantry
            eq["pantry_a_weight"],    eq["pantry_a_index"],
            eq["pantry_b_weight"],    eq["pantry_b_index"],
            eq["pantry_c_weight"],    eq["pantry_c_index"],
            eq["pantry_d_weight"],    eq["pantry_d_index"],
            # water
            eq["water_1q_weight"],    eq["water_1q_index"],
            eq["water_full_weight"],  eq["water_full_index"],
            # max pax
            max_pax,
            # seating condition
            siv["oa_adult"], siv["oa_male"], siv["oa_female"], siv["oa_child"],
            siv["ob_adult"], siv["ob_male"], siv["ob_female"], siv["ob_child"],
            siv["oc_adult"], siv["oc_male"], siv["oc_female"], siv["oc_child"],
            # distribution
            max_oa, k_oa,
            max_ob, k_ob,
            max_oc, None,
        ]

        rows.append(row)

    df = pd.DataFrame(rows, columns=multi_index)
    return df


def build_cn_roc_manual() -> dict:
    """
    Données CN-ROC saisies manuellement depuis les images.
    Le fichier source est mal formé — injection manuelle.
    """
    ac_id = {
        "registration" : "CN-ROC",
        "aircraft_type": "B737-800",
        "revision"     : "001-2023",
        "date"         : "12/04/2023",
        "lopa"         : "EG1305",
        "version"      : "12C147Y",
        "standard_crew": "2/4",
    }

    weights = {
        "engine"        : "CFM56-7B26",
        "mtgw"          : "75296",
        "mtow"          : "75069",
        "mlw"           : "66360",
        "mzfw"          : "62731",
        "fuel_cap"      : "20893",
        "last_weighing" : "12/04/2023",
        "mew_oew_label" : "MEW",
        "mew_oew"       : "41313",
        "mew_oew_index" : "45,03",
        "bw"            : "41388",
        "bw_index"      : "44,67",
    }

    equipment = {
        "cpt_weight"          : "85",    "cpt_index"           : "-1,52",
        "fo_weight"           : "85",    "fo_index"            : "-1,52",
        "obs1_weight"         : "85",    "obs1_index"          : "-1,44",
        "obs2_weight"         : "85",    "obs2_index"          : "-1,45",
        "cc_fwd_weight"       : "75",    "cc_fwd_index"        : "-1,18",
        "cc_aft_weight"       : "75",    "cc_aft_index"        : "+1,08",
        "cc_fwd_lh_weight"    : "75",    "cc_fwd_lh_index"     : "-1,18",
        "cc_fwd_rh_weight"    : "75",    "cc_fwd_rh_index"     : "-1,18",
        "cc_aft_lh_weight"    : "75",    "cc_aft_lh_index"     : "+1,08",
        "cc_aft_rh_weight"    : "75",    "cc_aft_rh_index"     : "+1,08",
        "fak_perm_weight"     : "52",    "fak_perm_index"      : "-0,65",
        "fak_occ_weight"      : "215",   "fak_occ_index"       : "-2,70",
        "fak_vip_weight"      : "210",   "fak_vip_index"       : "-2,64",
        "chem_weight"         : "23",    "chem_index"          : "+0,29",
        "water_full_weight"   : None,    "water_full_index"    : None,
        "water_3q_weight"     : None,    "water_3q_index"      : None,
        "water_half_weight"   : None,    "water_half_index"    : None,
        "water_1q_weight"     : None,    "water_1q_index"      : None,
        "str_right_weight"    : "57,16", "str_right_index"     : "+0,68",
        "str_left_weight"     : "57,16", "str_left_index"      : "+0,63",
        "pantry_a_weight"     : None,    "pantry_a_index"      : None,
        "pantry_b_weight"     : None,    "pantry_b_index"      : None,
        "pantry_c_weight"     : None,    "pantry_c_index"      : None,
        "pantry_d_weight"     : None,    "pantry_d_index"      : None,
        "pantry_ferry_weight" : None,    "pantry_ferry_index"  : None,
        "water_source"        : None,
        "pantry_source"       : None,
        "dow_a_full"          : "43382", "doi_a_full"          : "49,03",
        "dow_b_full"          : "43138", "doi_b_full"          : "47,52",
        "dow_c_full"          : "43255", "doi_c_full"          : "46,21",
        "dow_d_full"          : "42355", "doi_d_full"          : "43,83",
        "dow_ferry_full"      : None,    "doi_ferry_full"      : None,
    }

    w_1q   = 43382 - 43323
    w_half = 43382 - 43263
    w_3q   = 43382 - 43204
    w_full = w_3q + w_1q

    i_1q   = round(49.03 - 48.20, 2)
    i_half = round(49.03 - 47.37, 2)
    i_3q   = round(49.03 - 46.54, 2)
    i_full = round(i_3q + i_1q, 2)

    equipment["water_full_weight"]  = str(w_full)
    equipment["water_full_index"]   = str(i_full).replace(".", ",")
    equipment["water_3q_weight"]    = str(w_3q)
    equipment["water_3q_index"]     = str(i_3q).replace(".", ",")
    equipment["water_half_weight"]  = str(w_half)
    equipment["water_half_index"]   = str(i_half).replace(".", ",")
    equipment["water_1q_weight"]    = str(w_1q)
    equipment["water_1q_index"]     = str(i_1q).replace(".", ",")
    equipment["water_source"]       = "retrocal"
    equipment["pantry_source"]      = "retrocal"

    siv = {
        "oa_adult"  : "-0,9919", "oa_male"   : "-1,0392",
        "oa_female" : "-0,8266", "oa_child"  : "-0,4133",
        "ob_adult"  : "-0,2911", "ob_male"   : "-0,3050",
        "ob_female" : "-0,2426", "ob_child"  : "-0,1213",
        "oc_adult"  : "+0,6569", "oc_male"   : "+0,6882",
        "oc_female" : "+0,5474", "oc_child"  : "+0,2737",
    }

    pax = {
        "159": {"oa": "12", "ob": "78", "oc": "69"},
        "150": {"oa": "11", "ob": "74", "oc": "65"},
        "140": {"oa": "11", "ob": "69", "oc": "61"},
        "130": {"oa": "10", "ob": "64", "oc": "56"},
        "120": {"oa": "9",  "ob": "59", "oc": "52"},
        "100": {"oa": "8",  "ob": "49", "oc": "43"},
        "90":  {"oa": "7",  "ob": "44", "oc": "40"},
        "80":  {"oa": "6",  "ob": "39", "oc": "35"},
        "70":  {"oa": "5",  "ob": "34", "oc": "31"},
        "60":  {"oa": "5",  "ob": "29", "oc": "27"},
        "50":  {"oa": "3",  "ob": "25", "oc": "22"},
        "40":  {"oa": "2",  "ob": "20", "oc": "18"},
        "20":  {"oa": "1",  "ob": "10", "oc": "9"},
    }

    return {
        "ac_id"    : ac_id,
        "weights"  : weights,
        "equipment": equipment,
        "siv"      : siv,
        "pax"      : pax,
        "file_date": (2023, 1),
        "file_name": "AWB_CN-ROC_001-2023.pdf",
    }
