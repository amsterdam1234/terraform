#public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpn.id
  cidr_block              = "10.0.0.0/28" #16 IPs
  map_public_ip_on_launch = true          # public subnet (ensures that instances launched in that subnet automatically receive a public IP address.)
  availability_zone       = "us-east-1a"
  tags = {
    Name = "omer-public-subnet"
  }
}
#private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpn.id
  cidr_block              = "10.0.0.16/28" #16 IPs
  map_public_ip_on_launch = false         # private subnet
  availability_zone       = "us-east-1b"
    tags = {
        Name = "omer-private-subnet"
    }
}