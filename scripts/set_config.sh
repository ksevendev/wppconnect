#!/bin/bash
# set_config.sh — Script para editar as variáveis do config.sh interativamente
# Autor: K'Seven 🦊

set -euo pipefail  # ⚙️ Modo seguro: erro se variável não definida ou falha em pipes

# ⏱️ Marca o início da execução
START_TIME=$SECONDS

# 📂 Caminho base do script atual
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# 📁 Pasta onde ficam os scripts auxiliares
SCRIPTS_DIR="$BASE_DIR/../scripts"

# 📄 Caminho do arquivo de log (compartilhado com update.sh, se quiser)
LOG_FILE="$BASE_DIR/update.log"

# 📍 Caminho para script de notificação do Telegram (opcional)
TELEGRAM_SCRIPT="$SCRIPTS_DIR/telegram_notify.sh"

# 🚦 Detecta se o Telegram está ativado
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"     # 🔁 Importa as funções do Telegram
  TELEGRAM_ENABLED=true         # ✅ Telegram ON
else
  TELEGRAM_ENABLED=false        # 🚫 Telegram OFF
fi

# ⏰ Função para gerar timestamp formatado
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# 📥 Função de log com saída no terminal e em arquivo
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# ✉️ Função que envia mensagem Telegram (se ativo)
send_telegram() {
  if $TELEGRAM_ENABLED; then
    send_telegram_message "$1" "$2"
  fi
}

# 🧾 Caminho para o arquivo de configuração que será editado
CONFIG_FILE="$(dirname "$0")/config.sh"

# 🧠 Função para editar uma variável no arquivo config.sh
edit_var() {
  local VAR_NAME=$1                     # Nome da variável
  local PROMPT=$2                       # Texto a ser exibido no terminal

  current_value=$(grep "^$VAR_NAME=" "$CONFIG_FILE" | cut -d'=' -f2-)  # Valor atual da variável
  read -p "$PROMPT [$current_value]: " new_value                       # Solicita novo valor
  new_value=${new_value:-$current_value}                               # Se vazio, mantém valor atual

  # 🔁 Substitui valor no config.sh
  sed -i "s|^$VAR_NAME=.*|$VAR_NAME=$new_value|" "$CONFIG_FILE"

  # ✅ Feedback no terminal e Telegram
  echo "✅ $VAR_NAME atualizado para $new_value"
  send_telegram "✅ $VAR_NAME atualizado para $new_value"
}

# 🚀 Início da edição de variáveis
echo "🛠️ Edição de configuração do WPPConnect"
send_telegram "🛠️ Edição de configuração do WPPConnect"

# 🧪 Variáveis editáveis
edit_var "APP_DOMAIN"         "Informe o domínio ou IP do app"
edit_var "USE_HTTPS"          "Usar HTTPS? (true/false)"
edit_var "JWT_SECRET"         "Informe uma chave secreta JWT"
edit_var "BACKEND_PORT"       "Informe a porta do backend"
edit_var "FRONTEND_PORT"      "Informe a porta do frontend"
edit_var "TELEGRAM_BOT_TOKEN" "Token do Bot Telegram"
edit_var "TELEGRAM_CHAT_ID"   "Chat ID do Telegram"

# 🎉 Finalização
echo "🎉 Configurações atualizadas com sucesso!"
send_telegram "🎉 Configurações atualizadas com sucesso!"

# ⏱️ Cálculo de tempo total
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Atualização concluída em ${DURATION} segundos."
