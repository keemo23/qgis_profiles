# Profils QGIS déployés à EP Loire

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/eptb-loire/qgis_profiles/main.svg)](https://results.pre-commit.ci/latest/github/eptb-loire/qgis_profiles/main)

----

## Démarrage rapide

### Prérequis

- Python 3.10+
- connexion réseau autorisée sur :
  - github.com
  - plugins.qgis.org

### Cloner ou télécharger ce dépôt

```sh
git clone https://github.com/eptb-loire/qgis_profiles.git ep-loire-profils-qgis
cd ep-loire-profils-qgis
```

### Installer QDT

> De préférence dans un environnement virtuel

```sh
python -m pip install -U pip setuptools wheel
pip install -U -r requirements.txt
```

### Exécuter QDT avec un scénario de ce dépôt

```sh
qgis-deployment-toolbelt -v -s qdt_scenarii/scenario.qdt.yml
```

----

## Guide de contribution

Création d'un environnement virtuel Python :

```sh
python -m venv .venv
# Sur Windows :
# py -3 -m venv .venv
```

Activer l'environnement virtuel :

```sh
. .venv/bin/activate
# Sur Windows :
# .venv/Scripts/activate
```

Installation des dépendances :

```sh
python -m pip install -U pip setuptools wheel
pip install -U -r requirements.txt
pre-commit install
```
