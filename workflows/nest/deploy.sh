#! /bin/bash

# Ensure correct version of node is installed
if [ -z "$NODE_VER" ]; then
  NODE_VER="--lts"
fi

# Ensure correct domain name is set
if [ -z "$DOMAIN_NAME" ]; then
  DOMAIN_NAME="_"
fi

# Run NVM if not runing
# And Install NVM if not installed
if ! command -v nvm >/dev/null; then
  if [ ! -f "~/.nvm/nvm.sh" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  fi
  . ~/.nvm/nvm.sh
fi

# Install required version of node and pm2
nvm install $NODE_VER
nvm use $NODE_VER

# Install pm2 if not installed
# Else stop server and flush logs
if ! command -v pm2 >/dev/null; then
  npm i -g pm2
else
  pm2 flush
  pm2 kill
fi

# Delete and set environment variables
rm -rf node_modules
export NODE_ENV=production
if [ -f .env ]; then
  export $(cat .env | xargs)
fi

# Install dependencies and start server
if [ -f "yarn.lock" ]; then
  if ! command -v yarn >/dev/null; then
    npm i -g yarn
  fi
  yarn install --frozen-lockfile
  pm2 start yarn --name backend --update-env -- start:prod
else
  npm ci --force
  pm2 start npm --name backend --update-env -- run start:prod
fi

nginx_conf="
server {
  listen 80;
  server_name $DOMAIN_NAME;
  client_max_body_size 10M;

  location / {
    proxy_pass http://localhost:3000;
  }
}
"

if ! command -v nginx >/dev/null; then
  sudo apt-get update
  sudo apt-get install -y nginx
fi

sudo -u root bash -c "echo '$nginx_conf' >/etc/nginx/sites-available/default"

if systemctl is-active -q nginx; then
  sudo systemctl restart nginx
else
  sudo systemctl enable --now nginx
fi

EMAIL="harshit@heliverse.com"

# Install and configure certbot
if ! command -v certbot >/dev/null; then
  sudo apt update
  sudo apt install snapd -y
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot
fi

sudo certbot --nginx --non-interactive --agree-tos --redirect --email $EMAIL --domains $DOMAIN_NAME
