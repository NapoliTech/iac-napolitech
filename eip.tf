resource "aws_eip" "nat_eip" {
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}
