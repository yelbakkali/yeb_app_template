"""
extract_pi_tables.py
Orchestrateur du chapitre Performance Inflight (PI).

Responsabilites :
  1. Verifier si une mise a jour est necessaire (via metadata.json)
  2. Ecrire pi_chapters_map.json avec les aliases
  3. Construire la structure PI depuis toc.json
  4. Mettre a jour l'arborescence de dossiers PI/<sous-chapitre>/
  5. Executer tous les scripts .py trouves dans PI/

Peut etre lance seul :
  python3 extract_pi_tables.py
"""

import importlib.util
import json
import shutil
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from fcom_utils import safe_name, load_toc, find_subchapters

FCOM_DIR = Path(".")
PI_DIR   = FCOM_DIR / "PI"

# Aliases : nom original lowercase -> nom canonique
# Ajouter ici tout nouveau renommage entre NG et MAX
ALIASES = {
    "stabilizer trim setting": "Stab Trim Setting",
    "go-around %n1":           "Go-around %N1",
}


def read_metadata(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return {}


def needs_update(metadata_path, fcom_dir):
    stored = read_metadata(metadata_path)
    if not stored:
        return True, "metadata.json absent ou vide."
    pdfs = sorted(Path(fcom_dir).glob("*.pdf"))
    if not pdfs:
        return False, "Aucun PDF trouve."
    current      = {p.name for p in pdfs}
    stored_names = set(stored.keys())
    if current != stored_names:
        added   = current - stored_names
        removed = stored_names - current
        reasons = []
        if added:
            reasons.append("nouveaux : " + ", ".join(added))
        if removed:
            reasons.append("supprimes : " + ", ".join(removed))
        return True, " | ".join(reasons)
    return False, ""


def write_aliases(pi_dir, aliases):
    """
    Ecrit pi_chapters_map.json avec les aliases uniquement.
    Appele en premier pour que find_subchapters puisse les lire.
    """
    pi_dir = Path(pi_dir)
    pi_dir.mkdir(parents=True, exist_ok=True)
    map_path = pi_dir / "pi_chapters_map.json"
    # Charger le fichier existant si present pour ne pas ecraser les subchapters
    existing = {}
    if map_path.exists():
        try:
            with open(map_path, "r", encoding="utf-8") as f:
                existing = json.load(f)
        except:
            pass
    existing["aliases"] = aliases
    with open(map_path, "w", encoding="utf-8") as f:
        json.dump(existing, f, ensure_ascii=False, indent=2)


def build_chapters_map(subchapters, aliases):
    """
    Construit le dictionnaire de correspondance complet :
    - subchapters : {nom_dossier -> nom_canonique}
    - aliases     : {nom_original_lowercase -> nom_canonique}
    """
    chapters_map = {}
    for original_name in subchapters:
        folder = safe_name(original_name)
        chapters_map[folder] = original_name

    # Ajouter les alias inverses
    for alias_lower, canonical in aliases.items():
        alias_folder = safe_name(alias_lower)
        chapters_map[alias_folder] = canonical

    return {
        "subchapters": chapters_map,
        "aliases":     aliases,
    }


def update_directories(pi_dir, subchapters, aliases):
    """
    Met a jour l'arborescence PI/ :
    - Cree les nouveaux dossiers manquants
    - Deplace le contenu des dossiers alias vers le dossier canonique
    - Supprime les dossiers qui n'existent plus dans le TOC
    - Met a jour pi_chapters_map.json complet
    """
    pi_dir = Path(pi_dir)
    pi_dir.mkdir(parents=True, exist_ok=True)

    # Dossiers canoniques attendus
    expected_folders = {safe_name(name) for name in subchapters}

    # Mapping alias_folder -> canonical_folder
    alias_map = {safe_name(alias): safe_name(canonical)
                 for alias, canonical in aliases.items()}

    # Lister les dossiers existants
    existing = [d for d in pi_dir.iterdir() if d.is_dir()]

    for folder in existing:
        name = folder.name

        if name in expected_folders:
            # Dossier correct — rien a faire
            continue

        if name in alias_map:
            # C'est un alias — deplacer le contenu vers le dossier canonique
            canonical_folder = pi_dir / alias_map[name]
            canonical_folder.mkdir(parents=True, exist_ok=True)
            for item in folder.iterdir():
                dest = canonical_folder / item.name
                if not dest.exists():
                    shutil.move(str(item), str(dest))
                    print("  Deplace : " + name + "/" + item.name +
                          " -> " + alias_map[name] + "/" + item.name)
                else:
                    print("  Conflit (conserve) : " + str(dest.relative_to(pi_dir)))
            shutil.rmtree(str(folder))
            print("  Supprime alias : " + name)

        else:
            # Dossier inconnu — supprimer avec contenu
            shutil.rmtree(str(folder))
            print("  Supprime (plus dans TOC) : " + name)

    # Creer les dossiers manquants
    for name in subchapters:
        folder = pi_dir / safe_name(name)
        if not folder.exists():
            folder.mkdir(parents=True, exist_ok=True)
            print("  Cree : " + safe_name(name))

    # Mettre a jour pi_chapters_map.json complet
    chapters_map = build_chapters_map(subchapters, aliases)
    map_path = pi_dir / "pi_chapters_map.json"
    with open(map_path, "w", encoding="utf-8") as f:
        json.dump(chapters_map, f, ensure_ascii=False, indent=2)

    print("Arborescence mise a jour : " + str(pi_dir))
    print("Correspondances          : " + str(map_path))

def save_pi_chapters(fcom_dir, subchapters):
    """
    Ecrit _pi_chapters dans fcom_data.json :
    {subchapter_safe_name: pi_chapter}
    """
    from fcom_utils import load_fcom_data, save_fcom_data
    fcom_data = load_fcom_data(fcom_dir)
    pi_chapters = {}
    for canonical, entries in subchapters.items():
        if entries:
            pi_chapters[safe_name(canonical)] = entries[0].get("pi_chapter", "General")
    fcom_data["_pi_chapters"] = pi_chapters
    save_fcom_data(fcom_data, fcom_dir)
    print("_pi_chapters mis a jour")

def run_subchapter_scripts(pi_dir, fcom_dir):
    pi_dir   = Path(pi_dir)
    fcom_dir = Path(fcom_dir)

    toc_data    = load_toc(fcom_dir)
    subchapters = find_subchapters(toc_data, pi_dir)

    scripts = sorted(pi_dir.glob("*/*.py"))
    if not scripts:
        print("Aucun script de sous-chapitre trouve dans PI/")
        return

    print("Execution de " + str(len(scripts)) + " script(s)...")
    for script_path in scripts:
        print("  " + str(script_path.relative_to(pi_dir)))
        try:
            spec   = importlib.util.spec_from_file_location(script_path.stem, script_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            if hasattr(module, "run"):
                module.run(fcom_dir, pi_dir, subchapters)
            else:
                print("    Pas de fonction run() dans " + script_path.name)
        except Exception as e:
            print("    Erreur : " + str(e))


def main(fcom_dir=None, pi_dir=None, run_scripts=False):
    fcom_dir  = Path(fcom_dir)  if fcom_dir  else FCOM_DIR
    pi_dir    = Path(pi_dir)    if pi_dir    else PI_DIR
    meta_path = fcom_dir / "metadata.json"
    toc_path  = fcom_dir / "toc.json"

    print("=" * 60)
    print("Performance Inflight - Arborescence et Extraction")
    print("=" * 60)

    update_needed, reason = needs_update(meta_path, fcom_dir)
    if update_needed:
        print("Mise a jour necessaire : " + reason)
    else:
        print("Versions a jour")

    if not toc_path.exists():
        print("toc.json introuvable : " + str(toc_path))
        print("Lancez d'abord main.py pour generer le TOC.")
        return None

    # Etape 1 : ecrire les aliases en premier
    print("Ecriture des aliases...")
    write_aliases(pi_dir, ALIASES)

    # Etape 2 : charger le TOC avec les aliases disponibles
    toc_data    = load_toc(fcom_dir)
    subchapters = find_subchapters(toc_data, pi_dir)

    print("Sous-chapitres PI : " + str(len(subchapters)))
    for name, entries in subchapters.items():
        n = len(entries)
        print("  " + safe_name(name) + "  (" + str(n) + " section" + ("s" if n > 1 else "") + ")")

    # Etape 3 : mettre a jour l'arborescence
    print("Mise a jour de l'arborescence...")
    update_directories(pi_dir, subchapters, ALIASES)

    save_pi_chapters(fcom_dir, subchapters)

    if run_scripts:
        run_subchapter_scripts(pi_dir, fcom_dir)

    return subchapters


if __name__ == "__main__":
    main(run_scripts=True)
