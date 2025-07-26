#!/bin/bash
# Arquivo: main_menu.sh — Menu principal do instalador WPPConnect
# Autor: K'Seven 🦊

set -euo pipefail  # Ativa modo rigoroso para evitar erros silenciosos

# ⏱️ Inicia cronômetro para medir tempo de execução
START_TIME=$SECONDS

# Define diretórios
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"      # Caminho raiz do projeto
SCRIPTS_DIR="$BASE_DIR/scripts"                     # Caminho dos scripts auxiliares
LOG_FILE="$BASE_DIR/install.log"                    # Caminho para log de instalação

# Caminho para script de notificação Telegram (se existir)
TELEGRAM_SCRIPT="$SCRIPTS_DIR/telegram_notify.sh"

# Flag para indicar se Telegram está ativo
if [[ -f "$TELEGRAM_SCRIPT" ]]; then
  source "$TELEGRAM_SCRIPT"     # Importa funções de Telegram
  TELEGRAM_ENABLED=true
else
  TELEGRAM_ENABLED=false
fi

# Função segura para enviar mensagens Telegram se estiver habilitado
send_telegram() {
  if $TELEGRAM_ENABLED; then
    local TITLE="$1"
    local MESSAGE="${2:-}"  # ← Se $2 não for fornecido, assume string vazia
    send_telegram_message "$TITLE" "$MESSAGE"
  fi
}

# Função para timestamp formatado
TIMESTAMP() { date +"%Y-%m-%d %H:%M:%S"; }

# Loga mensagens com timestamp
log() {
  echo "[$(TIMESTAMP)] $1" | tee -a "$LOG_FILE"
}

# Aguarda Enter do usuário
pause() {
  read -rp "Pressione Enter para continuar..."
}

# Garante permissão de execução nos scripts
give_execute_permission() {
  chmod +x "$SCRIPTS_DIR"/*.sh
}

# Executa um script com validação e log
run_script() {
  local script="$1"
  log "Executando $script..."
  send_telegram "Executando $script..."
  if [ ! -x "$SCRIPTS_DIR/$script" ]; then
    log "❌ ERRO: Script $script não encontrado ou não executável."
    send_telegram "❌ ERRO: Script $script não encontrado ou não executável."
    return 1
  fi
  bash "$SCRIPTS_DIR/$script" 2>&1 | tee -a "$LOG_FILE"
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    log "❌ ERRO: Falha na execução de $script"
    send_telegram "❌ ERRO: Falha na execução de $script"
    return 1
  fi
  log "$script concluído."
  send_telegram "$script concluído."
}

# Caminho do config.sh
CONFIG_FILE="$SCRIPTS_DIR/config.sh"


# Chama o menu principal (modularizado) que fica em scripts/main_menu.sh
chamar_create_config() {
  log "🔧 Criando arquivo de configuração do instalador..."
  send_telegram "🔧 Criando arquivo de configuração do instalador..."
  bash "$SCRIPTS_DIR/create_config.sh"
}

# Verifica se existe e importa
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  log "Arquivo config.sh carregado com sucesso."
  send_telegram "⚙️ Configurações carregadas do config.sh" "O instalador iniciou com as configurações globais."
else
  log "❌ Arquivo config.sh não encontrado!"
  send_telegram "⚠️ Arquivo config.sh não encontrado!" "Favor criar o arquivo antes de rodar o instalador."
  chamar_create_config
  #exit 1
fi

# Inicia menu principal
while true; do
  OPTION=$(whiptail --title "Instalador WPPConnect" --menu "Escolha uma opção:" 20 60 12 \
    "1" "Instalar Apenas Backend" \
    "2" "Instalar Apenas Frontend" \
    "3" "Instalar Backend + Frontend" \
    "4" "Atualizar" \
    "5" "Configurações" \
    "6" "Desinstalar" \
    "7" "Configurar HTTPS com Nginx" \
    "8" "Editar Parâmetros" \
    "9" "Liberar acesso root via SSH" \
    "0" "Sair" 3>&1 1>&2 2>&3)

  give_execute_permission  # Libera execução antes de cada ação

  case $OPTION in
    1) run_script "install_backend.sh" && pause ;;
    2) run_script "install_frontend.sh" && pause ;;
    3) run_script "install_backend.sh" && run_script "install_frontend.sh" && pause ;;
    4)
      UPDATE_OPTION=$(whiptail --title "Atualizações WPPConnect" --menu "Escolha o que deseja atualizar:" 20 60 10 \
          "1" "Atualizar Instalador" \
          "2" "Atualizar Backend" \
          "3" "Atualizar Frontend" \
          "4" "Atualizar Tudo" \
          "5" "Voltar" 3>&1 1>&2 2>&3)

      give_execute_permission

      case $UPDATE_OPTION in
        1)
          log "Atualizando instalador via Git..."
          send_telegram "Atualizando instalador via Git..."
          if ! command -v git &>/dev/null; then
            log "Git não encontrado. Instale com: sudo apt install git"
            send_telegram "Git não encontrado. Instale com: sudo apt install git"
          else
            git -C "$BASE_DIR" pull origin main | tee -a "$LOG_FILE"
            chmod +x "$BASE_DIR/install.sh"
            chmod +x "$SCRIPTS_DIR"/*.sh
            log "Instalador atualizado com sucesso!"
            send_telegram "Instalador atualizado com sucesso!"
            read -p "Deseja reiniciar o instalador agora? (s/n): " REINICIAR
            [[ "$REINICIAR" =~ ^[sS]$ ]] && exec "$BASE_DIR/install.sh"
          fi
          pause ;;
        2) run_script "update_backend.sh" && pause ;;
        3) run_script "update_frontend.sh" && pause ;;
        4) run_script "update_backend.sh" && run_script "update_frontend.sh" && pause ;;
        5) log "Retornando ao menu principal..." && send_telegram "Retornando ao menu principal..." && sleep 1 ;;
        *) log "Opção inválida!" && send_telegram "Opção inválida!" && sleep 1 ;;
      esac
      ;;
    5) run_script "config.sh" && pause ;;
    6) run_script "uninstall.sh" && pause ;;
    7) run_script "setup_nginx.sh" && pause ;;
    8) run_script "set_config.sh" && pause ;;
    9)
      log "Configurando acesso root via SSH..."
      send_telegram "Configurando acesso root via SSH..."
      sudo passwd root
      sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
      sudo systemctl restart ssh
      log "Acesso root SSH liberado com sucesso!"
      send_telegram "Acesso root SSH liberado com sucesso!"
      pause ;;
    0)
      log "Saindo do instalador. Até mais!"
      send_telegram "Saindo do instalador. Até mais!"
      exit 0 ;;
    *)
      log "Opção inválida!"
      send_telegram "Opção inválida!"
      sleep 1 ;;
  esac

  
# ⏱️ Calcula o tempo de execução
DURATION=$((SECONDS - START_TIME))
log "⏱️ Tempo total: ${DURATION}s"
send_telegram "⏱️ Tempo de Execução" "Atualização concluída em ${DURATION} segundos."

done
