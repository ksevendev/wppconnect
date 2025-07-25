

# Instalador WPPConnect - Backend + Frontend


## 🚀 Visão Geral

  Este projeto automatiza a instalação, configuração, atualização e desinstalação do **WPPConnect Server + Frontend** em VPS Linux, oferecendo um menu interativo via terminal para gerenciar tudo com facilidade.

O WPPConnect é uma plataforma open source para criar bots e integrações WhatsApp usando a API Web não oficial, oferecendo envio de mensagens, gerenciamento de sessões, e muito mais.

## 🔎 Sobre o WPPConnect

-  **WPPConnect** é uma biblioteca que permite criar bots no WhatsApp utilizando a API Web do WhatsApp, sem depender da API oficial.
- Possui suporte para várias funcionalidades, como envio de mensagens, envio de mídia, gerenciamento de contatos, grupos, e leitura de mensagens.
- Ideal para automações, notificações, atendimento via WhatsApp e integrações personalizadas.
- Disponível em [https://wppconnect.io](https://wppconnect.io)
- Backend construído em Node.js com uso de Puppeteer para controle do WhatsApp Web.
- Frontend para monitoramento, configuração e interação via interface gráfica.

## 📋 Requisitos

- VPS Linux (Ubuntu 20.04+ recomendado)
- Node.js 22.x (via nvm recomendado)
- Yarn instalado
- PM2 instalado globalmente para gerenciar processos Node.js
- Nginx instalado para configurar HTTPS (opcional, mas recomendado)
-  `whiptail` para menu interativo no terminal (normalmente já instalado em Ubuntu/Debian)
- Permissão sudo ou root para instalação e configuração  

## 📦 Instalação Manual Inicial


### Instalar Node.js, Yarn, PM2, whiptail:

  

```bash
sudo  apt  update && sudo  apt  upgrade  -y
```
```bash
sudo  apt  install  curl  git  build-essential  whiptail  -y
```
  

# Instalar NVM para gerenciar versões Node.js
```
curl  -o-  https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
```
```
source  ~/.bashrc
```
  

# Instalar Node.js 22.x
```
nvm  install  22
```
```
nvm  use  22
```
```
nvm  alias  default  22
```
  
# Instalar Yarn e PM2 globalmente
```
npm  install  -g  yarn  pm2
```
  

📂  Clonar  e  Executar  o  Instalador


```
cd  /opt
```
```
git  clone  https://github.com/ksevendev/wppconnect.git
```
```
cd  wppconnect
```
```
chmod  +x  wppconnect.sh
```
```
./wppconnect.sh
```
### 🧭  Menu  Interativo  do  Instalador

##### Opção  Função:
1.  Instalar  Backend  +  Frontend
2.  Atualizar  backend  e  frontend
3.  Configurar  parâmetros (token, porta,  domínio)
4.  Desinstalar  tudo
5.  Configurar  HTTPS  com  Nginx
6.  Editar  parâmetros  avançados
7.  Sair

  

### ⚙️  O  que  cada  opção  faz?

1.  **Instalar  Backend  +  Frontend**

	Clona  os  repositórios  oficiais (seu fork)
	Instala  dependências  com  yarn
	Configura  o  backend  para  rodar  via  PM2
	Configura  frontend  para  rodar  na  porta  80 (HTTP)
	Aplica  configurações  básicas  iniciais
  
2.  **Atualizar**

	Dá  pull  nos  repositórios  backend  e  frontend
	Atualiza  dependências
	Reinicia  serviços  PM2  automaticamente

3.  **Configurações**

	***Menu  para  editar:***
		Token  da  API
		Porta  do  backend
		Domínio  para  acessar  o  frontend

4.  **Desinstalar**
		
		Para  serviços
		Remove  arquivos  do  backend  e  frontend
		Limpa  configurações  e  PM2 

5.  **Configurar  HTTPS  com  Nginx**
		
	Instala  e  configura  Nginx
	Gera  certificado  Let's Encrypt (via Certbot)
	Configura proxy reverso HTTPS para backend e frontend

6. **Editar Parâmetros Avançados**
		
	Permite ajustes manuais em arquivos de configuração
	Configurações extras do WPPConnect

### 🔒 Segurança

O token da API é fundamental para autenticar requisições — mantenha-o seguro.
Configure HTTPS para proteger dados em trânsito.
Use firewall para permitir somente portas necessárias (80, 443, porta backend).

### 📖 Sobre o WPPConnect

##### Funcionalidades principais:

Envio e recebimento de mensagens texto, mídia, áudio, vídeo
Gestão de contatos e grupos
Geração e leitura de QR Code para autenticação
Webhooks para eventos WhatsApp
Multi sessão (vários bots)
Suporte a templates, etiquetas e mensagens reativas

  

##### Ideal para:

Automação de atendimento
Notificações de sistemas
Integração com CRMs
Bots de suporte e vendas

  

### 🆘 Como monitorar e gerenciar?

##### Use o PM2 para controlar o backend:
```
pm2 status
```
```
pm2 logs wppconnect-backend
```
```
pm2 restart wppconnect-backend
```
Frontend geralmente roda no navegador via domínio configurado (porta 80 ou 443)

 
### ⚠️ Dicas finais

Sempre faça backup do seu token e dados importantes
Para customizações, faça fork dos repositórios backend e frontend
Use o menu para facilitar atualizações e configurações
Mantenha seu sistema atualizado para evitar bugs e vulnerabilidades

## 📝 Referências e Recursos

-   [WPPConnect Docs](https://wppconnect.io/pt-BR/docs/)
-   [WPPConnect Server](https://github.com/ksevendev/wppconnect-server)
-   [WPPConnect Frontend](https://github.com/ksevendev/wppconnect-frontend))

