#!/bin/bash
# Script: update_frontend.sh — Atualização segura com controle de versão + Telegram
# Autor: K'Seven 🦊

set -euo pipefail  # Ativa o modo seguro: para se houver erro, variáveis indefinidas ou falha em pipes

# ⏱️ Inicia o cronômetro para medir o tempo de execução
START_TIME=$SECONDS

# 🔗 Carrega funções de notificação do Telegram, se o arquivo existir
TELEGRAM_SCRIPT="$(dirname "$0")/telegram_notify.sh"
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"
  TELEGRAM_ENABLED=true
else
  TELEGRAM_ENABLED=false
fi

# 📁 Define diretórios e variáveis principais
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FRONTEND_DIR="$BASE_DIR/frontend"
REPO_URL="https://github.com/ksevendev/wppconnect-frontend.git"
LOG_FILE="$BASE_DIR/update.log"

# ⏲️ Função que retorna timestamp formatado
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# 📝 Função de log com horário e gravação no arquivo
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# 📩 Função segura para enviar mensagem ao Telegram (se habilitado)
send_telegram() {
  $TELEGRAM_ENABLED && send_telegram_message "$1" "$2"
}

# ✅ Verifica se os comandos obrigatórios existem
for cmd in git npm; do
  if ! command -v $cmd &>/dev/null; then
    log "❌ $cmd não instalado. Instale antes de prosseguir."
    send_telegram "❌ Falha na Atualização do Frontend" "$cmd não instalado no sistema."
    exit 1
  fi
done

log "🔄 Atualizando frontend..."
send_telegram "🔄 Iniciando atualização do Frontend" "Repositório: $REPO_URL"

# ❗ Verifica se o diretório do frontend é válido e possui git
if [ ! -d "$FRONTEND_DIR/.git" ]; then
  log "❌ Diretório inválido: $FRONTEND_DIR"
  send_telegram "❌ Diretório Inválido" "Não encontrado .git em $FRONTEND_DIR"
  exit 1
fi

# 📌 Obtém versões do repositório
cd "$FRONTEND_DIR"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git ls-remote "$REPO_URL" "$CURRENT_BRANCH" | awk '{print $1}')

log "📌 Versão local: $LOCAL_COMMIT"
log "📌 Versão remota: $REMOTE_COMMIT"
log "🌿 Branch atual: $CURRENT_BRANCH"

send_telegram "📋 Informações do Repositório" "Branch: $CURRENT_BRANCH\nVersão local: $LOCAL_COMMIT\nVersão remota: $REMOTE_COMMIT"

# 🔍 Verifica se está atualizado
if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
  log "✅ Frontend já está atualizado."
  send_telegram "✅ Nenhuma Atualização" "O frontend já está na versão mais recente."
  exit 0
fi

# 📦 Faz backup do frontend antes da atualização
BACKUP_DIR="$BASE_DIR/_backup/frontend_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r . "$BACKUP_DIR"
log "📦 Backup realizado em $BACKUP_DIR"
send_telegram "📦 Backup Realizado" "Backup salvo em: $BACKUP_DIR"

# 🔁 Atualiza repositório e instala dependências
git pull origin "$CURRENT_BRANCH"

npm install || {
  log "❌ npm install falhou. Restaurando backup..."
  cp -r "$BACKUP_DIR"/* .
  send_telegram "❌ Erro em npm install" "Rollback executado com sucesso."
  exit 1
}

npm run build || {
  log "❌ Build falhou. Revertendo alterações..."
  cp -r "$BACKUP_DIR"/* .
  send_telegram "❌ Erro na build" "Rollback executado com sucesso."
  exit 1
}

log "✅ Frontend atualizado com sucesso!"
send_telegram "✅ Atualização Concluída" "Frontend atualizado com sucesso para a versão $(git rev-parse HEAD)."

# ⏱️ Calcula o tempo de execução
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Atualização concluída em ${DURATION} segundos."
