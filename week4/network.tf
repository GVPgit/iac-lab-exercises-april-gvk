resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"


  tags = {
    Name = format("%s-vpc", var.prefix)
  }
}
resource "aws_subnet" "pubsub" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.combined_pubsubnet_cidr, 1, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], count.index))

  tags = {
    Name = format("%s-public-subnet-%d", var.prefix, count.index + 1)
  }
}
resource "aws_subnet" "prisub" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.combined_prisubnet_cidr, 1, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], count.index))

  tags = {
    Name = format("%s-private-subnet-%d", var.prefix, count.index + 1)
  }
}
resource "aws_subnet" "secsub" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.combined_secsubnet_cidr, 1, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = format("%s%s", var.region, element(["a", "b"], count.index))

  tags = {
    Name = format("%s-private-subnet-%d", var.prefix, count.index + 1)
  }
}
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = format("%s-myigw", var.prefix)
  }
}
resource "aws_eip" "myeip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.pubsub[0].id

  tags = {
    Name = format("%s-mynat", var.prefix)
  }
}
resource "aws_route_table" "mypubrt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = format("%s-mypubrt", var.prefix)
  }
}
resource "aws_route_table" "mypvtrt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mynat.id
  }

  tags = {
    Name = format("%s-mypvtrt", var.prefix)
  }
}
resource "aws_route_table_association" "pub" {
  for_each = { for idx, subnet in aws_subnet.pubsub : idx => subnet.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.mypubrt.id
}
resource "aws_route_table_association" "pri" {
  for_each = { for idx, subnet in aws_subnet.prisub : idx => subnet.id }

  subnet_id      = each.value
  route_table_id = aws_route_table.mypvtrt.id
}


