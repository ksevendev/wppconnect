#!/bin/bash
set -e

REPO="https://github.com/ksevendev/wppconnect-frontend.git"
DIR="/opt/wppconnect-frontend"

echo "🚀 Instalando frontend WPPConnect..."

apt-get update
apt-get install -y git yarn nginx

if [ -d "$DIR" ]; then
  echo "Repositorio frontend já existe, atualizando..."
  cd "$DIR" && git pull origin main
else
  git clone "$REPO" "$DIR"
  cd "$DIR"
fi

yarn install
yarn build

mkdir -p /var/www/wppconnect-frontend
rm -rf /var/www/wppconnect-frontend/*
cp -r dist/* /var/www/wppconnect-frontend/

echo "✅ Frontend instalado em /var/www/wppconnect-frontend"
