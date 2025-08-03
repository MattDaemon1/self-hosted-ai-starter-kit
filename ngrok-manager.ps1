# Script PowerShell de gestion ngrok pour n8n AI Starter Kit
# Usage: ./ngrok-manager.ps1 [start|stop|status|logs|urls|config|help]

param(
    [Parameter(Position = 0)]
    [ValidateSet("start", "stop", "restart", "status", "logs", "urls", "config", "help")]
    [string]$Command = "help"
)

$ComposeFile = "docker-compose.yml"
$NgrokContainer = "ngrok"

# Fonctions d'affichage coloré
function Write-Success {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Title {
    param([string]$Message)
    Write-Host "=== $Message ===" -ForegroundColor Cyan
}

# Vérifier si Docker est en cours d'exécution
function Test-DockerRunning {
    try {
        docker info | Out-Null
        return $true
    }
    catch {
        Write-Error "Docker n'est pas en cours d'exécution ou n'est pas accessible"
        return $false
    }
}

# Vérifier si le service ngrok existe
function Test-NgrokService {
    $services = docker-compose -f $ComposeFile config --services
    return $services -contains "ngrok"
}

# Démarrer ngrok
function Start-Ngrok {
    Write-Title "Démarrage de ngrok"
    
    # Vérifier si NGROK_AUTHTOKEN est défini
    $envContent = Get-Content .env -ErrorAction SilentlyContinue
    $authToken = ($envContent | Where-Object { $_ -match "^NGROK_AUTHTOKEN=" }) -replace "^NGROK_AUTHTOKEN=", ""
    
    if ([string]::IsNullOrEmpty($authToken)) {
        Write-Warning "NGROK_AUTHTOKEN n'est pas défini dans .env"
        Write-Warning "Les tunnels fonctionneront en mode limité (2h max)"
        Write-Host ""
        Write-Success "Pour obtenir un token gratuit :"
        Write-Success "1. Créez un compte sur https://ngrok.com"
        Write-Success "2. Récupérez votre token : https://dashboard.ngrok.com/get-started/your-authtoken"
        Write-Success "3. Ajoutez-le dans .env : NGROK_AUTHTOKEN=votre_token"
        Write-Host ""
    }
    
    # Démarrer le service ngrok
    docker-compose up -d ngrok
    
    Write-Success "ngrok démarré avec succès !"
    
    # Attendre que ngrok soit prêt
    Write-Success "Attente de l'initialisation de ngrok..."
    Start-Sleep -Seconds 5
    
    # Afficher les URLs
    Show-NgrokUrls
}

# Arrêter ngrok
function Stop-Ngrok {
    Write-Title "Arrêt de ngrok"
    docker-compose stop ngrok
    docker-compose rm -f ngrok
    Write-Success "ngrok arrêté avec succès !"
}

# Statut de ngrok
function Get-NgrokStatus {
    Write-Title "Statut de ngrok"
    
    $status = docker-compose ps ngrok
    if ($status -match "Up") {
        Write-Success "ngrok est en cours d'exécution"
        
        # Afficher les informations du conteneur
        Write-Host ""
        docker-compose ps ngrok
        
        # Afficher les URLs si disponibles
        Write-Host ""
        Show-NgrokUrls
    }
    else {
        Write-Warning "ngrok n'est pas en cours d'exécution"
    }
}

# Logs de ngrok
function Get-NgrokLogs {
    Write-Title "Logs de ngrok"
    docker-compose logs -f ngrok
}

# Afficher les URLs des tunnels
function Show-NgrokUrls {
    Write-Title "URLs des tunnels ngrok"
    
    try {
        # Vérifier si ngrok est accessible
        $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
        
        if ($response.tunnels.Count -gt 0) {
            foreach ($tunnel in $response.tunnels) {
                Write-Host "🌐 $($tunnel.name): $($tunnel.public_url) -> $($tunnel.config.addr)" -ForegroundColor Cyan
            }
            Write-Host ""
            Write-Success "Interface web ngrok : http://localhost:4040"
            Write-Success "Métriques ngrok : http://localhost:9090"
        }
        else {
            Write-Warning "Aucun tunnel actif trouvé"
        }
    }
    catch {
        Write-Error "Impossible d'accéder à l'API ngrok sur le port 4040"
        Write-Error "Vérifiez que le service ngrok est démarré"
    }
}

# Redémarrer ngrok
function Restart-Ngrok {
    Write-Title "Redémarrage de ngrok"
    Stop-Ngrok
    Start-Sleep -Seconds 2
    Start-Ngrok
}

# Configuration interactive
function Set-NgrokConfig {
    Write-Title "Configuration ngrok"
    
    Write-Host "Configuration de votre token ngrok :"
    Write-Host "1. Rendez-vous sur https://dashboard.ngrok.com/get-started/your-authtoken"
    Write-Host "2. Copiez votre token d'authentification"
    Write-Host ""
    
    $token = Read-Host "Entrez votre NGROK_AUTHTOKEN (ou Entrée pour ignorer)"
    
    if (![string]::IsNullOrEmpty($token)) {
        # Mettre à jour le fichier .env
        $envPath = ".env"
        $envContent = @()
        
        if (Test-Path $envPath) {
            $envContent = Get-Content $envPath
        }
        
        $tokenExists = $false
        for ($i = 0; $i -lt $envContent.Count; $i++) {
            if ($envContent[$i] -match "^NGROK_AUTHTOKEN=") {
                $envContent[$i] = "NGROK_AUTHTOKEN=$token"
                $tokenExists = $true
                break
            }
        }
        
        if (!$tokenExists) {
            $envContent += "NGROK_AUTHTOKEN=$token"
        }
        
        $envContent | Set-Content $envPath
        Write-Success "Token sauvegardé dans .env"
    }
    
    Write-Host ""
    Write-Host "Souhaitez-vous configurer des domaines personnalisés ? (nécessite un compte payant)"
    $n8nDomain = Read-Host "Domaine pour n8n (ex: mon-n8n.ngrok.io)"
    
    if (![string]::IsNullOrEmpty($n8nDomain)) {
        $envContent = Get-Content $envPath
        $domainExists = $false
        
        for ($i = 0; $i -lt $envContent.Count; $i++) {
            if ($envContent[$i] -match "^NGROK_DOMAIN=") {
                $envContent[$i] = "NGROK_DOMAIN=$n8nDomain"
                $domainExists = $true
                break
            }
        }
        
        if (!$domainExists) {
            $envContent += "NGROK_DOMAIN=$n8nDomain"
        }
        
        $envContent | Set-Content $envPath
        Write-Success "Domaine n8n configuré : $n8nDomain"
    }
}

# Menu d'aide
function Show-Help {
    Write-Title "ngrok Manager - Aide"
    Write-Host "Usage: ./ngrok-manager.ps1 [COMMAND]"
    Write-Host ""
    Write-Host "Commandes disponibles :"
    Write-Host "  start      Démarrer ngrok et créer les tunnels"
    Write-Host "  stop       Arrêter ngrok"
    Write-Host "  restart    Redémarrer ngrok"
    Write-Host "  status     Afficher le statut de ngrok"
    Write-Host "  logs       Afficher les logs de ngrok"
    Write-Host "  urls       Afficher les URLs des tunnels"
    Write-Host "  config     Configuration interactive"
    Write-Host "  help       Afficher cette aide"
    Write-Host ""
    Write-Host "Exemples :"
    Write-Host "  ./ngrok-manager.ps1 start           # Démarrer ngrok"
    Write-Host "  ./ngrok-manager.ps1 urls            # Voir les URLs publiques"
    Write-Host "  ./ngrok-manager.ps1 logs            # Suivre les logs"
}

# Main
if (!(Test-DockerRunning)) {
    exit 1
}

if (!(Test-NgrokService)) {
    Write-Error "Le service ngrok n'est pas défini dans $ComposeFile"
    exit 1
}

switch ($Command) {
    "start" { Start-Ngrok }
    "stop" { Stop-Ngrok }
    "restart" { Restart-Ngrok }
    "status" { Get-NgrokStatus }
    "logs" { Get-NgrokLogs }
    "urls" { Show-NgrokUrls }
    "config" { Set-NgrokConfig }
    "help" { Show-Help }
    default { 
        Write-Error "Commande inconnue: $Command"
        Write-Host ""
        Show-Help
        exit 1
    }
}
