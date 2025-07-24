#!/bin/bash
set -e

read -p "Digite seu domínio (ex: wpp.seudominio.com): " DOMAIN
read -p "Digite seu email para Let's Encrypt: " EMAIL

apt-get update
apt-get install -y nginx certbot python3-certbot-nginx

cat >/etc/nginx/sites-available/wppconnect <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/wppconnect-frontend;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:21465/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOL

ln -sf /etc/nginx/sites-available/wppconnect /etc/nginx/sites-enabled/wppconnect

nginx -t && systemctl reload nginx

certbot --nginx --non-interactive --agree-tos -m $EMAIL -d $DOMAIN

echo "✅ Nginx e HTTPS configurados com sucesso."
