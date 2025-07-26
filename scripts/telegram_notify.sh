#!/bin/bash
# Script para enviar notificações via Telegram 📲 (usando config.sh)
# Autor: K'Seven 🦊

set -euo pipefail

# === CONFIG ===
CONFIG_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/scripts/config.sh"
if [[ -f "$CONFIG_PATH" ]]; then
  source "$CONFIG_PATH"
else
  echo "[ERRO] config.sh não encontrado em $CONFIG_PATH"
  exit 1
fi

SENDER_NAME="K'Seven WPP Installer 🦊"

# === VERIFICADOR DO BOT ===
is_telegram_bot_active() {
  curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" | grep -q '"ok":true'
}

# === ESCAPE PARA MARKDOWN ===
escape_markdown() {
  echo "$1" | sed -e 's/\*/\\*/g' \
                  -e 's/_/\\_/g' \
                  -e 's/\[/\\[/g' \
                  -e 's/\]/\\]/g' \
                  -e 's/(/\\(/g' \
                  -e 's/)/\\)/g' \
                  -e 's/`/\\`/g' \
                  -e 's/>/\\>/g' \
                  -e "s/'/\\'/g"
}

# === ENVIO PARA TODOS ===
send_telegram_message() {
  local TITLE="${1:-"Notificação"}"
  local MESSAGE="${2:-""}"

  if is_telegram_bot_active; then
    local ESCAPED_TITLE ESCAPED_MESSAGE PAYLOAD
    ESCAPED_TITLE=$(escape_markdown "$TITLE")
    ESCAPED_MESSAGE=$(escape_markdown "$MESSAGE")

    if [[ -n "$ESCAPED_MESSAGE" ]]; then
      PAYLOAD="*$ESCAPED_TITLE*\n\n$ESCAPED_MESSAGE\n\n_Sent by: $SENDER_NAME_"
    else
      PAYLOAD="*$ESCAPED_TITLE*\n\n_Sent by: $SENDER_NAME_"
    fi

    for CHAT_ID in "${TELEGRAM_CHAT_IDS[@]}"; do
      curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        --data-urlencode "chat_id=$CHAT_ID" \
        --data-urlencode "text=$PAYLOAD" \
        --data-urlencode "parse_mode=Markdown" >/dev/null
    done

    echo "[TELEGRAM] Mensagem enviada para todos os destinos com sucesso!"
  else
    echo "[TELEGRAM] Bot inativo ou token inválido."
  fi
}

# === EXECUÇÃO DIRETA ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  send_telegram_message "${1:-"Mensagem sem título"}" "${2:-""}"
fi
