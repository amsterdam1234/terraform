# Launch template
resource "aws_launch_template" "ec2_launch_template" {
  name_prefix   = "omer_ec2_launch_template"
  instance_type = "t2.micro"
  image_id      = "ami-00c39f71452c08778"
  key_name      = aws_key_pair.omer_key.key_name
  user_data     = filebase64("userdata.sh") #encode it in base64, and provide it as the initialization script
  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.private_subnet.id
    security_groups             = [aws_security_group.omer_ec2_sg.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags          = {
      Name = "omer-instance" # Name for the EC2 instances
    }
  }
}