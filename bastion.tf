resource "aws_instance" "bastion" {
  ami           = "ami-00c39f71452c08778" # replace with the correct AMI ID for your region
  instance_type = "t2.micro"
  key_name = aws_key_pair.omer_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id = aws_subnet.public_subnet.id # replace with your public subnet ID
  tags = {
    Name = "BastionHost"
  }
}

resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = aws_vpc.main_vpn.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}