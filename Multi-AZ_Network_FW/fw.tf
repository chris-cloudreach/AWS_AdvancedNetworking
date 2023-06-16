data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "FW-VPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.example.id
   tags = {
    Name = "IGW"
  }

}

resource "aws_subnet" "applicationAz1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.example.id
   tags = {
    Name = "APP-Az1-subnet"
  }
}

resource "aws_subnet" "applicationAz2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.example.id
   tags = {
    Name = "APP-Az2-subnet"
  }
}

resource "aws_subnet" "FW-subnet-Az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.example.id
   tags = {
    Name = "FW-subnet-Az1"
  }
}
resource "aws_subnet" "FW-subnet-Az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.3.0/24"
  vpc_id = aws_vpc.example.id
   tags = {
    Name = "FW-Az2-subnet"
  }
}

resource "aws_networkfirewall_rule_group" "example" {
  capacity = 1000
  name = "example"
  type = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 5
          rule_definition {
            actions = ["aws:pass"]
            match_attributes {
              source {
                address_definition = "10.0.0.0/8"
              }
               source {
                address_definition = "192.168.0.0/16"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

resource "aws_networkfirewall_firewall_policy" "example" {
  name = "example"
  firewall_policy {
    stateless_default_actions = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]
    stateless_rule_group_reference {
      priority = 20
      resource_arn = aws_networkfirewall_rule_group.example.arn
    }
  }
}

resource "aws_networkfirewall_firewall" "NetworkFireWall" {
  firewall_policy_arn = aws_networkfirewall_firewall_policy.example.arn
  name = "NetworkFireWall"
  vpc_id = aws_vpc.example.id
  subnet_mapping {
    subnet_id = aws_subnet.FW-subnet-Az1.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.FW-subnet-Az2.id
  }
}
# NEED JUST 1 FW FOR MULTIPLE AZs

# resource "aws_networkfirewall_firewall" "NetworkFireWall-Az2" {
#   firewall_policy_arn = aws_networkfirewall_firewall_policy.example.arn
#   name = "NetworkFireWall-Az2"
#   vpc_id = aws_vpc.example.id
#   subnet_mapping {
#     subnet_id = aws_subnet.FW-subnet-Az2.id
#   }
# }


resource "aws_route_table" "FWSubnetRT" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  # route {  
    # This route is added automatically when u associate to subnets
  #   cidr_block = "10.0.0.0/16"
  #   gateway_id = local
  # }
      tags = {
    Name = "FWSubnetRT"
  }
}
resource "aws_route_table_association" "FW-subnetRT-AssocAz1" {
  route_table_id = aws_route_table.FWSubnetRT.id
  subnet_id = aws_subnet.FW-subnet-Az1.id
}
resource "aws_route_table_association" "FW-subnetRT-AssocAz2" {
  route_table_id = aws_route_table.FWSubnetRT.id
  subnet_id = aws_subnet.FW-subnet-Az2.id
}

resource "aws_network_interface" "applicationAz1-ENI" {
  subnet_id = aws_subnet.applicationAz1.id
   tags = {
    Name = "APP-Az1-ENI"
  }
}
resource "aws_network_interface" "applicationAz2-ENI" {
  subnet_id = aws_subnet.applicationAz2.id
   tags = {
    Name = "APP-Az2-ENI"
  }
}


data "aws_network_interface" "applicationAz1-ENI" {
  id = aws_network_interface.applicationAz1-ENI.id
}
data "aws_network_interface" "applicationAz2-ENI" {
  id = aws_network_interface.applicationAz2-ENI.id
}

resource "aws_route_table" "applicationAz1-RT" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"   
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.NetworkFireWall.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == "${aws_subnet.FW-subnet-Az1.id}" ], 0)
        # vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.NetworkFireWall.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id ], 0)

  }
      tags = {
    Name = "APP-Az1-RT"
  }
}
resource "aws_route_table" "applicationAz2-RT" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.NetworkFireWall.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == "${aws_subnet.FW-subnet-Az2.id}" ], 0)
  }
      tags = {
    Name = "APP-Az2-RT"
  }
}

resource "aws_route_table_association" "applicationAz1" {
  route_table_id = aws_route_table.applicationAz1-RT.id
  subnet_id = aws_subnet.applicationAz1.id
}
resource "aws_route_table_association" "applicationAz2" {
  route_table_id = aws_route_table.applicationAz2-RT.id
  subnet_id = aws_subnet.applicationAz2.id
}

resource "aws_route_table" "gateway" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = aws_subnet.applicationAz1.cidr_block
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.NetworkFireWall.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == "${aws_subnet.FW-subnet-Az1.id}" ], 0)
  }
  route {
    cidr_block = aws_subnet.applicationAz2.cidr_block
    vpc_endpoint_id = element([for ss in tolist(aws_networkfirewall_firewall.NetworkFireWall.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == "${aws_subnet.FW-subnet-Az2.id}" ], 0)
  }
      tags = {
    Name = "IGW-RT"
  }
}

resource "aws_route_table_association" "gateway" {
  gateway_id = aws_internet_gateway.IGW.id
  route_table_id = aws_route_table.gateway.id
}