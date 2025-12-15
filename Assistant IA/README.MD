# AS400 AI Assistant
![Python](https://img.shields.io/badge/Python-3.9.21-blue)
![AS400](https://img.shields.io/badge/AS400-V7R3-orange)

## Description
Ce projet permet d'utiliser un assistant IA via l'API Hugging Face, fonctionnant sur un environnement AS400.  
Il simule un type de ChatGPT adapté à l’AS400 et permet de réaliser de l'analyse de donnée sur une table spécifique.  

**Principe :**
- La **question et le script** sont stockés dans une table AS400 et peuvent être modifiés. 
- Toute modification permet de **reconstruire automatiquement le script Python** dans l’IFS (Integrated File System).  
- La **réponse** est générée par le script Python, qui utilise l'API Hugging Face et enregistre les résultats dans un fichier CSV.

---

## Installation et utilisation
1. **Insérer le fichier Python** dans son dossier IFS.  

2. Copier le script Python dans la table AS400 :
```sql
INSERT INTO nbouvier.ask (FLD001)
SELECT LINE
FROM TABLE(QSYS2.IFS_READ('/home/NBOUVIER/python2.py'));
```

3. **Se connecter via QSH** et effectuer les commandes suivantes pour créer un environnement virtuel et installer les bibliothèques nécessaires :  
```sh
PATH=/QOpenSys/pkgs/bin:$PATH
python3 --version
pip3 --version
python3 -m venv my_env
source my_env/bin/activate
```
---

## Visuelle

<img width="1230" height="888" alt="Image" src="https://github.com/user-attachments/assets/ff6f3e09-c085-4360-8542-43b08b67c325" />
<img width="1262" height="833" alt="Image" src="https://github.com/user-attachments/assets/07e21e5e-98bf-42ed-9e1d-a488a5e1e2db" />
<img width="1280" height="928" alt="Image" src="https://github.com/user-attachments/assets/236077ba-5a46-40e8-ac89-b1feeb4d499a" />
