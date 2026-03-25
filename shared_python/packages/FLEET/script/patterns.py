# =============================================================
# PATTERNS - Expressions régulières pour l'extraction W&B
# =============================================================

# --- IDENTIFICATION AVION ---
AC_ID_PATTERNS = {
    "revision"     : r"Rév\.\s+(\S+)",
    "date"         : r"Date\s+(\d{2}/\d{2}/\d{4})",
    "lopa"         : r"LOPA\s*\n?(?:AIRCRAFT WEIGHT AND BALANCE\s+)?(\S+)",
    "version"      : r"Version\s+(\S+)",
    "registration" : r"(CN-[A-Z]{3})",
    "aircraft_type": r"(B737-\w+)\s+CN-",
    "standard_crew": r"Standard Crew\s+(\d+/\d+)",
}

# --- COCKPIT CREW ---
# (pattern, weight_key, index_key)
COCKPIT_PATTERNS = {
    "cpt"  : (r"^Captain\s+(\d+)\s+([+-]?\d+,\d+)",      "cpt_weight",  "cpt_index"),
    "fo"   : (r"^First Officer\s+(\d+)\s+([+-]?\d+,\d+)", "fo_weight",   "fo_index"),
    "obs1" : (r"^1st Observer\s+(\d+)\s+([+-]?\d+,\d+)",  "obs1_weight", "obs1_index"),
    "obs2" : (r"^2nd Observer\s+(\d+)\s+([+-]?\d+,\d+)",  "obs2_weight", "obs2_index"),
}

# --- CABIN CREW ---
# (pattern, weight_key, index_key)
CABIN_PATTERNS = {
    "fwd_4posts" : (r"^Forward (?:LH|RH)\s+(\d+)\s+([+-]?\d+,\d+)",    "cc_fwd_weight", "cc_fwd_index"),
    "aft_4posts" : (r"^Aft (?:LH|RH|Rh)\s+(\d+)\s+([+-]?\d+,\d+)",     "cc_aft_weight", "cc_aft_index"),
    "fwd_2pnc"   : (r"^Forward \(2PNC\)\s+(\d+)\s+([+-]?\d+,\d+)",      "cc_fwd_weight", "cc_fwd_index"),
    "aft_2pnc"   : (r"^Aft \(2PNC\)\s+(\d+)\s+([+-]?\d+,\d+)",          "cc_aft_weight", "cc_aft_index"),
}

# --- FLY AWAY KIT ---
# (pattern, weight_key, index_key)
FAK_PATTERNS = {
    "perm" : (r"Permanent\s+(\d+)\s+([+-]?\d+,\d+)",   "fak_perm_weight", "fak_perm_index"),
    "occ"  : (r"Occasion\w+\s+(\d+)\s+([+-]?\d+,\d+)", "fak_occ_weight",  "fak_occ_index"),
    "vip"  : (r"VIP\s+(\d+)\s+([+-]?\d+,\d+)",         "fak_vip_weight",  "fak_vip_index"),
}


# --- CHEMICAL FLUID ---
CHEM_PATTERNS = {
    # format inline B737-800 : "Chimical Water 23 +0,29"
    "inline"    : r"(?:Chimical Water|Chimical Fluid)\s+(\d+)\s+([+-]?\d+,\d+)",
    # format MAX : valeur fusionnée en fin de ligne cockpit crew
    # ex: "1st Observer 85 -1,44 23 +0,29"
    # ex: "2nd Observer 85 -1,45 23 +0,29"
    # règle : ligne cockpit crew se terminant par <entier> <index>
    "crew_fused": r"^(?:1st|2nd) Observer\s+\d+\s+[+-]?\d+,\d+\s+(\d+)\s+([+-]?\d+,\d+)$",
}


# --- STRETCHER ---
# (pattern, weight_key, index_key)
STRETCHER_PATTERNS = {
    "right" : (r"Right AFT \d+ rows\s+([\d,]+)\s+([+-]?\d+,\d+)", "str_right_weight", "str_right_index"),
    "left"  : (r"Left AFT \d+ rows\s+([\d,]+)\s+([+-]?\d+,\d+)",  "str_left_weight",  "str_left_index"),
}

# --- POTABLE WATER ---
# (pattern, weight_key, index_key)
WATER_PATTERNS = {
    "Full" : (r"^Full\s+(\d+)\s+([+-]?\d+,\d+)", "water_full_weight", "water_full_index"),
    "3/4"  : (r"^3/4\s+(\d+)\s+([+-]?\d+,\d+)",  "water_3q_weight",   "water_3q_index"),
    "1/2"  : (r"^1/2\s+(\d+)\s+([+-]?\d+,\d+)",  "water_half_weight", "water_half_index"),
    "1/4"  : (r"^1/4\s+(\d+)\s+([+-]?\d+,\d+)",  "water_1q_weight",   "water_1q_index"),
}
PANTRY_PATTERNS = {
    "A"             : (r"\bA\s+(\d+)\s+([+-]?\d+,\d+)",                        "pantry_a_weight",     "pantry_a_index"),
    "B"             : (r"\bB\s+(\d+)\s+([+-]?\d+,\d+)",                        "pantry_b_weight",     "pantry_b_index"),
    "C"             : (r"\bC\s+(\d+)\s+([+-]?\d+,\d+)",                        "pantry_c_weight",     "pantry_c_index"),
    "D"     : (r"\bD\s+(\d+)\s+([+-]{1,2}\d+,\d+)",                        "pantry_d_weight",     "pantry_d_index"),
    "FERRY" : (r"\bFERRY\s+(\d+)\s+([+-]{1,2}\d+,\d+)",                    "pantry_ferry_weight", "pantry_ferry_index"),
    "CODE A"        : (r"\bCODE A\s+(\d+)\s+([+-]?\d+,\d+)",                   "pantry_a_weight",     "pantry_a_index"),
    "CODE B"        : (r"\bCODE B\s+(\d+)\s+([+-]?\d+,\d+)",                   "pantry_b_weight",     "pantry_b_index"),
    "CODE C, E et F": (r"\bCODE C,\s*E\s*et\s*F\s+(\d+)\s+([+-]?\d+,\d+)",    "pantry_c_weight",     "pantry_c_index"),
    "CODE D"        : (r"\bCODE D\s+(\d+)\s+([+-]?\d+,\d+)",                   "pantry_d_weight",     "pantry_d_index"),
}


# --- RETRO-CALCUL : ligne de données DOW/DOI page 1 ---
RETROCAL_ROW_PATTERN = (
    r"^(A|B|C,?\s*E\s*or\s*F|D|FERRY)\s+"
    r"(\d+)\s+([\d,]+)\s+"
    r"(\d+)\s+([\d,]+)\s+"
    r"(\d+)\s+([\d,]+)\s+"
    r"(\d+)\s+([\d,]+)"
)

# --- RETRO-CALCUL : mapping code pantry -> clés equipment ---
RETROCAL_PANTRY_MAP = {
    "A"     : ("pantry_a_weight",     "pantry_a_index"),
    "B"     : ("pantry_b_weight",     "pantry_b_index"),
    "C"     : ("pantry_c_weight",     "pantry_c_index"),
    "D"     : ("pantry_d_weight",     "pantry_d_index"),
    "FERRY" : ("pantry_ferry_weight", "pantry_ferry_index"),
}

# Patterns qui indiquent la fin des notes (debut d'un nouveau tableau ou section)
NOTES_STOP_PATTERNS = [
    r'^Table \d+ of \d+',
    r'^WEIGHT\s',
    r'^FLAPS\s',
    r'^TEMP\s',
    r'^PRESS ALT',
    r'^V1,\s',
    r'^Slope',
    r'^Boeing Proprietary',
    r'^Copyright',
    r'^%N1 Adjust',
    r'^Takeoff %N1',
    r'^Max (Climb|Continuous)',
    r'^Go-[Aa]round',
    r'^BLEED\s',
    r'^CONFIGURATION\s',
    r'^ENGINE\s',
    r'^PACKS\s',
    r'^WING\s',
    r'^A/C\s',
]