#!/bin/bash
set -e

REPO="https://github.com/ksevendev/wppconnect-server.git"
DIR="/opt/wppconnect-server"

echo "🚀 Instalando backend WPPConnect..."

# Atualiza o sistema e instala Node.js 22.x, yarn e PM2
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get update
apt-get install -y nodejs build-essential git yarn pm2

if [ -d "$DIR" ]; then
  echo "Repositorio backend já existe, atualizando..."
  cd "$DIR" && git pull origin main
else
  git clone "$REPO" "$DIR"
  cd "$DIR"
fi

yarn install
yarn build || echo "Ignorando erro de build caso não tenha."

pm2 start dist/server.js --name wppconnect-backend -- --port 21465
pm2 save

echo "✅ Backend instalado e rodando na porta 21465."
