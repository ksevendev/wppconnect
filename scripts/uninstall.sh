#!/bin/bash
# uninstall.sh — Remove backend, frontend, Nginx e configurações
# Autor: K'Seven 🦊

# ⚙️ Ativa modo seguro: erro em comando, variável indefinida ou falha em pipe encerram o script
set -euo pipefail

# ⏱️ Inicia cronômetro para medir tempo de execução
START_TIME=$SECONDS

# 📂 Define caminho base (raiz do projeto) e pasta de scripts
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"

# 📝 Arquivo de log da desinstalação
LOG_FILE="$BASE_DIR/uninstall.log"

# 🛜 Caminho do script de notificação Telegram (opcional)
TELEGRAM_SCRIPT="$SCRIPTS_DIR/telegram_notify.sh"

# 🚨 Verifica se Telegram está ativado
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"
  TELEGRAM_ENABLED=true
else
  TELEGRAM_ENABLED=false
fi

# 🕒 Timestamp formatado
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# 📥 Função para registrar log com horário e salvar em arquivo
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# ✉️ Envia mensagem ao Telegram se estiver habilitado
send_telegram() {
  $TELEGRAM_ENABLED && send_telegram_message "$1" "$2"
}

# 🚀 Início do processo
log "⚠️ Iniciando desinstalação do WPPConnect..."
send_telegram "⚠️ Iniciando desinstalação do WPPConnect..." "WPPConnect"

# 🧹 Função para remover diretório com segurança
remove_dir() {
  local DIR="$1"
  local NAME="$2"
  if [[ -d "$DIR" ]]; then
    rm -rf "$DIR" || sudo rm -rf "$DIR"
    log "🗑️ $NAME removido."
    send_telegram "🗑️ $NAME removido."
  else
    log "ℹ️ $NAME não encontrado."
    send_telegram "ℹ️ $NAME não encontrado."
  fi
}

# 🧨 Remove Backend
remove_dir "$BASE_DIR/backend" "Backend"

# 🧨 Remove Frontend
remove_dir "$BASE_DIR/frontend" "Frontend"

# 🔥 Remove Nginx (site config, certificado, reload)
if command -v nginx >/dev/null; then
  read -rp "Digite o domínio usado no Nginx (ex: meuapp.com): " DOMAIN

  # Caminhos padrão do Nginx e SSL
  NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
  NGINX_LINK="/etc/nginx/sites-enabled/$DOMAIN"
  SSL_DIR="/etc/letsencrypt/live/$DOMAIN"

  # Remove configurações e certificado SSL
  sudo rm -f "$NGINX_CONF" "$NGINX_LINK"
  sudo rm -rf "$SSL_DIR"

  # Testa e recarrega o Nginx
  sudo nginx -t && sudo systemctl reload nginx

  log "🗑️ Configurações Nginx e SSL para '$DOMAIN' removidas."
  send_telegram "🗑️ Nginx + SSL removidos para $DOMAIN"
else
  log "ℹ️ Nginx não está instalado, pulando remoção de configs."
fi

# ✅ Finaliza processo
log "✅ Desinstalação concluída."
send_telegram "✅ Desinstalação do WPPConnect concluída com sucesso." "WPPConnect"

# ⏱️ Exibe tempo de execução
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Desinstalação concluída em ${DURATION} segundos."

# 🎶 (Opcional) Toca um som se tiver `mpg123` instalado — só por zoeira nerd 😎
# command -v mpg123 >/dev/null && mpg123 /usr/share/sounds/alsa/Front_Center.wav
