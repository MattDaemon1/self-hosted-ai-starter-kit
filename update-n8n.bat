@echo off
echo Mise à jour manuelle de n8n...
echo.

echo Arrêt du service n8n...
docker-compose stop n8n

echo Téléchargement de la dernière version de n8n...
docker pull n8nio/n8n:latest

echo Redémarrage du service n8n avec la nouvelle version...
docker-compose up -d n8n

echo.
echo Mise à jour de n8n terminée !
echo Vous pouvez accéder à n8n sur : http://localhost

pause
