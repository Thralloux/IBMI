import os, csv, requests

API_URL = "https://router.huggingface.co/v1/chat/completions"
HEADERS = {"Authorization": f"Bearer {os.environ['HF_TOKEN']}", "Content-Type": "application/json"}
MODEL = "meta-llama/Llama-3.3-70B-Instruct:cerebras"

def llm(query):
    try:
        r = requests.post(API_URL, headers=HEADERS, json={"messages":[{"role":"user","content":query}], "model":MODEL})
        r.raise_for_status()
        text = r.json()["choices"][0]["message"]["content"].strip()
    except Exception as e:
        text = f"Erreur: {e}"

    with open("response.csv", "w", newline='', encoding="utf-8-sig") as f:
        csv.writer(f, delimiter=";").writerow([text])
    return text

# Lecture CSV externe (IFS)
with open("/home/NBOUVIER/table.csv", newline='', encoding="utf-8-sig") as f:
    table_data = "\n".join(" | ".join(row) for row in csv.reader(f, delimiter="\t"))

llm(f"{table_data} test")
