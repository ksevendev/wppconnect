#!/bin/bash

CONFIG_FILE="/opt/wppconnect-server/.env"

# Cria arquivo se não existir
if [ ! -f "$CONFIG_FILE" ]; then
  cat >"$CONFIG_FILE" <<EOL
PORT=21465
TOKEN=INSIRA_SEU_TOKEN_AQUI
DOMAIN=SEU_DOMINIO_AQUI
EOL
fi

# Carrega as variáveis do arquivo
source "$CONFIG_FILE"

while true; do
  OPTION=$(whiptail --title "Configuração WPPConnect" --menu "Escolha o que deseja alterar:" 15 60 4 \
    "1" "TOKEN (Token de segurança da API)" \
    "2" "PORT (Porta do backend)" \
    "3" "DOMAIN (Domínio do frontend/backend)" \
    "4" "Salvar e sair" 3>&1 1>&2 2>&3)

  case $OPTION in
    1)
      NEW_TOKEN=$(whiptail --inputbox "Informe o novo TOKEN:" 8 60 "$TOKEN" 3>&1 1>&2 2>&3)
      [ $? -eq 0 ] && TOKEN="$NEW_TOKEN"
      ;;
    2)
      NEW_PORT=$(whiptail --inputbox "Informe a nova PORTA:" 8 60 "$PORT" 3>&1 1>&2 2>&3)
      [ $? -eq 0 ] && PORT="$NEW_PORT"
      ;;
    3)
      NEW_DOMAIN=$(whiptail --inputbox "Informe o novo DOMÍNIO:" 8 60 "$DOMAIN" 3>&1 1>&2 2>&3)
      [ $? -eq 0 ] && DOMAIN="$NEW_DOMAIN"
      ;;
    4)
      # Salva as alterações no arquivo .env
      cat >"$CONFIG_FILE" <<EOL
PORT=$PORT
TOKEN=$TOKEN
DOMAIN=$DOMAIN
EOL
      echo "Configurações salvas em $CONFIG_FILE"
      sleep 1
      break
      ;;
    *)
      whiptail --msgbox "Opção inválida!" 8 40
      ;;
  esac
done
