# Internet Gateway
resource "aws_internet_gateway" "omer-gateway" {
  vpc_id = aws_vpc.main_vpn.id
}
# route table for public subnet - connecting to Internet gateway
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main_vpn.id

  route {
    cidr_block = "0.0.0.0/0" # all IPs
    gateway_id = aws_internet_gateway.omer-gateway.id
  }
}
# associate the route table with the public subnet
resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_public.id
}

# route table for private subnet
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.main_vpn.id
}
# associate the route table with the private subnet
resource "aws_route_table_association" "route_table_association_private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table_private.id
}

# Elastic IP for NAT gateway (static ip address for the NAT gateway)
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.omer-gateway]
  domain     = "vpc"
  tags       = {
    Name = "EIP_for_NAT"
  }
}

# NAT gateway for private subnets
# (for the private subnet ec2 to access internet)
resource "aws_nat_gateway" "omer-nat-gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id # nat should be in public subnet
  tags          = {
    Name = "NAT for private subnet"
  }
  depends_on = [aws_internet_gateway.omer-gateway]
}

# route table - connecting to NAT
resource "aws_route_table" "route_table_nat" {
  vpc_id = aws_vpc.main_vpn.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.omer-nat-gateway.id
  }
}

# associate the route table with private subnet
resource "aws_route_table_association" "route_table_association_nat" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table_nat.id
}

