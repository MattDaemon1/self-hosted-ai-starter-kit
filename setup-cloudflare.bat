@echo off
echo =================================================================
echo       Configuration Cloudflare Tunnel pour n8n
echo =================================================================
echo.

echo 1. Allez sur https://dash.cloudflare.com/
echo 2. Cliquez sur "Zero Trust" dans le menu
echo 3. Allez dans "Access" > "Tunnels"
echo 4. Cliquez "Create a tunnel"
echo 5. Donnez un nom (ex: n8n-tunnel) et cliquez "Save tunnel"
echo 6. Copiez la commande qui apparait (elle contient le token)
echo.

set /p TOKEN="Collez le token du tunnel ici: "

echo.
echo Creation du fichier de configuration...

echo tunnel: %TOKEN% > cloudflare-tunnel.yml
echo credentials-file: /etc/cloudflared/cert.json >> cloudflare-tunnel.yml
echo. >> cloudflare-tunnel.yml
echo ingress: >> cloudflare-tunnel.yml
echo   - service: http://caddy:443 >> cloudflare-tunnel.yml
echo     originRequest: >> cloudflare-tunnel.yml
echo       noTLSVerify: true >> cloudflare-tunnel.yml
echo   - service: http_status:404 >> cloudflare-tunnel.yml

echo {"AccountTag":"","TunnelSecret":"%TOKEN%","TunnelID":"%TOKEN%"} > cloudflare-cert.json

echo.
echo Configuration terminee !
echo Maintenant executez: docker-compose up -d cloudflare-tunnel
echo.
pause
