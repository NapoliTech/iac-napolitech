# ============================
# 🌐 NGINX ADMIN SERVER
# ============================
output "nginx_admin_public_ip" {
  value       = aws_instance.nginx_server_admin.public_ip
  description = "------ IP Público do Nginx Admin ------"
}

output "nginx_admin_public_dns" {
  value       = aws_instance.nginx_server_admin.public_dns
  description = "------ DNS Público do Nginx Admin ------"
}

output "ssh_command_admin" {
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.nginx_server_admin.public_ip}"
  description = "------ Comando SSH para acessar o Nginx Admin ------"
}

# ----------------------------
# 🖥️ APP SERVERS ADMIN
# ----------------------------
output "app_server_1_admin_private_ip" {
  value       = aws_instance.app_server_1_admin.private_ip
  description = "------ IP Privado do App Server 1 Admin ------"
}

output "app_server_2_admin_private_ip" {
  value       = aws_instance.app_server_2_admin.private_ip
  description = "------ IP Privado do App Server 2 Admin ------"
}

output "ssh_command_app_1_admin" {
  value       = "ssh -i ~/.ssh/id_rsa_jump ubuntu@${aws_instance.app_server_1_admin.private_ip}"
  description = "------ SSH para App Server 1 Admin via Jump ------"
}

output "ssh_command_app_2_admin" {
  value       = "ssh -i ~/.ssh/id_rsa_jump ubuntu@${aws_instance.app_server_2_admin.private_ip}"
  description = "------ SSH para App Server 2 Admin via Jump ------"
}


# ============================
# 🌐 NGINX ORIGINAL SERVER
# ============================
output "nginx_public_ip" {
  value       = aws_instance.nginx_server.public_ip
  description = "------ IP Público do Nginx Original ------"
}

output "nginx_public_dns" {
  value       = aws_instance.nginx_server.public_dns
  description = "------ DNS Público do Nginx Original ------"
}

output "ssh_command" {
  value       = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.nginx_server.public_ip}"
  description = "------ Comando SSH para acessar o Nginx Original ------"
}

# ----------------------------
# 🖥️ APP SERVERS ORIGINAL
# ----------------------------
output "app_server_1_private_ip" {
  value       = aws_instance.app_server_1.private_ip
  description = "------ IP Privado do App Server 1 Original ------"
}

output "app_server_2_private_ip" {
  value       = aws_instance.app_server_2.private_ip
  description = "------ IP Privado do App Server 2 Original ------"
}

output "ssh_command_app_1" {
  value       = "ssh -i ~/.ssh/id_rsa_jump ubuntu@${aws_instance.app_server_1.private_ip}"
  description = "------ SSH para App Server 1 Original via Jump ------"
}

output "ssh_command_app_2" {
  value       = "ssh -i ~/.ssh/id_rsa_jump ubuntu@${aws_instance.app_server_2.private_ip}"
  description = "------ SSH para App Server 2 Original via Jump ------"
}


# ============================
# 🔑 SSH CONFIG
# ============================
output "ssh_private_key_path" {
  value       = local_file.private_key.filename
  description = "------ Caminho para a chave privada SSH ------"
}
