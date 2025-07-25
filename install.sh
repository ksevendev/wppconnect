#!/bin/bash

# Caminho base
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"

# Função para garantir permissão executável nos scripts
give_execute_permission() {
  chmod +x "$SCRIPTS_DIR"/*.sh
}

# Menu inicial
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
    
  # Sempre liberar permissão antes de rodar
  give_execute_permission

  case $OPTION in
    1)
      bash "$SCRIPTS_DIR/install_backend.sh"
      ;;
    2)
      bash "$SCRIPTS_DIR/install_frontend.sh"
      ;;
    3)
      bash "$SCRIPTS_DIR/install_backend.sh"
      bash "$SCRIPTS_DIR/install_frontend.sh"
      ;;
    4)
      bash "$SCRIPTS_DIR/update.sh"
      ;;
    5)
      bash "$SCRIPTS_DIR/config.sh"
      ;;
    6)
      bash "$SCRIPTS_DIR/uninstall.sh"
      ;;
    7)
      bash "$SCRIPTS_DIR/setup_nginx.sh"
      ;;
    8)
      bash "$SCRIPTS_DIR/set_config.sh"
      ;;
    9)
      echo "🔐 Configurando acesso root via SSH..."
      sudo passwd root
      sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
      sudo systemctl restart ssh
      echo "✅ Acesso root SSH liberado com sucesso!"
      read -p "Pressione Enter para continuar..."
      ;;
    0)
      echo "👋 Saindo..."
      exit 0
      ;;
    *)
      echo "🚫 Opção inválida!"
      sleep 2
      ;;
  esac
done
