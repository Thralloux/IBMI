# AS400 AI Assistant
![Python](https://img.shields.io/badge/Python-3.9.21-blue)
![AS400](https://img.shields.io/badge/AS400-V7R3-orange)

## Description
Ce projet permet d'utiliser un assistant IA via l'API Hugging Face, fonctionnant sur un environnement AS400.  
Il simule un type de ChatGPT adapté à l’AS400.  

**Principe :**
- La **question et le script** sont stockés dans une table AS400 et peuvent être modifiés. 
- Toute modification permet de **reconstruire automatiquement le script Python** dans l’IFS (Integrated File System).  
- La **réponse** est générée par le script Python, qui utilise l'API Hugging Face et enregistre les résultats dans un fichier CSV.
  
## Prérequis
- Python 3.9.21  
- AS400 en version V7R3  
-
## Installation et utilisation
1. Copier le script Python dans la table AS400 :
```sql
INSERT INTO nbouvier.ask (FLD001)
SELECT LINE
FROM TABLE(QSYS2.IFS_READ('/home/NBOUVIER/python2.py'));

2. Créer un environnement personnelle 
python3 -m venv my_env 
