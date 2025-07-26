#!/bin/bash
# Script para enviar notificações via Telegram 📲 (com verificação de bot ativo)
# Autor: K'Seven 🦊

set -euo pipefail

# === CONFIGURAÇÃO ===
BOT_TOKEN="123456789:ABCDefghIJKlmNoPQrstUVwxyZ"  # ← Substitua pelo seu token
CHAT_ID="123456789"                               # ← Substitua pelo seu ID
SENDER_NAME="K'Seven WPP Installer 🦊"

# === VERIFICADOR DO BOT ===
is_telegram_bot_active() {
  curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getMe" | grep -q '"ok":true'
}

# === FUNÇÃO DE ENVIO ===
send_telegram_message() {
  local TITLE="$1"
  local MESSAGE="$2"

  if is_telegram_bot_active; then
    PAYLOAD="*$TITLE*\n\n$MESSAGE\n\n_Sent by: $SENDER_NAME_"

    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
      -d chat_id="$CHAT_ID" \
      -d text="$PAYLOAD" \
      -d parse_mode="Markdown" >/dev/null

    echo "[TELEGRAM] Mensagem enviada com sucesso!"
  else
    echo "[TELEGRAM] Bot inativo ou token inválido. Ignorando notificação."
  fi
}

# === USO DIRETO VIA TERMINAL ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  send_telegram_message "$1" "$2"
fi
