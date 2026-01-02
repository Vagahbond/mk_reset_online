#!/bin/bash
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ Erreur : Fichier .env introuvable."
    exit 1
fi

DB_USER=${POSTGRES_USER}
DB_PASSWORD=${POSTGRES_PASSWORD}
DB_NAME=${POSTGRES_DB}
SERVICE_DB="db" 
BACKUP_DIR="./backups"

save() {
    mkdir -p $BACKUP_DIR
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    FILENAME="$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

    echo "💾 Sauvegarde en cours..."
    
    docker-compose exec -T -e PGPASSWORD=$DB_PASSWORD $SERVICE_DB pg_dump -U $DB_USER --clean $DB_NAME | gzip > $FILENAME

    if [ $? -eq 0 ]; then
        echo "✅ Succès ! Fichier créé : $FILENAME"
        find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +30 -delete
    else
        echo "❌ Erreur lors de la sauvegarde."
        rm -f $FILENAME
    fi
}

restore() {
    SEARCH_TERM=$1

    if [ -z "$SEARCH_TERM" ]; then
        echo "❌ Erreur : Spécifiez une date (ex: ./backup.sh restore 2025)."
        exit 1
    fi

    MATCHING_FILE=$(find $BACKUP_DIR -name "*$SEARCH_TERM*.sql.gz" | sort | tail -n 1)

    if [ -z "$MATCHING_FILE" ]; then
        echo "❌ Aucun fichier trouvé pour : '$SEARCH_TERM'"
        exit 1
    fi

    echo "⚠️  ATTENTION : Restauration de $MATCHING_FILE"
    echo "⚠️  La base de données actuelle sera ENTIÈREMENT EFFACÉE."
    read -p "Confirmer ? (oui/non) : " CONFIRM

    if [[ "$CONFIRM" != "oui" ]]; then
        echo "Annulé."
        exit 0
    fi

    echo "🛑 Arrêt du site (Frontend & Backend)..."
    docker-compose stop frontend backend

    echo "🧹 Nettoyage et Restauration de la base de données..."
    
    zcat $MATCHING_FILE | docker-compose exec -T -e PGPASSWORD=$DB_PASSWORD $SERVICE_DB psql -U $DB_USER -d $DB_NAME

    if [ $? -eq 0 ]; then
        echo "✅ Restauration réussie !"
    else
        echo "❌ Erreur pendant la restauration."
    fi

    echo "▶️  Redémarrage du site..."
    docker-compose start frontend backend
}

case "$1" in
    save)
        save
        ;;
    restore)
        restore "$2"
        ;;
    *)
        echo "Usage : ./backup.sh [save | restore <date>]"
        exit 1
        ;;
esac
