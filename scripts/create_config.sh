#!/bin/bash
# create_config.sh — Gera config.sh com dados via input ou variáveis, e envia para Telegram
# Autor: K'Seven 🦊

set -euo pipefail  # Segurança braba: erro se variável não definida ou comando falha

# ⏱️ Cronômetro ON
START_TIME=$SECONDS

# Caminhos base
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$BASE_DIR/config.sh"
SCRIPTS_DIR="$BASE_DIR/scripts"
TELEGRAM_SCRIPT="$SCRIPTS_DIR/telegram_notify.sh"

# ⏳ Timestamp bonito
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# 🧾 Logger com hora
log() {
  echo "[$(TIMESTAMP)] $1"
}

# 🧠 Verifica e carrega script Telegram
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"
  TELEGRAM_ENABLED=true
else
  TELEGRAM_ENABLED=false
fi

# ✉️ Envia para Telegram, se ativado
send_telegram() {
  if $TELEGRAM_ENABLED; then
    send_telegram_message "$1" "$2"
  fi
}

# 📥 Pede dado com padrão ou usa argumento/env
ask_or_arg() {
  local var_name=$1
  local prompt=$2
  local default_value=$3
  local user_input=${!var_name:-}

  if [[ -z "$user_input" ]]; then
    read -p "$prompt [$default_value]: " user_input
    user_input="${user_input:-$default_value}"
  fi
  eval "$var_name=\"$user_input\""
}

# 🎉 Começo do processo
log "🚀 Iniciando criação do config.sh"
send_telegram "⚙️ Gerando novo config.sh..." "WPPConnect Setup"

# 🔧 Coleta de dados
ask_or_arg PM2NAME            "🔧 Nome do processo no PM2"               "wppconnectserver"
ask_or_arg APP_DOMAIN         "🌐 Domínio do App (ex: app.kseven.com.br)" "localhost"
ask_or_arg USE_HTTPS          "🔐 Usar HTTPS? (true/false)"              "true"
ask_or_arg SECRET_KEY         "🔒 Chave secreta do servidor"             "minha-chave-secreta"
ask_or_arg JWT_SECRET         "🛡️ JWT Secret Key"                        "jwt-secreta-123"
ask_or_arg BACKEND_PORT       "⚙️ Porta do backend"                      "21465"
ask_or_arg FRONTEND_PORT      "⚙️ Porta do frontend"                     "80"
ask_or_arg TELEGRAM_BOT_TOKEN "🤖 Token do Bot Telegram"                 "SEU_TOKEN_AQUI"
ask_or_arg TELEGRAM_CHAT_ID   "💬 Chat ID do Telegram"                   "SEU_CHAT_ID"


if [[ -f "$CONFIG_FILE" ]]; then
  read -p "⚠️ O arquivo config.sh já existe. Deseja sobrescrever? (s/N): " confirm
  [[ "$confirm" =~ ^[sS]$ ]] || exit 0
fi

# ✍️ Criação do arquivo config.sh
cat <<EOF > "$CONFIG_FILE"
#!/bin/bash
# config.sh — Variáveis globais de configuração do WPPConnect
# Autor: K'Seven 🦊
# Gerado automaticamente por create_config.sh 🦊

# 🔧 Nome do processo no PM2
PM2NAME="$PM2NAME"

# 🔧 Configurações de domínio/URL
APP_DOMAIN="$APP_DOMAIN"
USE_HTTPS=$USE_HTTPS

# WPP Server
SECRET_KEY="$SECRET_KEY"
deviceName="WppConnect"
poweredBy="WPPConnect-Server"
linkPreviewApiServers="null"

# 🔒 Segurança
JWT_SECRET="$JWT_SECRET"

# ⚙️ Portas
BACKEND_PORT=$BACKEND_PORT
FRONTEND_PORT=$FRONTEND_PORT

# 📲 Notificações
TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN"
TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"
EOF

log "✅ config.sh gerado com sucesso em: $CONFIG_FILE"
send_telegram "✅ config.sh criado com sucesso!" "WPPConnect"

# ⏱️ Final do cronômetro
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Arquivo gerado em ${DURATION} segundos."

bash "$SCRIPTS_DIR/main_menu.sh"
