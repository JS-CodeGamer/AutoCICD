#! /bin/bash

if [ -z "$DOMAIN_NAME" ]; then
  DOMAIN_NAME='_'
fi

nginx_conf="
server {
  listen 80;
  server_name $DOMAIN_NAME;
  client_max_body_size 10M;

  root /ubuntu;

  location / {
    try_files \$uri \$uri/ /index.html =404;
  }

  error_page 404 /404.html;
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
