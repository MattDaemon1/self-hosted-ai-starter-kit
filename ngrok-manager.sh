#!/bin/bash

# Script de gestion ngrok pour n8n AI Starter Kit
# Usage: ./ngrok-manager.sh [start|stop|status|logs|urls]

set -e

COMPOSE_FILE="docker-compose.yml"
NGROK_CONTAINER="ngrok"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage coloré
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_title() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Vérifier si Docker est en cours d'exécution
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker n'est pas en cours d'exécution ou n'est pas accessible"
        exit 1
    fi
}

# Vérifier si le service ngrok existe
check_ngrok_service() {
    if ! docker-compose -f "$COMPOSE_FILE" config --services | grep -q "^ngrok$"; then
        print_error "Le service ngrok n'est pas défini dans $COMPOSE_FILE"
        exit 1
    fi
}

# Démarrer ngrok
start_ngrok() {
    print_title "Démarrage de ngrok"
    
    # Vérifier si NGROK_AUTHTOKEN est défini
    if [ -z "$(grep '^NGROK_AUTHTOKEN=' .env | cut -d'=' -f2)" ]; then
        print_warning "NGROK_AUTHTOKEN n'est pas défini dans .env"
        print_warning "Les tunnels fonctionneront en mode limité (2h max)"
        echo
        print_status "Pour obtenir un token gratuit :"
        print_status "1. Créez un compte sur https://ngrok.com"
        print_status "2. Récupérez votre token : https://dashboard.ngrok.com/get-started/your-authtoken"
        print_status "3. Ajoutez-le dans .env : NGROK_AUTHTOKEN=votre_token"
        echo
    fi
    
    # Démarrer le service ngrok
    docker-compose up -d ngrok
    
    print_status "ngrok démarré avec succès !"
    
    # Attendre que ngrok soit prêt
    print_status "Attente de l'initialisation de ngrok..."
    sleep 5
    
    # Afficher les URLs
    show_urls
}

# Arrêter ngrok
stop_ngrok() {
    print_title "Arrêt de ngrok"
    docker-compose stop ngrok
    docker-compose rm -f ngrok
    print_status "ngrok arrêté avec succès !"
}

# Statut de ngrok
status_ngrok() {
    print_title "Statut de ngrok"
    
    if docker-compose ps ngrok | grep -q "Up"; then
        print_status "ngrok est en cours d'exécution"
        
        # Afficher les informations du conteneur
        echo
        docker-compose ps ngrok
        
        # Afficher les URLs si disponibles
        echo
        show_urls
    else
        print_warning "ngrok n'est pas en cours d'exécution"
    fi
}

# Logs de ngrok
logs_ngrok() {
    print_title "Logs de ngrok"
    docker-compose logs -f ngrok
}

# Afficher les URLs des tunnels
show_urls() {
    print_title "URLs des tunnels ngrok"
    
    # Vérifier si ngrok est accessible
    if ! curl -s http://localhost:4040/api/tunnels >/dev/null 2>&1; then
        print_error "Impossible d'accéder à l'API ngrok sur le port 4040"
        print_error "Vérifiez que le service ngrok est démarré"
        return 1
    fi
    
    # Récupérer et afficher les tunnels
    TUNNELS=$(curl -s http://localhost:4040/api/tunnels)
    
    if echo "$TUNNELS" | jq -e '.tunnels | length > 0' >/dev/null 2>&1; then
        echo "$TUNNELS" | jq -r '.tunnels[] | "🌐 \(.name): \(.public_url) -> \(.config.addr)"'
        echo
        print_status "Interface web ngrok : http://localhost:4040"
        print_status "Métriques ngrok : http://localhost:9090"
    else
        print_warning "Aucun tunnel actif trouvé"
    fi
}

# Redémarrer ngrok
restart_ngrok() {
    print_title "Redémarrage de ngrok"
    stop_ngrok
    sleep 2
    start_ngrok
}

# Configuration interactive
configure_ngrok() {
    print_title "Configuration ngrok"
    
    echo "Configuration de votre token ngrok :"
    echo "1. Rendez-vous sur https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "2. Copiez votre token d'authentification"
    echo
    read -p "Entrez votre NGROK_AUTHTOKEN (ou Entrée pour ignorer) : " token
    
    if [ -n "$token" ]; then
        # Mettre à jour le fichier .env
        if grep -q "^NGROK_AUTHTOKEN=" .env; then
            sed -i "s/^NGROK_AUTHTOKEN=.*/NGROK_AUTHTOKEN=$token/" .env
        else
            echo "NGROK_AUTHTOKEN=$token" >> .env
        fi
        print_status "Token sauvegardé dans .env"
    fi
    
    echo
    echo "Souhaitez-vous configurer des domaines personnalisés ? (nécessite un compte payant)"
    read -p "Domaine pour n8n (ex: mon-n8n.ngrok.io) : " n8n_domain
    
    if [ -n "$n8n_domain" ]; then
        if grep -q "^NGROK_DOMAIN=" .env; then
            sed -i "s/^NGROK_DOMAIN=.*/NGROK_DOMAIN=$n8n_domain/" .env
        else
            echo "NGROK_DOMAIN=$n8n_domain" >> .env
        fi
        print_status "Domaine n8n configuré : $n8n_domain"
    fi
}

# Menu d'aide
show_help() {
    print_title "ngrok Manager - Aide"
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commandes disponibles :"
    echo "  start      Démarrer ngrok et créer les tunnels"
    echo "  stop       Arrêter ngrok"
    echo "  restart    Redémarrer ngrok"
    echo "  status     Afficher le statut de ngrok"
    echo "  logs       Afficher les logs de ngrok"
    echo "  urls       Afficher les URLs des tunnels"
    echo "  config     Configuration interactive"
    echo "  help       Afficher cette aide"
    echo
    echo "Exemples :"
    echo "  $0 start           # Démarrer ngrok"
    echo "  $0 urls            # Voir les URLs publiques"
    echo "  $0 logs            # Suivre les logs"
}

# Main
main() {
    check_docker
    check_ngrok_service
    
    case "${1:-help}" in
        start)
            start_ngrok
            ;;
        stop)
            stop_ngrok
            ;;
        restart)
            restart_ngrok
            ;;
        status)
            status_ngrok
            ;;
        logs)
            logs_ngrok
            ;;
        urls)
            show_urls
            ;;
        config)
            configure_ngrok
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Commande inconnue: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"
