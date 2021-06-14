resource "aws_vpc" "k8s-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "k8s"
  }
}

resource "aws_subnet" "k8s-subnet" {
  vpc_id            = aws_vpc.k8s-vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "k8s"
  }
}

resource "aws_internet_gateway" "k8s-igw" { #1
  vpc_id = aws_vpc.k8s-vpc.id

  tags = {
    Environment = "k8s"
  }
}

resource "aws_route_table" "public" { #2
  vpc_id = aws_vpc.k8s-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-igw.id
  }
  tags = {
    Environment = "k8s"
  }
}

resource "aws_route_table_association" "public" { #3
  subnet_id      = aws_subnet.k8s-subnet.id
  route_table_id = aws_route_table.public.id
}

