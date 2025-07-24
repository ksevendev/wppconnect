#!/bin/bash

CONFIG_FILE="/opt/wppconnect-server/.env"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Criando arquivo .env básico..."
  cat >"$CONFIG_FILE" <<EOL
PORT=21465
TOKEN=INSIRA_SEU_TOKEN_AQUI
DOMAIN=SEU_DOMINIO_AQUI
EOL
fi

echo "Editando arquivo de configuração: $CONFIG_FILE"
nano "$CONFIG_FILE"
