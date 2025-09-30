
import os                                                                                                                                             
import csv                                                                                                                                            
import requests                                                                                                                                       
                                                                                                                                                      
API_URL = "https://router.huggingface.co/v1/chat/completions"                                                                                         
                                                                                                                                                      
# Utilise la variable d'environnement HF_TOKEN                                                                                                        
headers = {                                                                                                                                           
    "Authorization": f"Bearer {os.environ['HF_TOKEN']}",                                                                                              
    "Content-Type": "application/json"                                                                                                                
}                                                                                                                                                     
                                                                                                                                                      
def llm(query):                                                                                                                                       
    payload = {                                                                                                                                       
        "messages": [{"role": "user", "content": query}],                                                                                             
        "model": "meta-llama/Llama-3.1-70B-Instruct:fireworks-ai"                                                                                     
    }                                                                                                                                                 
                                                                                                                                                      
    try:                                                                                                                                              
        response = requests.post(API_URL, headers=headers, json=payload)                                                                              
        response.raise_for_status()                                                                                                                   
        data = response.json()                                                                                                                        
        response_text = data["choices"][0]["message"]["content"].strip().replace("\n", " ").replace("\r", " ")                                        
    except requests.exceptions.HTTPError as e:                                                                                                        
        response_text = f"Erreur HTTP: {e} - {response.text}"                                                                                         
    except Exception as e:                                                                                                                            
        response_text = f"Erreur lors de la requête ou parsing JSON: {e}"                                                                             
                                                                                                                                                      
    # Écriture dans CSV                                                                                                                               
    csv_path = os.path.join(os.getcwd(), "response.csv")                                                                                              
    with open(csv_path, mode='w', newline='', encoding='utf-8-sig') as file:                                                                          
        writer = csv.writer(file, delimiter=';')                                                                                                      
        writer.writerow([response_text])                                                                                                              
                                                                                                                                                      
    print("Réponse:", response_text)                                                                                                                  
    print(f"CSV créé ici : {csv_path}")                                                                                                               
                                                                                                                                                      
# Test                                                                                                                                                
llm('Question ici')                                                                                                       
