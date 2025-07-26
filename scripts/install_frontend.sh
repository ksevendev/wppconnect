#!/bin/bash
# Este arquivo é: install_frontend.sh — Instala apenas o frontend do WPPConnect
# Autor: K'Seven 🦊

set -euo pipefail

# ⏱️ Inicia cronômetro para medir tempo de execução
START_TIME=$SECONDS

# Diretórios
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"      # Define a raiz do projeto
FRONTEND_DIR="$BASE_DIR/frontend"                 # Caminho do frontend
LOG_FILE="$BASE_DIR/install.log"                  # Arquivo de log

# Caminho para script de notificação Telegram (se existir)
TELEGRAM_SCRIPT="$SCRIPTS_DIR/telegram_notify.sh"

# Flag para indicar se Telegram está ativo
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"     # Importa funções de Telegram
  TELEGRAM_ENABLED=true
else
  TELEGRAM_ENABLED=false
fi

# Funções auxiliares
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }         # Retorna timestamp atual formatado

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

# Detecta a distribuição Linux atual
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
  else
    log "❌ Não foi possível identificar a distribuição Linux."
    send_telegram "❌ Não foi possível identificar a distribuição Linux."
    exit 1
  fi
}

# Verifica se um comando existe e instala o pacote se não estiver presente
check_or_install() {
  local cmd="$1"
  local pkg="$2"

  if ! command -v "$cmd" &>/dev/null; then
    log "📦 Instalando $pkg..."
    send_telegram "📦 Instalando $pkg..."
    if [[ "$DISTRO" =~ (ubuntu|debian) ]]; then
      sudo apt update && sudo apt install -y "$pkg"
    elif [[ "$DISTRO" =~ (centos|rhel|fedora) ]]; then
      sudo yum install -y "$pkg"
    else
      log "❌ Distribuição $DISTRO não suportada automaticamente."
      send_telegram "❌ Distribuição $DISTRO não suportada automaticamente."
      exit 1
    fi
  else
    log "✅ $pkg já instalado."
    send_telegram "✅ $pkg já instalado."
  fi
}

# Checa versão mínima do Node.js (precisamos do mínimo 16)
check_node_version() {
  local MIN_VERSION=16
  local INSTALLED_VERSION=$(node -v | grep -oP '\d+' | head -1 || echo 0)
  if (( INSTALLED_VERSION < MIN_VERSION )); then
    log "⚠️ Node.js está na versão $INSTALLED_VERSION, mas é necessário >= $MIN_VERSION."
    send_telegram "⚠️ Node.js está na versão $INSTALLED_VERSION, mas é necessário >= $MIN_VERSION."
    read -p "Deseja atualizar para versão recomendada (18)? (s/n): " RESPOSTA
    if [[ "$RESPOSTA" =~ ^[sS]$ ]]; then
      if [[ "$DISTRO" =~ (ubuntu|debian) ]]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt install -y nodejs
      elif [[ "$DISTRO" =~ (centos|rhel|fedora) ]]; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
      fi
    fi
  fi
}

### INÍCIO DO SCRIPT ###

log "🚀 Iniciando instalação do frontend..."
send_telegram "🚀 Iniciando instalação do frontend..."

# Descobre a distro Linux
detect_distro

# Verifica e instala as dependências necessárias
check_or_install "git" "git"
check_or_install "node" "nodejs"
check_node_version
check_or_install "npm" "npm"
check_or_install "curl" "curl"

# Clona o projeto frontend
if [ -d "$FRONTEND_DIR" ]; then
  log "📂 Frontend já existe em $FRONTEND_DIR. Pulando clone."
  send_telegram "📂 Frontend já existe em $FRONTEND_DIR. Pulando clone."
else
  log "📥 Clonando repositório do frontend..."
  send_telegram "📥 Clonando repositório do frontend..."
  git clone https://github.com/ksevendev/wppconnect-frontend.git "$FRONTEND_DIR"
fi

# Entra no diretório do projeto frontend
cd "$FRONTEND_DIR"

# Instala dependências do projeto frontend
log "📦 Instalando dependências do frontend..."
send_telegram "📦 Instalando dependências do frontend..."
npm install

# Compila o frontend para produção
log "🏗️ Gerando build do frontend para produção..."
send_telegram "🏗️ Gerando build do frontend para produção..."
npm run build

log "✅ Frontend instalado com sucesso e pronto para uso!"
send_telegram "✅ Frontend instalado com sucesso e pronto para uso!"

# ⏱️ Calcula o tempo de execução
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Atualização concluída em ${DURATION} segundos."