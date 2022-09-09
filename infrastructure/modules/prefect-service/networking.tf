data "aws_availability_zone" "az" {
  name = "${local.account_region}a"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {}

resource "aws_internet_gateway_attachment" "gw_attachement" {
  vpc_id              = aws_vpc.vpc.id
  internet_gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "route_to_gw" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.gw.id
  depends_on                = [aws_internet_gateway_attachment.gw_attachement]
}

resource "aws_subnet" "service_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/16"
  availability_zone = data.aws_availability_zone.az.name
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

resource "aws_route_table_association" "service_subnet_public_route_association" {
  subnet_id      = aws_subnet.service_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
