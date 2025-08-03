# Configuration ngrok pour n8n AI Starter Kit

Ce guide vous explique comment utiliser ngrok avec votre stack n8n pour exposer vos services publiquement.

## 🚀 Démarrage rapide

### 1. Configuration initiale

```powershell
# Configurer votre token ngrok (optionnel mais recommandé)
./ngrok-manager.ps1 config

# Démarrer ngrok
./ngrok-manager.ps1 start

# Voir les URLs publiques
./ngrok-manager.ps1 urls
```

### 2. URLs générées

Une fois ngrok démarré, vous aurez accès à :

- **n8n Interface** : `https://xxxx-xxx-xxx-xxx.ngrok.io`
- **Ollama API** : `https://yyyy-yyy-yyy-yyy.ngrok.io` (avec auth)
- **Qdrant API** : `https://zzzz-zzz-zzz-zzz.ngrok.io` (avec auth)
- **Interface ngrok** : `http://localhost:4040`

## ⚙️ Configuration

### Variables d'environnement (.env)

```bash
# Token d'authentification ngrok (recommandé)
NGROK_AUTHTOKEN=votre_token_ici

# Domaines personnalisés (compte payant requis)
NGROK_DOMAIN=mon-n8n.ngrok.io
NGROK_HTTPS_DOMAIN=secure-n8n.ngrok.io
NGROK_OLLAMA_DOMAIN=ollama.ngrok.io
NGROK_QDRANT_DOMAIN=qdrant.ngrok.io

# Authentification pour les API (format: username:password)
NGROK_OLLAMA_AUTH=admin:secret123
NGROK_QDRANT_AUTH=admin:secret123
```

### Obtenir un token ngrok

1. **Créer un compte** : [ngrok.com](https://ngrok.com)
2. **Récupérer le token** : [Dashboard ngrok](https://dashboard.ngrok.com/get-started/your-authtoken)
3. **Ajouter dans .env** : `NGROK_AUTHTOKEN=votre_token`

### Configuration avancée (ngrok.yml)

Le fichier `ngrok.yml` contient la configuration des tunnels :

```yaml
version: "2"
authtoken: ${NGROK_AUTHTOKEN}

tunnels:
  n8n-http:
    addr: caddy:80
    proto: http
    inspect: true
    
  n8n-https:
    addr: caddy:443
    proto: http
    bind_tls: true
```

## 🛠️ Commandes disponibles

### Script PowerShell (Windows)

```powershell
# Démarrer ngrok
./ngrok-manager.ps1 start

# Arrêter ngrok
./ngrok-manager.ps1 stop

# Statut et URLs
./ngrok-manager.ps1 status
./ngrok-manager.ps1 urls

# Logs en temps réel
./ngrok-manager.ps1 logs

# Configuration interactive
./ngrok-manager.ps1 config

# Redémarrer
./ngrok-manager.ps1 restart
```

### Script Bash (Linux/Mac)

```bash
# Rendre exécutable
chmod +x ngrok-manager.sh

# Utilisation identique
./ngrok-manager.sh start
./ngrok-manager.sh urls
```

### Commandes Docker directes

```powershell
# Démarrer uniquement ngrok
docker-compose up -d ngrok

# Voir les logs
docker-compose logs -f ngrok

# Arrêter ngrok
docker-compose stop ngrok
```

## 🔒 Sécurité

### Authentification HTTP

Les services Ollama et Qdrant sont protégés par authentification HTTP :

```bash
# Configuration dans .env
NGROK_OLLAMA_AUTH=admin:motdepasse123
NGROK_QDRANT_AUTH=admin:motdepasse456
```

### Accès aux APIs protégées

```bash
# Exemple d'accès à Ollama via ngrok
curl -u admin:motdepasse123 https://votre-ollama.ngrok.io/api/generate

# Exemple d'accès à Qdrant
curl -u admin:motdepasse456 https://votre-qdrant.ngrok.io/collections
```

### Recommandations de sécurité

1. **Utilisez des mots de passe forts** pour l'authentification HTTP
2. **Surveillez les logs** ngrok pour détecter les accès suspects
3. **Limitez l'exposition** aux services nécessaires uniquement
4. **Utilisez HTTPS** quand possible

## 📊 Monitoring

### Interface web ngrok

Accédez à `http://localhost:4040` pour :

- Voir tous les tunnels actifs
- Analyser le trafic HTTP
- Inspecter les requêtes/réponses
- Voir les statistiques d'utilisation

### Métriques

ngrok expose des métriques sur `http://localhost:9090` :

- Nombre de connexions
- Bande passante utilisée
- Latence des tunnels
- Erreurs de connexion

### Logs

```powershell
# Logs du service ngrok
./ngrok-manager.ps1 logs

# Logs Docker
docker-compose logs ngrok

# Logs en temps réel
docker-compose logs -f ngrok
```

## 🌍 Utilisation avec Telegram

Pour utiliser n8n avec Telegram via ngrok :

1. **Démarrer ngrok** : `./ngrok-manager.ps1 start`
2. **Récupérer l'URL** : `./ngrok-manager.ps1 urls`
3. **Configurer le webhook Telegram** avec l'URL ngrok
4. **Tester le bot** Telegram

Exemple d'URL webhook :
```
https://abcd-12-34-56-78.ngrok.io/webhook/telegram
```

## 🔧 Dépannage

### Problèmes courants

**Erreur "tunnel session failed"**
```bash
# Vérifier le token
grep NGROK_AUTHTOKEN .env

# Redémarrer ngrok
./ngrok-manager.ps1 restart
```

**Port 4040 déjà utilisé**
```bash
# Arrêter les processus ngrok existants
docker-compose stop ngrok
docker container prune -f
```

**Timeout des tunnels**
```bash
# Les comptes gratuits ont une limite de 2h
# Redémarrer pour renouveler
./ngrok-manager.ps1 restart
```

**Connexion refused**
```bash
# Vérifier que les services sont démarrés
docker-compose ps

# Vérifier les logs
./ngrok-manager.ps1 logs
```

### Vérification de la configuration

```powershell
# Tester la connectivité interne
docker-compose exec ngrok ping caddy

# Vérifier la configuration ngrok
docker-compose exec ngrok cat /etc/ngrok.yml

# Tester l'API ngrok
curl http://localhost:4040/api/tunnels
```

## 💰 Plans ngrok

### Gratuit
- 1 processus ngrok en ligne
- 40 connexions/minute
- Tunnels temporaires (2h max)
- Sous-domaines aléatoires

### Payant (dès $8/mois)
- Tunnels persistants
- Domaines personnalisés
- Plus de connexions simultanées
- Support prioritaire

### Recommandation

Pour un usage professionnel ou de production, un compte payant est recommandé pour la stabilité et les fonctionnalités avancées.

## 📚 Ressources

- [Documentation ngrok](https://ngrok.com/docs)
- [Dashboard ngrok](https://dashboard.ngrok.com)
- [n8n Webhooks](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [Telegram Bot API](https://core.telegram.org/bots/api)

---

✅ **ngrok est maintenant configuré !** Vos services n8n sont accessibles publiquement via des URLs sécurisées.
