#!/bin/bash
# Script: setup_nginx.sh — Configura NGINX com HTTPS (SSL via Let's Encrypt)
# Autor: K'Seven 🦊

set -euo pipefail

# ⏱️ Inicia cronômetro para medir tempo de execução
START_TIME=$SECONDS

# Caminho base e diretórios
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"                      # Define diretório base do projeto
FRONTEND_DIR="$BASE_DIR/frontend"                                 # Define o caminho do frontend
LOG_FILE="$BASE_DIR/install.log" 

# Caminho para script de notificação Telegram (se existir)
TELEGRAM_SCRIPT="$SCRIPTS_DIR/telegram_notify.sh"

# Flag para indicar se Telegram está ativo
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"     # Importa funções de Telegram
  TELEGRAM_ENABLED=true
else
  TELEGRAM_ENABLED=false
fi                                 # Caminho do arquivo de log

# Função timestamp para log formatado
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# Função de log com horário
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# Função segura para enviar mensagens Telegram se estiver habilitado
send_telegram() {
  if $TELEGRAM_ENABLED; then
    send_telegram_message "$1" "$2"
  fi
}

# Solicita domínio do usuário
read -rp "🌐 Digite o domínio que deseja usar (ex: meusite.com.br): " DOMAIN

# Valida se domínio foi informado
if [[ -z "$DOMAIN" ]]; then
  log "❌ Domínio não informado. Abortando."
  send_telegram "❌ Domínio não informado. Abortando."
  exit 1
fi

# Define caminhos do NGINX com base no domínio
NGINX_CONFIG="/etc/nginx/sites-available/$DOMAIN"
NGINX_LINK="/etc/nginx/sites-enabled/$DOMAIN"

# Detecta distribuição Linux
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
  else
    log "❌ Não foi possível detectar a distribuição Linux."
    send_telegram "❌ Não foi possível detectar a distribuição Linux."
    exit 1
  fi
}

# Instala NGINX e Certbot, dependendo da distribuição
install_dependencies() {
  log "📦 Instalando dependências (NGINX + Certbot)..."
  send_telegram "📦 Instalando dependências (NGINX + Certbot)..."
  if [[ "$DISTRO" =~ (ubuntu|debian) ]]; then
    sudo apt update
    sudo apt install -y nginx certbot python3-certbot-nginx
  elif [[ "$DISTRO" =~ (centos|rhel|fedora) ]]; then
    sudo yum install -y epel-release
    sudo yum install -y nginx certbot python3-certbot-nginx
  else
    log "❌ Distribuição não suportada: $DISTRO"
    send_telegram "❌ Distribuição não suportada: $DISTRO"
    exit 1
  fi
}

# Gera config do NGINX para servir o frontend e redirecionar para backend
create_nginx_config() {
  log "🛠️ Criando configuração do NGINX..."
  send_telegram "🛠️ Criando configuração do NGINX..."

  sudo tee "$NGINX_CONFIG" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root $FRONTEND_DIR/dist;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

  sudo ln -sf "$NGINX_CONFIG" "$NGINX_LINK"                         # Cria link simbólico para ativar site
  sudo nginx -t && sudo systemctl reload nginx                     # Testa e recarrega NGINX
}

# Solicita e aplica certificado SSL
enable_ssl() {
  log "🔐 Solicitando certificado SSL para $DOMAIN..."
  send_telegram "🔐 Solicitando certificado SSL para $DOMAIN..."
  sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "admin@$DOMAIN"
  log "✅ Certificado SSL instalado com sucesso!"
  send_telegram "✅ Certificado SSL instalado com sucesso!"
}

# Execução do fluxo principal
log "🚀 Iniciando configuração do NGINX com SSL..."
send_telegram "🚀 Iniciando configuração do NGINX com SSL..."

detect_distro              # Detecta o tipo de distro Linux
install_dependencies       # Instala NGINX e Certbot
create_nginx_config        # Cria config do NGINX
enable_ssl                 # Ativa HTTPS com Let's Encrypt

log "🎉 NGINX configurado com HTTPS para $DOMAIN com sucesso!"
send_telegram "🎉 NGINX configurado com HTTPS para $DOMAIN com sucesso!"

# ⏱️ Calcula o tempo de execução
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Atualização concluída em ${DURATION} segundos."
