#!/bin/bash
# Script: update_backend.sh — Atualização inteligente do backend com rollback e Telegram
# Autor: K'Seven 🦊

set -euo pipefail  # Segurança total: aborta em erros ou comandos inválidos

# ⏱️ Marca o início da execução
START_TIME=$SECONDS

# 📁 Caminhos principais
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BACKEND_DIR="$BASE_DIR/backend"
REPO_URL="https://github.com/ksevendev/wppconnect-server.git"
LOG_FILE="$BASE_DIR/update.log"

# 🔗 Telegram opcional
TELEGRAM_SCRIPT="$(dirname "$0")/telegram_notify.sh"
[[ -f "$TELEGRAM_SCRIPT" ]] && source "$TELEGRAM_SCRIPT" && TELEGRAM_ENABLED=true || TELEGRAM_ENABLED=false

# ⏲️ Timestamp amigável
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# 📝 Log com horário + gravação
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# 📩 Envia mensagem ao Telegram, se ativo
send_telegram() {
  $TELEGRAM_ENABLED && send_telegram_message "$1" "$2"
}

# 🔍 Verifica dependências
for cmd in git npm pm2; do
  if ! command -v $cmd &>/dev/null; then
    log "❌ Comando '$cmd' não encontrado. Instale antes de continuar."
    send_telegram "❌ Falha na atualização Backend" "Dependência '$cmd' ausente no sistema."
    exit 1
  fi
done

log "🔄 Iniciando atualização do backend..."
send_telegram "🔄 Atualizando Backend" "Iniciando atualização do repositório:\n$REPO_URL"

# 🔍 Valida repositório
if [ ! -d "$BACKEND_DIR/.git" ]; then
  log "❌ Diretório inválido: $BACKEND_DIR"
  send_telegram "❌ Erro no Backend" "Diretório $BACKEND_DIR não é um repositório git válido."
  exit 1
fi

cd "$BACKEND_DIR"

# 🔃 Coleta informações da versão atual
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git ls-remote "$REPO_URL" "$CURRENT_BRANCH" | awk '{print $1}')

log "📌 Versão local: $LOCAL_COMMIT"
log "📌 Versão remota: $REMOTE_COMMIT"
log "🌿 Branch: $CURRENT_BRANCH"

send_telegram "📋 Repositório Backend" "Branch: $CURRENT_BRANCH\nLocal: $LOCAL_COMMIT\nRemoto: $REMOTE_COMMIT"

# ✅ Já está atualizado?
if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
  log "✅ Backend já está atualizado."
  send_telegram "✅ Nenhuma Atualização" "O backend já está na última versão."
  exit 0
fi

# 📦 Backup
BACKUP_DIR="$BASE_DIR/_backup/backend_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r . "$BACKUP_DIR"
log "📦 Backup salvo em: $BACKUP_DIR"
send_telegram "📦 Backup Realizado" "Backup salvo em: $BACKUP_DIR"

# 🔁 Puxa atualizações
git pull origin "$CURRENT_BRANCH" || {
  log "❌ Falha no git pull"
  send_telegram "❌ Falha no Git Pull" "Erro ao atualizar do repositório remoto."
  exit 1
}

# 📦 Instala dependências
npm install || {
  log "❌ Falha no npm install. Restaurando backup..."
  cp -r "$BACKUP_DIR"/* .
  send_telegram "❌ Erro no npm install" "Rollback executado com sucesso."
  exit 1
}

# 🛠️ Compila projeto
npm run build || {
  log "⚠️ Build falhou. Tentando iniciar com build anterior..."
  send_telegram "⚠️ Erro na build" "Build falhou. Tentando iniciar com último build existente."
}

# 🚀 Reinicia com PM2
pm2 restart all || {
  log "❌ Falha ao reiniciar o backend via PM2"
  send_telegram "❌ Falha no PM2" "Erro ao reiniciar o backend após update."
  exit 1
}

# ✅ Finaliza
log "✅ Backend atualizado com sucesso para $(git rev-parse HEAD)"
send_telegram "✅ Atualização Concluída" "Nova versão backend: $(git rev-parse HEAD)"

# ⏱️ Tempo total
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo de execução: ${DURATION}s"
send_telegram "⏱️ Tempo Total" "Atualização realizada em ${DURATION} segundos."
