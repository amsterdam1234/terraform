# VPC
resource "aws_vpc" "main_vpn" {
  cidr_block = "10.0.0.0/27" # 32 IPs
  tags = {
    Name = "omer-main-vpc"
  }
}
