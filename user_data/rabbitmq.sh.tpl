#!/bin/bash
set -e

LOG_FILE="/var/log/rabbitmq_install.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "=== Iniciando instalação RabbitMQ (logs em $LOG_FILE) ==="

# Espera interface de rede
for i in {1..30}; do
  if ip route get 8.8.8.8 >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "Instalando dependências e Docker..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
 https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker || true

# Cria diretório para dados
mkdir -p /var/lib/rabbitmq

# Inicia o container RabbitMQ
docker rm -f rabbitmq-napolitech >/dev/null 2>&1 || true

docker run -d \
  --name rabbitmq-napolitech \
  --restart unless-stopped \
  -p 5672:5672 \
  -p 15672:15672 \
  -e RABBITMQ_DEFAULT_USER=${rabbitmq_user} \
  -e RABBITMQ_DEFAULT_PASS=${rabbitmq_pass} \
  -v /var/lib/rabbitmq:/var/lib/rabbitmq \
  rabbitmq:3.13-management || true

# Espera o RabbitMQ ficar pronto
count=0
until docker exec rabbitmq-napolitech rabbitmqctl node_health_check >/dev/null 2>&1; do
  count=$((count+1))
  if [ $count -ge 60 ]; then
    echo "RabbitMQ não iniciou a tempo"
    exit 1
  fi
  sleep 2
done

echo "RabbitMQ inicializado com usuário: ${rabbitmq_user}"

echo "=== Finalizado! ==="