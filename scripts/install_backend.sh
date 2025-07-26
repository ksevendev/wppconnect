#!/bin/bash
# Este arquivo é: install_backend.sh — Instala apenas o backend do WPPConnect
# Autor: K'Seven 🦊

set -euo pipefail

# ⏱️ Inicia cronômetro para medir tempo de execução
START_TIME=$SECONDS

# Diretórios
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_DIR="$BASE_DIR/backend"
LOG_FILE="$BASE_DIR/install.log"

# Nome do processo no PM2
SSNAME="wppconnectserver"

# Timestamp para log
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# Log formatado
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# Verifica distribuição
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

# Instala pacote se não existir
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

# Instala Node.js se versão for incompatível
check_node_version() {
  local MIN_VERSION=16
  local INSTALLED_VERSION=$(node -v | grep -oP '\d+' | head -1 || echo 0)
  if (( INSTALLED_VERSION < MIN_VERSION )); then
    log "⚠️ Node.js instalado é versão $INSTALLED_VERSION (mínimo $MIN_VERSION)"
    send_telegram "⚠️ Node.js instalado é versão $INSTALLED_VERSION (mínimo $MIN_VERSION)"
    read -p "Deseja atualizar para versão recomendada? (s/n): " RESPOSTA
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

### INÍCIO DO FLUXO ###

log "🚀 Iniciando instalação do backend..."
send_telegram "🚀 Iniciando instalação do backend..."

detect_distro

# Verifica e instala dependências
check_or_install "git" "git"
check_or_install "node" "nodejs"
check_node_version
check_or_install "npm" "npm"
check_or_install "pm2" "pm2"

# Instala PM2 se não estiver global
if ! command -v pm2 &>/dev/null; then
  log "🔧 Instalando PM2 globalmente..."
  send_telegram "🔧 Instalando PM2 globalmente..."
  sudo npm install -g pm2
else
  log "✅ PM2 já instalado."
  send_telegram "✅ PM2 já instalado."
fi

# Clonagem do projeto
if [ -d "$BACKEND_DIR" ]; then
  log "📂 Backend já existe em $BACKEND_DIR. Pulando clone."
  send_telegram "📂 Backend já existe em $BACKEND_DIR. Pulando clone."
else
  log "📥 Clonando repositório backend..."
  send_telegram "📥 Clonando repositório backend..."
  git clone https://github.com/ksevendev/wppconnect-server.git "$BACKEND_DIR"
fi

# Instalação e execução
cd "$BACKEND_DIR"

log "📦 Instalando pacotes Node..."
send_telegram "📦 Instalando pacotes Node..."
npm install

log "⚙️ Rodando build do backend (se aplicável)..."
send_telegram "⚙️ Rodando build do backend (se aplicável)..."
npm run build || true

log "▶️ Iniciando backend com PM2..."
send_telegram "▶️ Iniciando backend com PM2..."
pm2 start dist/main.js --name "$SSNAME" || pm2 start npm --name "$SSNAME" -- run start:prod

log "✅ Backend instalado e rodando com sucesso via PM2!"
send_telegram "✅ Backend instalado e rodando com sucesso via PM2!"

# ⏱️ Calcula o tempo de execução
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Atualização concluída em ${DURATION} segundos."