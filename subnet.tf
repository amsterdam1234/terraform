#public subnet
resource "aws_subnet" "sh_subnet_1" {
  vpc_id                  = aws_vpc.main_vpn.id
  cidr_block              = "10.0.0.0/30" #4 IPs
  map_public_ip_on_launch = true          # public subnet
  availability_zone       = "us-east-1a"
}
#private subnet
resource "aws_subnet" "sh_subnet_2" {
  vpc_id                  = aws_vpc.main_vpn.id
  cidr_block              = "10.0.0.0/30" #4 IPs
  map_public_ip_on_launch = false         # private subnet
  availability_zone       = "us-east-1b"
}