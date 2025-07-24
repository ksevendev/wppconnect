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
  OPTION=$(whiptail --title "Instalador WPPConnect" --menu "Escolha uma opção:" 20 60 10 \
    "1" "Instalar Backend + Frontend" \
    "2" "Atualizar" \
    "3" "Configurações" \
    "4" "Desinstalar" \
    "5" "Configurar HTTPS com Nginx" \
    "6" "Editar Parâmetros" \
    "7" "Sair" 3>&1 1>&2 2>&3)

  # Sempre liberar permissão antes de rodar
  give_execute_permission

  case $OPTION in
    1)
      bash "$SCRIPTS_DIR/install_backend.sh"
      bash "$SCRIPTS_DIR/install_frontend.sh"
      ;;
    2)
      bash "$SCRIPTS_DIR/update.sh"
      ;;
    3)
      bash "$SCRIPTS_DIR/config.sh"
      ;;
    4)
      bash "$SCRIPTS_DIR/uninstall.sh"
      ;;
    5)
      bash "$SCRIPTS_DIR/setup_nginx.sh"
      ;;
    6)
      bash "$SCRIPTS_DIR/set_config.sh"
      ;;
    7)
      echo "Saindo..."
      exit 0
      ;;
    *)
      echo "Opção inválida!"
      sleep 2
      ;;
  esac
done
