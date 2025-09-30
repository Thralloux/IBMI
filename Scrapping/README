# Scrapping AS400

![Python](https://img.shields.io/badge/Python-3.9-blue)
![AS400](https://img.shields.io/badge/AS400-V7R3-orange)
![BeautifulSoup](https://img.shields.io/badge/Library-BeautifulSoup4-green)

## Description

Ce projet permet de récupérer des données depuis différents sites web et de les insérer dans des fichiers CSV sur un environnement AS400.  
Il utilise Python avec les bibliothèques `requests` et `BeautifulSoup` pour effectuer le scrapping.

**Principe de fonctionnement :**

- Les scripts Python sont stockés dans l’IFS (Integrated File System) de l’AS400.  
- Les données récupérées sont insérées dans des tables AS400 spécifiques.  
- Les résultats sont exportés au format CSV pour exploitation ou reporting.

---

## Prérequis

- Python 3.x sur l’AS400  
- Bibliothèques Python : `requests`, `beautifulsoup4`  
- Accès à l’IFS de l’AS400  

---

## Installation et utilisation

1. **Insérer le fichier Python** dans son dossier IFS.  

2. **Se connecter via QSH** et effectuer les commandes suivantes pour créer un environnement virtuel et installer les bibliothèques nécessaires :  
```sh
PATH=/QOpenSys/pkgs/bin:$PATH
python3 --version
pip3 --version
python3 -m venv my_env
source my_env/bin/activate
pip install requests beautifulsoup4

3. Création des tables AS400 pour stocker les données scrappées :
```sql
CREATE TABLE METEO (METEO_DATA CHAR(150));
CREATE TABLE BOUVIER.Actu (ACTU_DATA CHAR(150));
CREATE TABLE BOUVIER.Sport (ACTU_DATA CHAR(150));
