# INTERNET GATEWAY - ROUTE TABLE
resource "aws_route_table" "public_to_internet_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  route {
    cidr_block = "10.1.0.0/16"
    gateway_id = aws_vpc_peering_connection.Hub-spoke1-Peering.id
  }

      route {
    cidr_block = "10.2.0.0/16"
    gateway_id = aws_vpc_peering_connection.Hub-spoke2-Peering.id
  }
    lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "internet-gateway-route-table"
  }
}

resource "aws_route_table" "private_to_public_subnet_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
  # route {
  #   cidr_block = "10.1.0.0/16"
  #   nat_gateway_id = aws_vpc_peering_connection.Hub-spoke1-Peering.id
  # }

    lifecycle {
    ignore_changes = [
      route,
    ]
  }

  tags = {
    Name = "private-to-public"
  }
}

# ASSOCIATION TO SUBNET PUBLIC A
resource "aws_route_table_association" "igw_for_public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_to_internet_rt.id
}

# ASSOCIATION TO SUBNET PRIVATE A
resource "aws_route_table_association" "private_rt_for_public_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_to_public_subnet_rt.id
}