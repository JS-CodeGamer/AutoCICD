#! /bin/bash

set -e

if [ ! -z "$1" ]; then
  JAVA_VER=$1
elif [ -z "$JAVA_VER" ]; then
  JAVA_VER=20
fi

if [ -z "$DOMAIN_NAME" ]; then
  DOMAIN_NAME='_'
fi

service_file="
[Unit]
Description=webserver Daemon

[Service]
ExecStart=find /home/ubuntu/target -name *.jar -exec java -jar {} \;
User=ubuntu

[Install]
WantedBy=multi-user.target
"

if ! command -v java >/dev/null; then
  sudo apt-get update
  sudo apt install -y "openjdk-${JAVA_VER}-jre"
fi

if [ ! -f '/usr/lib/systemd/system/webserver.service' ]; then
  sudo -u root bash -c "echo '$service_file' >/usr/lib/systemd/system/webserver.service"
fi

if systemctl is-active -q webserver; then
  sudo systemctl restart webserver
else
  sudo systemctl enable --now webserver
fi

nginx_conf="
server {
  listen 80;
  server_name $DOMAIN_NAME;
  client_max_body_size 10M;

  location / {
    proxy_pass http://localhost:8088;
  }
}
"

if ! command -v nginx >/dev/null; then
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
