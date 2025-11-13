#!/QOpenSys/usr/bin/sh

# Chemins des fichiers et informations de connexion
LOCAL_DIR="Chemin dossier local"
REMOTE_USER="Nom d'utilisateur SFTP"
REMOTE_HOST="Nom du serveur SFTP"
SFTP_KEY="Chemin fichier id_rsa"
KNOWN_HOSTSfichier="Chemin fichier known_hosts"
LOG_FILE="Chemin fichier log"

# Initialiser le fichier de log pour garantir son existence
echo "Debut du traitement du $(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"

# Connexion SFTP pour lister les GUID disponibles et capturer tous les fichiers en une seule fois
RAW_FILE_LIST=$(/QOpenSys/bin/sftp -i "$SFTP_KEY" -oUserKnownHostsFile="$KNOWN_HOSTS" "$REMOTE_USER@$REMOTE_HOST" <<EOF 2>/dev/null
ls
quit
EOF
)

# Extraire uniquement les GUID des resultats de ls, en excluant les fichiers avec extension .xml
FILE_LIST=$(echo "$RAW_FILE_LIST" | grep -E '^\{[0-9A-Fa-f-]+\}' | grep -v '\.xml' | awk '{print $1}')

# Verifier si des dossiers GUID sont trouves
if [ -z "$FILE_LIST" ]; then
    echo "Aucun dossier trouve sur le serveur distant" >> "$LOG_FILE"
    exit 1
fi

# Parcourir chaque dossier GUID pour traiter les fichiers
for GUID_DIR in $FILE_LIST; 
do	
/QOpenSys/bin/sftp -i "$SFTP_KEY" -oUserKnownHostsFile="$KNOWN_HOSTS" "$REMOTE_USER@$REMOTE_HOST" <<EOF 2>/dev/null | grep "Fetching" >> "$LOG_FILE"
lcd "$LOCAL_DIR"
cd "$GUID_DIR"
get Nom*.xml
rm Nom*.xml
quit
EOF
done

# Message si aucun fichier recupere
if ! grep -q "Fetching" "$LOG_FILE"; then
    echo "Aucun fichier recupere" >> "$LOG_FILE"
fi

echo "Fin du traitement." >> "$LOG_FILE"
exit 0