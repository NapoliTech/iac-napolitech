#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io docker-compose nginx
systemctl enable docker
systemctl start docker


mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

cat > docker-compose.yml <<'EOL'
version: "3.8"

services:
  frontend:
    image: alejandrocastor/admin:0.0.3
    container_name: frontend-app
    restart: always
    ports:
      - "3001:80"
EOL

docker-compose up -d

# configura nginx com os IPs passados pelo template
cat > /etc/nginx/sites-available/default <<'NGINX'
upstream backend {
    server ${app1_ip}:8080;
    server ${app2_ip}:8080;
}

upstream frontend {
    server 127.0.0.1:3001;
}

server {
    listen 80 default_server;
    server_name _;

    location /api {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location / {
        proxy_pass http://frontend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX

systemctl restart nginx
