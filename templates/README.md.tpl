# {{repo_name}}

Ce projet est une application de base utilisant une architecture Pub/Sub, générée automatiquement.

Il contient :
- Un orchestrateur central.
- Deux agents (workers) qui communiquent via des événements Pydantic.
- Une configuration complète pour le développement (venv, pip, Makefile, pre-commit).

## Installation

1.  **Clonez le dépôt :**
    ```sh
    git clone <url-du-repo>
    cd {{repo_name}}
    ```

2.  **Installez l'environnement et les dépendances :**
    La commande `make setup` s'occupe de tout.
    ```sh
    make setup
    ```

## Utilisation

1.  **Démarrez le serveur Pub/Sub (dans un terminal séparé) :**
    ```sh
    docker compose up
    ```

2.  **Lancez l'application client :**
    ```sh
    make run
    ```