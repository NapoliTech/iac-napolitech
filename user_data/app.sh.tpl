#!/bin/bash
set -e

LOG_FILE="/var/log/app_install.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "=== Iniciando instalação (com logs em $LOG_FILE) ==="

# Espera interface de rede
echo "Aguardando interface de rede ficar ativa..."
for i in {1..30}; do
  if ip route get 8.8.8.8 >/dev/null 2>&1; then
    echo "Interface ativa!"
    break
  fi
  echo "Interface ainda não disponível... tentativa $i"
  sleep 5
done

echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

echo "=== Instalando dependências e Docker ==="
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release git openssh-server openssh-client

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
 https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
systemctl enable ssh
systemctl start ssh

usermod -aG docker ubuntu

mkdir -p /home/ubuntu/app
chown ubuntu:ubuntu -R /home/ubuntu/app
cd /home/ubuntu/app

echo "=== Aguardando o banco de dados ${db_host}:${db_port} ficar acessível ==="
count=0
until bash -c "</dev/tcp/${db_host}/${db_port}" >/dev/null 2>&1; do
  count=$((count+1))
  echo "Banco ainda não acessível... tentativa $count"
  if [ $count -ge 120 ]; then
    echo "Banco não ficou pronto após muitas tentativas. Abortando."
    exit 1
  fi
  sleep 5
done
echo "Banco acessível, seguindo com deploy Docker Compose"

cat > docker-compose.yml <<'EOL'
version: "3.8"

networks:
  network-napolitech:
    driver: bridge

services:
  backend:
    image: napolitech/backend-napolitech-dev:1.1.0
    container_name: backend-napolitech
    ports:
      - "8080:8080"
    environment:
      SPRING_PROFILES_ACTIVE: prod
      SPRING_APPLICATION_NAME: back-end-napolitech
      DATASOURCE_URL: jdbc:mysql://${db_host}:${db_port}/${db_name}?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true
      DATASOURCE_USERNAME: ${db_username}
      DATASOURCE_PASSWORD: ${db_password}
      DATASOURCE_DRIVER: com.mysql.cj.jdbc.Driver
      SERVER_PORT: "8080"
      MAIL_HOST: "smtp.gmail.com"
      MAIL_PORT: "587"
      MAIL_USERNAME: "mailsendernoreplyv8@gmail.com"
      MAIL_PASSWORD: "gycihyclbdscmhor"
      MAIL_SMTP_AUTH: "true"
      MAIL_SMTP_STARTTLS: "true"
      RABBITMQ_HOST: "rabbitmq"
      RABBITMQ_PORT: "5672"
      RABBITMQ_DEFAULT_USER: "admin"
      RABBITMQ_DEFAULT_PASS: "napolitech"
      BROKER_EXCHANGE_NAME: "napolitech-exchange"
      BROKER_QUEUE_NAME: "pedidos-queue"
      BROKER_ROUTING_KEY: "pedidos-routing-key"
    depends_on:
      rabbitmq:
        condition: service_healthy
    networks:
      - network-napolitech

  rabbitmq:
    image: rabbitmq:3.13-management
    container_name: rabbitmq-napolitech
    restart: always
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      RABBITMQ_DEFAULT_USER: admin
      RABBITMQ_DEFAULT_PASS: napolitech
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    healthcheck:
      test: ["CMD-SHELL", "rabbitmqctl node_health_check"]
      interval: 10s
      timeout: 10s
      retries: 10
      start_period: 20s
    networks:
      - network-napolitech

volumes:
  rabbitmq_data:
EOL

echo "=== Subindo containers ==="

docker compose down || true
docker compose up -d

echo "=== Finalizado! Logs em $LOG_FILE ==="
