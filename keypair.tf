resource "aws_key_pair" "omer_key" {
  key_name   = "omer_key"
  public_key = file("~/.ssh/id_rsa.pub")
}