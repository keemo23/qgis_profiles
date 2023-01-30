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
git clone https://github.com/geotribu/profils-qgis.git geotribu-profils-qgis
cd geotribu-profils-qgis
```

### Installer QDT

> De préférence dans un environnement virtuel

```sh
python -m pip install -U pip setuptools wheel
pip install -U -r requirements.txt
```

### Exécuter QDT avec le scénario Geotribu

```sh
qgis-deployment-toolbelt -v -s qdt/scenario.qdt.yml
```

----

## Développement

- installer pre-commit et les git hooks
