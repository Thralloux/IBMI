import requests
from bs4 import BeautifulSoup
import csv

HEADERS = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}

def extract_and_save_data(url, output_file, heure_selector, content_selector, delimiter=':', encoding='utf-8-sig'):
    try:
        response = requests.get(url, headers=HEADERS)
        soup = BeautifulSoup(response.text, 'html.parser')

        heures = [item.text.strip() for item in soup.select(heure_selector)]
        contenus = [item.text.strip().replace("’", "'") for item in soup.select(content_selector)]

        data = list(zip(heures, contenus))

        with open(output_file, mode='w', newline='', encoding=encoding) as file:
            writer = csv.writer(file, delimiter=delimiter)
            writer.writerows(data)

    except Exception:
        pass

# Génération des trois fichiers CSV
extract_and_save_data(
    url="https://www.lemonde.fr/",
    output_file="lemonde_data.csv",
    heure_selector="div.New__time",
    content_selector="div.New__content"
)

extract_and_save_data(
    url="https://www.infoclimat.fr/observations-meteo/temps-reel/montpellier-frejorgues/07643.html",
    output_file="infoclimat_data.csv",
    heure_selector="th[style='font-size:1.25em'] span.tipsy-trigger",
    content_selector="span[style='font-weight:bold;display:inline-block;font-size:16px']"
)

extract_and_save_data(
    url="https://www.lequipe.fr/",
    output_file="lequipe_data.csv",
    heure_selector="span.ChronoItem__time",
    content_selector="div.ChronoItem__summary"
)

