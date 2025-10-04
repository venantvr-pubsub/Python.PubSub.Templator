import sys
from pathlib import Path

import yaml  # Python.PubSub.Risk

CONFIG_FILE = Path("structure.yaml")
TEMPLATE_DIR = Path("templates")


def load_config(config_path: Path) -> dict:
    """Charge la configuration depuis le fichier YAML."""
    if not config_path.exists():
        print(f"❌ ERREUR: Fichier de configuration '{config_path}' introuvable.")
        sys.exit(1)
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"❌ ERREUR: Le fichier YAML '{config_path}' est mal formaté.\n{e}")
        sys.exit(1)


def render_template(content: str, context: dict) -> str:
    """Remplace les placeholders dans une chaîne de caractères."""
    for key, value in context.items():
        content = content.replace(f"{{{{{key}}}}}", value)
    return content


def main():
    """Fonction principale du script de bootstrap."""
    print("--- Générateur de Projet Pub/Sub ---")

    # 1. Charger la configuration
    config = load_config(CONFIG_FILE)

    # 2. Obtenir le nom du projet
    try:
        repo_name = input("Quel est le nom du nouveau projet (ex: mon-super-projet) ? ")
        if not repo_name:
            print("\n❌ Le nom du projet ne peut pas être vide. Abandon.")
            return
    except KeyboardInterrupt:
        print("\n👋 Opération annulée.")
        return

    # 3. Préparer le contexte et les chemins
    root_dir = Path("..") / repo_name
    if root_dir.exists():
        print(f"\n❌ Le dossier '{repo_name}' existe déjà dans le répertoire parent. Abandon.")
        return

    project_name_py = repo_name.replace("-", "_").replace(".", "_").lower()
    context = {
        "repo_name": repo_name,
        "project_name_py": project_name_py
    }

    print(f"\n🚀 Création du projet '{repo_name}' dans le dossier parent...")
    root_dir.mkdir()

    # 4. Créer les répertoires
    print("\n📁 Création de l'arborescence...")
    for dir_tpl in config.get("directories", []):
        dir_path_str = render_template(dir_tpl, context)
        dir_path = root_dir / dir_path_str
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"   -> Créé : {dir_path}/")

    # 5. Créer les fichiers à partir des gabarits
    print("\n📝 Écriture des fichiers...")
    for dest_tpl, template_name in config.get("files", {}).items():
        dest_path_str = render_template(dest_tpl, context)
        dest_path = root_dir / dest_path_str

        template_path = TEMPLATE_DIR / template_name
        if not template_path.exists():
            print(f"   -> ⚠️ AVERTISSEMENT: Gabarit '{template_path}' introuvable. Fichier ignoré.")
            continue

        content = template_path.read_text(encoding="utf-8")
        rendered_content = render_template(content, context)

        dest_path.write_text(rendered_content, encoding="utf-8")
        print(f"   -> Créé : {dest_path}")

    # 6. Message final
    print("\n" + "=" * 60)
    print(f"🎉 Projet '{repo_name}' créé avec succès !")
    print("=" * 60)
    print("\nProchaines étapes :")
    print(f"   1. `cd ../{repo_name}`")
    print("   2. `git init && git add . && git commit -m \"Initial commit\"`")
    print("   3. `docker compose up` (dans un terminal)")
    print("   4. `make setup` (dans un autre terminal)")
    print("   5. `make run`")
    print("\nBon codage ! ✨")


if __name__ == "__main__":
    main()
