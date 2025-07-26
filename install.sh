#!/bin/bash
# Arquivo: install.sh — Instalador WPPConnect
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

# Instala as dependências básicas necessárias para o instalador rodar
instalar_dependencias() {
  log "🔍 Instalando dependências obrigatórias..."
  send_telegram "🔍 Instalando dependências obrigatórias..."

  case "$DISTRO" in
    ubuntu|debian)
      sudo apt update && sudo apt install -y curl git whiptail sudo
      ;;
    centos|rhel|fedora)
      sudo yum install -y curl git newt sudo
      ;;
    *)
      log "⚠️ Distribuição $DISTRO não suportada automaticamente. Instale dependências manualmente."
      send_telegram "⚠️ Distribuição $DISTRO não suportada automaticamente. Instale dependências manualmente."
      ;;
  esac
}

# Dá permissão executável para todos os scripts .sh na pasta scripts
liberar_execucao() {
  chmod +x "$SCRIPTS_DIR"/*.sh
  log "✅ Permissões de execução garantidas para scripts em $SCRIPTS_DIR"
  send_telegram "✅ Permissões de execução garantidas para scripts em $SCRIPTS_DIR"
}

# Chama o menu principal (modularizado) que fica em scripts/main_menu.sh
chamar_menu() {
  log "🔧 Iniciando menu principal do instalador..."
  send_telegram "🔧 Iniciando menu principal do instalador..."
  bash "$SCRIPTS_DIR/main_menu.sh"
}

### INÍCIO DO FLUXO PRINCIPAL ###

detectar_distro           # Detecta distro Linux
instalar_dependencias     # Instala pacotes essenciais
liberar_execucao          # Garante permissão para executar scripts
chamar_menu               # Executa o menu principal do instalador

# ⏱️ Calcula o tempo de execução
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Atualização concluída em ${DURATION} segundos."