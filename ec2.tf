data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "nginx_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = aws_key_pair.generated.key_name

  user_data = templatefile("${path.module}/user_data/nginx.sh.tpl", {
    app1_ip = aws_instance.app_server_1.private_ip,
    app2_ip = aws_instance.app_server_2.private_ip
  })

  tags = {
    Name = "${var.project_name}-nginx"
  }

  depends_on = [
    aws_instance.app_server_1,
    aws_instance.app_server_2
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
    host        = self.public_ip
    timeout     = "2m"
  }

  provisioner "file" {
    content     = tls_private_key.ssh_key.private_key_pem
    destination = "/home/ubuntu/nginx-lb-key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/.ssh",
      "mv /home/ubuntu/nginx-lb-key.pem /home/ubuntu/.ssh/id_rsa_jump",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa_jump",
      "chmod 600 /home/ubuntu/.ssh/id_rsa_jump",
      "cat >> /home/ubuntu/.ssh/config <<'SSHCONF'\nHost *\n  StrictHostKeyChecking no\n  UserKnownHostsFile=/dev/null\nSSHCONF",
      "chown ubuntu:ubuntu /home/ubuntu/.ssh/config",
      "chmod 600 /home/ubuntu/.ssh/config"
    ]
  }
}

resource "aws_instance" "app_server_1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.generated.key_name

  user_data = file("${path.module}/user_data/app.sh")

  tags = {
    Name = "${var.project_name}-app-1"
  }
}

resource "aws_instance" "app_server_2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.private_2.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.generated.key_name

  user_data = file("${path.module}/user_data/app.sh")

  tags = {
    Name = "${var.project_name}-app-2"
  }
}
