# Système de Mise à Jour Automatique N8N

## Configuration Actuelle

### Watchtower (Mise à Jour Automatique)
- **Service** : `watchtower`
- **Intervalle** : Toutes les 24 heures (configurable via `WATCHTOWER_POLL_INTERVAL` dans `.env`)
- **Mode** : Surveillance uniquement des conteneurs avec les labels appropriés
- **Nettoyage** : Suppression automatique des anciennes images après mise à jour

### Services Surveillés
- **n8n** : Mise à jour automatique activée via les labels
- **Autres services** : Non surveillés par défaut pour éviter les interruptions

## Configuration dans .env

```env
# Configuration de mise à jour automatique
WATCHTOWER_POLL_INTERVAL=86400  # Vérification toutes les 24h
WATCHTOWER_CLEANUP=true
WATCHTOWER_INCLUDE_STOPPED=true
```

## Commandes Utiles

### Mise à jour manuelle de n8n
```bash
# Utiliser le script automatique
./update-n8n.bat

# Ou manuellement
docker-compose stop n8n
docker pull n8nio/n8n:latest
docker-compose up -d n8n
```

### Forcer une vérification Watchtower
```bash
docker exec watchtower watchtower --run-once --label-enable
```

### Vérifier les logs de mise à jour
```bash
docker logs watchtower
```

### Désactiver temporairement les mises à jour automatiques
```bash
docker-compose stop watchtower
```

## Sécurité et Recommandations

1. **Sauvegarde** : Toujours sauvegarder les données avant une mise à jour majeure
2. **Test** : Les mises à jour automatiques utilisent la version `latest` stable
3. **Monitoring** : Surveillez les logs après chaque mise à jour
4. **Rollback** : En cas de problème, utilisez `docker-compose down && docker-compose up -d`

## Personnalisation

### Changer l'intervalle de vérification
Modifiez `WATCHTOWER_POLL_INTERVAL` dans `.env` :
- 3600 = 1 heure
- 86400 = 24 heures  
- 604800 = 1 semaine

### Ajouter d'autres services à la surveillance
Ajoutez ces labels à n'importe quel service dans `docker-compose.yml` :
```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=true"
  - "com.centurylinklabs.watchtower.monitor-only=false"
```

### Notifications (optionnel)
Pour recevoir des notifications de mise à jour, ajoutez à l'environnement Watchtower :
```yaml
- WATCHTOWER_NOTIFICATIONS=slack://token@channel
```
