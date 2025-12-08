# 🚀 Load Balancer Nginx com Servidores de Aplicação na AWS

[![Terraform](https://img.shields.io/badge/Terraform-1.2+-623CE4?style=flat&logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-EC2%20%7C%20VPC%20%7C%20NAT-FF9900?style=flat&logo=amazon-aws)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-Containers-2496ED?style=flat&logo=docker)](https://www.docker.com/)

Este projeto Terraform provisiona uma infraestrutura completa na AWS com um load balancer Nginx e dois servidores de aplicação em subnets privadas. A configuração inclui VPC, subnets, grupos de segurança, NAT Gateway e instâncias EC2, tudo automatizado para deploy rápido e seguro.

## 🏗️ Arquitetura da Infraestrutura

```
┌─────────────────┐    ┌──────────────────┐
│   Internet      │────│   Nginx LB       │
│                 │    │  (Público)       │
└─────────────────┘    └──────────────────┘
                              │
                    ┌─────────┼─────────┐
                    │         │         │
            ┌───────▼───┐ ┌───▼───┐ ┌───▼───┐
            │ App Server │ │ MySQL │ │Rabbit│
            │   (Privado)│ │       │ │  MQ  │
            └────────────┘ └───────┘ └──────┘
```

### Componentes Principais

- **🌐 VPC Personalizada**: Com subnets públicas e privadas para isolamento
- **⚖️ Servidor Nginx**: Instância EC2 pública atuando como load balancer
- **🖥️ Servidores de Aplicação**: Duas instâncias privadas executando a aplicação backend
- **🌉 NAT Gateway**: Permite acesso à internet para instâncias privadas (updates, Docker pulls)
- **🔒 Grupos de Segurança**: Configurados para acesso controlado e seguro

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter:

- ✅ AWS CLI configurado com permissões adequadas
- ✅ Terraform v1.2.0 ou superior instalado
- ✅ Cliente SSH para conexão às instâncias
- ✅ Conta AWS com limites suficientes (NAT Gateway, EC2, etc.)

## 🚀 Guia de Inicialização Rápida

### 1. Clonagem do Repositório
```bash
git clone https://github.com/NapoliTech/Terraform.git
cd Terraform
```

### 2. Inicialização do Terraform
```bash
terraform init
```
*Este comando baixa os providers necessários e prepara o ambiente.*

### 3. Revisão do Plano de Execução
```bash
terraform plan
```
*Verifique as mudanças que serão aplicadas na infraestrutura.*

### 4. Aplicação da Infraestrutura
```bash
terraform apply
```
*Confirme com `yes` quando solicitado. A criação pode levar alguns minutos.*

### 5. Verificação dos Outputs
```bash
terraform output
```
*Anote os IPs públicos e comandos SSH gerados.*

## 🌐 Acesso à Aplicação

Após o deploy, acesse a aplicação através do load balancer Nginx:

- **🔗 URL Pública**: Utilize o `nginx_public_ip` ou `nginx_public_dns` dos outputs do Terraform
- **🔑 Acesso SSH**: Use os comandos SSH fornecidos nos outputs para conectar às instâncias

### Exemplo de Acesso
```bash
# Conectar ao servidor Nginx
ssh -i ./nginx-lb-key.pem ubuntu@<nginx-public-ip>

# Verificar status dos containers
docker ps
```

## ⚙️ Configuração Personalizada

### Variáveis Principais

Personalize o deploy editando `variables.tf`:

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `aws_region` | Região AWS | `us-east-1` |
| `project_name` | Prefixo para recursos | `nginx-lb` |
| `vpc_cidr` | Bloco CIDR da VPC | `10.0.0.0/16` |
| `subnet_cidr` | CIDR da subnet pública | `10.0.1.0/24` |
| `instance_type` | Tipo de instância EC2 | `t2.micro` |

### Scripts de User Data

- **`user_data/nginx.sh.tpl`**: Configura o servidor Nginx com Docker e balanceamento de carga
- **`user_data/app.sh`**: Provisiona servidores de aplicação com Docker Compose (backend, MySQL, RabbitMQ)

## 📱 Detalhes da Aplicação

A aplicação completa inclui:

- **🎨 Frontend**: Aplicação React servida pelo Nginx
- **⚙️ Backend**: API Spring Boot para lógica de negócio
- **🗄️ Banco de Dados**: MySQL para persistência de dados
- **📨 Fila de Mensagens**: RabbitMQ para comunicação assíncrona

### Endpoints da API
- `GET /`: Página inicial da aplicação
- `GET /api/*`: Endpoints da API backend (balanceados entre os dois servidores)

## 🔐 Notas de Segurança

- **🔑 Chaves SSH**: Geradas localmente e enviadas para as instâncias
- **🛡️ Grupos de Segurança**: Restringem acesso apenas ao necessário
- **🏠 Acesso Privado**: Instâncias privadas acessíveis apenas via servidor Nginx (jump host)
- **🔒 Estado do Terraform**: Protegido contra modificações simultâneas

## 🧹 Limpeza da Infraestrutura

Para remover todos os recursos criados:

```bash
terraform destroy
```

*Confirme a destruição quando solicitado. Todos os recursos serão removidos.*

## 🔧 Solução de Problemas

### Problemas Comuns

1. **❌ Limite de NAT Gateway Excedido**
   - Verifique seus limites na AWS Console
   - Solicite aumento se necessário

2. **🚫 Acesso Negado**
   - Confirme regras dos security groups
   - Verifique se a chave SSH está correta

3. **🔄 Lock do Estado Terraform**
   - Use `terraform force-unlock <lock-id>` se necessário
   - Evite modificações simultâneas

4. **🐳 Problemas com Docker**
   - Verifique logs: `docker logs <container-name>`
   - Reinicie serviços: `docker-compose restart`

### Comandos Úteis para Debug

```bash
# Ver status das instâncias
aws ec2 describe-instances --filters "Name=tag:Name,Values=nginx-lb*" --region us-east-1

# Verificar conectividade
ping <nginx-public-ip>

# Logs do Terraform
terraform apply -auto-approve 2>&1 | tee terraform.log
```

## 📊 Outputs do Terraform

O deploy gera os seguintes outputs importantes:

| Output | Descrição |
|--------|-----------|
| `nginx_public_ip` | IP público do load balancer |
| `nginx_public_dns` | DNS público do load balancer |
| `ssh_command` | Comando SSH para o servidor Nginx |
| `app_server_1_private_ip` | IP privado do primeiro app server |
| `app_server_2_private_ip` | IP privado do segundo app server |
| `ssh_private_key_path` | Caminho da chave SSH privada |

## 🤝 Contribuição

1. Faça fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

**💡 Dica**: Sempre revise o `terraform plan` antes de aplicar mudanças em produção!

Para dúvidas ou suporte, abra uma issue no repositório.



tratando erros:


╷
│ Error: importing EC2 Key Pair (nginx-lb-key): InvalidKeyPair.Duplicate: The keypair already exists        
│       status code: 400, request id: 8ed108fb-5c3e-481b-acdc-86f63ccd2f04
│
│   with aws_key_pair.generated,
│   on keypair.tf line 8, in resource "aws_key_pair" "generated":
│    8: resource "aws_key_pair" "generated" {


O erro indica que o par de chaves EC2 chamado nginx-lb-key já existe na sua conta AWS, então o Terraform não pode criar outro igual.

Para resolver, você pode:

Importar o par de chaves existente para o estado do Terraform
Execute no PowerShell:



terraform import aws_key_pair.generated nginx-lb-key