output "nginx_public_ip" {
  value = aws_instance.nginx_server.public_ip
}

output "nginx_public_dns" {
  value = aws_instance.nginx_server.public_dns
}


output "ssh_private_key_path" {
  value = local_file.private_key.filename
}

output "ssh_command" {
  value = "ssh -i ${local_file.private_key.filename} ubuntu@${aws_instance.nginx_server.public_ip}"
}


// ...existing code...

output "app_server_1_private_ip" {
  value = aws_instance.app_server_1.private_ip
}

output "app_server_2_private_ip" {
  value = aws_instance.app_server_2.private_ip
}

output "ssh_command_app_1" {
  value = "ssh -i ~/.ssh/id_rsa_jump ubuntu@${aws_instance.app_server_1.private_ip}"
}

output "ssh_command_app_2" {
  value = "ssh -i ~/.ssh/id_rsa_jump ubuntu@${aws_instance.app_server_2.private_ip}"
 
}
