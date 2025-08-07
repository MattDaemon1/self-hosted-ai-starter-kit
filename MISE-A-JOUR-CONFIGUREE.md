# 🔄 Configuration de Mise à Jour Automatique N8N Terminée

## ✅ Ce qui a été configuré :

### 1. Service Watchtower
- **Image** : `containrrr/watchtower:latest`
- **Fonction** : Surveille et met à jour automatiquement n8n
- **Intervalle** : Toutes les 24 heures (configurable)
- **Mode** : Label-based (ne met à jour que les services marqués)

### 2. Labels N8N
- Service n8n marqué pour mise à jour automatique
- Configuration sélective pour éviter les mises à jour non désirées

### 3. Variables d'environnement (.env)
```env
WATCHTOWER_POLL_INTERVAL=86400  # 24 heures
WATCHTOWER_CLEANUP=true
WATCHTOWER_INCLUDE_STOPPED=true
```

### 4. Scripts utilitaires
- `update-n8n.bat` : Mise à jour manuelle de n8n
- `UPDATE-SYSTEM.md` : Documentation complète

## 🎯 Fonctionnement :

1. **Automatique** : Watchtower vérifie les mises à jour toutes les 24h
2. **Sélectif** : Seul n8n sera mis à jour automatiquement
3. **Sécurisé** : Nettoyage automatique des anciennes images
4. **Contrôlable** : Possibilité de désactiver temporairement

## 📋 Commandes rapides :

```bash
# Vérifier le statut
docker-compose ps

# Voir les logs de mise à jour
docker logs watchtower

# Mise à jour manuelle
./update-n8n.bat

# Désactiver temporairement
docker-compose stop watchtower

# Réactiver
docker-compose up -d watchtower
```

## 🚀 Prochaine vérification automatique :
**Demain à la même heure** (24h après le démarrage)

Le système est maintenant opérationnel et maintiendra votre installation n8n à jour automatiquement ! 🎉
