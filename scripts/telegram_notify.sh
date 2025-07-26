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

# === ENVIO ===
send_telegram_message() {
  local TITLE="$1"
  local MESSAGE="${2:-}"  # ← Se $2 não for fornecido, assume string vazia

  if is_telegram_bot_active; then
    local PAYLOAD

    if [[ -n "$MESSAGE" ]]; then
      PAYLOAD="*$TITLE*\n\n$MESSAGE\n\n_Sent by: $SENDER_NAME_"
    else
      PAYLOAD="*$TITLE*\n\n_Sent by: $SENDER_NAME_"
    fi

    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
      -d chat_id="$TELEGRAM_CHAT_ID" \
      -d text="$PAYLOAD" \
      -d parse_mode="Markdown" >/dev/null

    echo "[TELEGRAM] Mensagem enviada com sucesso!"
  else
    echo "[TELEGRAM] Bot inativo ou token inválido."
  fi
}


# === EXECUÇÃO DIRETA ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  send_telegram_message "$1" "$2"
fi
