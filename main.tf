provider "aws" {
 
  region     = "us-east-1"  # Update with your desired region
}

resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"  # Update with your desired availability zone
}

resource "aws_internet_gateway" "example_gateway" {
  vpc_id = aws_vpc.example_vpc.id
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_gateway.id
  }
}

resource "aws_route_table_association" "example_association" {
  subnet_id      = aws_subnet.example_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_key_pair" "example_keypair" {
  key_name   = "example_keypair"
  public_key = file("~/.ssh/id_rsa.pub")  # Update with your public key path
}

resource "aws_security_group" "example_security_group" {
  name        = "example_security_group"
  description = "Allow SSH, HTTP, and HTTPS traffic"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_instance" "example_instance" {
  ami           = "ami-0c94855ba95c71c99"  # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example_keypair.key_name
  subnet_id     = aws_subnet.example_subnet.id
  vpc_security_group_ids = [aws_security_group.example_security_group.id]
  associate_public_ip_address = true
  tags = {
      Name = "ExempleInstance"
}

}
