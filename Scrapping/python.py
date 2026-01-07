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

        if heure_selector.strip() == content_selector.strip():
            data = [[c] for c in contenus]
        else:
            data = list(zip(heures, contenus))

        with open(output_file, mode='w', newline='', encoding=encoding) as file:
            writer = csv.writer(file, delimiter=delimiter)
            writer.writerows(data)

    except Exception:
        pass

# Infoclimat
extract_and_save_data(
    url="https://www.infoclimat.fr/observations-meteo/temps-reel/montpellier-frejorgues/07643.html",
    output_file="infoclimat_data.csv",
    heure_selector="th[style='font-size:1.25em'] span.tipsy-trigger",
    content_selector="span[style='font-weight:bold;display:inline-block;font-size:16px']"
)
# Le monde
extract_and_save_data(
    url="https://www.lemonde.fr/",
    output_file="lemonde_data.csv",
    heure_selector=".ds-en-continu-popin__card-link__time",
    content_selector=".ds-en-continu-popin__card-link__content--title"
)
# L'équipe
extract_and_save_data(
    url="https://www.lequipe.fr/",
    output_file="lequipe_data.csv",
    heure_selector="span.ChronoItem__time",
    content_selector="div.ChronoItem__summary"
)
# Télérama
extract_and_save_data(
    url="https://television.telerama.fr/",
    output_file="telerama_data.csv",
    heure_selector="section.js-tv-grid-card-prime.tv-grid__card.tv-grid__card--first .tv-grid__card-bottom-first",
    content_selector="section.js-tv-grid-card-prime.tv-grid__card.tv-grid__card--first h3"
)
# france Inter
extract_and_save_data(
    url="https://www.radiofrance.fr/franceinter/grille-programmes/",
    output_file="radio_data.csv",
    heure_selector="time.qg-tx4",
    content_selector="p > span > a.expandToParent"
)
# Megarama
extract_and_save_data(
    url="https://montpellier.megarama.fr/FR/43/horaires-cinema-megarama-montpellier.html",
    output_file="cinema_data.csv",
    heure_selector="#containerHoraires .zoneAfficheInfo .afficheTitre.fittext1",
    content_selector="#containerHoraires .zoneAfficheInfo .afficheTitre.fittext1"
)
