#!/bin/bash

echo "Parando backend..."
pm2 stop wppconnect-backend || true
pm2 delete wppconnect-backend || true
pm2 save || true

echo "Removendo backend..."
rm -rf /opt/wppconnect-server

echo "Removendo frontend..."
rm -rf /opt/wppconnect-frontend
rm -rf /var/www/wppconnect-frontend

echo "Removendo configurações nginx..."
rm -f /etc/nginx/sites-enabled/wppconnect
rm -f /etc/nginx/sites-available/wppconnect
systemctl reload nginx

echo "✅ Desinstalação concluída."
