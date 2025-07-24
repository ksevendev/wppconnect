#!/bin/bash
set -e

echo "Atualizando backend..."
cd /opt/wppconnect-server
git pull origin main
yarn install
yarn build || echo "Ignorando erro de build."
pm2 restart wppconnect-backend

echo "Atualizando frontend..."
cd /opt/wppconnect-frontend
git pull origin main
yarn install
yarn build
cp -r dist/* /var/www/wppconnect-frontend/

echo "✅ Atualização concluída."
