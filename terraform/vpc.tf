# Create a VPC
resource "aws_vpc" "k8svpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "k8svpc"
  }
}