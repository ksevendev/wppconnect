#!/bin/bash
# config.sh — Variáveis globais de configuração do WPPConnect
# Autor: K'Seven 🦊

# 🔧 Nome do processo no PM2
PM2NAME="wppconnectserver"

# 🔧 Configurações de domínio/URL
APP_DOMAIN="wpp.kseven.com.br"
USE_HTTPS=true

# WPP Server
SECRET_KEY="sua-chave-secreta-super-segura"
deviceName=WppConnect
poweredBy=WPPConnect-Server
linkPreviewApiServers=null

# 🔒 Segurança
JWT_SECRET="sua-chave-secreta-super-segura"

# ⚙️ Portas
BACKEND_PORT=21465
FRONTEND_PORT=80

# 📲 Notificações
TELEGRAM_BOT_TOKEN="SEU_TOKEN_AQUI"
TELEGRAM_CHAT_ID="SEU_CHAT_ID_AQUI"
