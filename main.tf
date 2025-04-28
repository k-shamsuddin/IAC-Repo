resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "iac_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "iac_igw"
  }
}

resource "aws_route_table" "pvtrt" {
  vpc_id = aws_vpc.mainvpc.id



  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "iac_pvtrt"
  }
}

resource "aws_route_table" "pubrt" {
  vpc_id = aws_vpc.mainvpc.id


  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "iac_pubrt"
  }
}

resource "aws_subnet" "pvtsn" {
  vpc_id     = aws_vpc.mainvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "iac_pvtsn"
  }
}

resource "aws_subnet" "pubsn" {
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "iac_pubsn"
  }
}

resource "aws_route_table_association" "pvtsn-pvtrt" {
  subnet_id      = aws_subnet.pvtsn.id
  #gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.pvtrt.id

}
resource "aws_route_table_association" "pubsn-pubrt" {
  subnet_id      = aws_subnet.pubsn.id
  #gateway_id     = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.pubrt.id
}





data "aws_ami" "here" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

}
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILRIi8wPRMppk0ChISelRlV138VWhsRhxHb5YqabllW0 shamsuddin@LAPTOP-FE6SCP8J"
}



resource "aws_instance" "web" {
  ami             = data.aws_ami.here.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.pubsn.id
  security_groups = [aws_security_group.sg.id]
  key_name        = aws_key_pair.mykey.id

  tags = {
    Name = "iac_ec2"
  }
}
resource "aws_security_group" "sg" {
  name        = "iac_ec2_sg"
  description = "Allow TLS inbound 22 and all outbound traffic"
  vpc_id      = aws_vpc.mainvpc.id


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

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


  tags = {
    Name = "iac_ec2_sg"
  }
}
