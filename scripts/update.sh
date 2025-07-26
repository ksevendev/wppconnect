#!/bin/bash
# Script: update.sh — Atualização inteligente com rollback
# Autor: K'Seven 🦊

set -euo pipefail  # Ativa modo seguro: para erros, variáveis não definidas e falhas em pipe

# ⏱️ Inicia cronômetro para medir tempo de execução
START_TIME=$SECONDS

# Define caminho base do script (diretório atual do install.sh)
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Diretório onde ficam os scripts auxiliares (ex: install_backend.sh, main_menu.sh)
SCRIPTS_DIR="$BASE_DIR/scripts"

# Arquivo de log principal para instalação/atualização
LOG_FILE="$BASE_DIR/update.log"

# Caminho para script de notificação Telegram (se existir)
TELEGRAM_SCRIPT="$SCRIPTS_DIR/telegram_notify.sh"

# Flag para indicar se Telegram está ativo
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"     # Importa funções de Telegram
  TELEGRAM_ENABLED=true
else
  TELEGRAM_ENABLED=false
fi

# Função que retorna timestamp formatado YYYY-MM-DD HH:MM:SS
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# Função de log que escreve no console e no arquivo de log com timestamp
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# Função segura para enviar mensagens Telegram se estiver habilitado
send_telegram() {
  if $TELEGRAM_ENABLED; then
    send_telegram_message "$1" "$2"
  fi
}

# Detecta a distribuição Linux atual via /etc/os-release
detectar_distro() {
  if [[ -f /etc/os-release ]]; then
    # Importa variáveis da distro, ex: ID=ubuntu
    . /etc/os-release
    DISTRO=$ID
    log "Distribuição detectada: $DISTRO"
    send_telegram "Distribuição detectada no servidor: $DISTRO"
  else
    log "❌ Distribuição Linux não detectada."
    send_telegram "❌ Distribuição Linux não detectada."
    exit 1
  fi
}

echo "1) Atualizar Backend"
echo "2) Atualizar Frontend"
echo "3) Atualizar Tudo"
read -p "Escolha: " OPT

case $OPT in
  1) ./scripts/update_backend.sh ;;
  2) ./scripts/update_frontend.sh ;;
  3) ./scripts/update_backend.sh && ./scripts/update_frontend.sh ;;
  *) log "Opção inválida!" && send_telegram "Opção inválida!" && sleep 1 ;;
esac
