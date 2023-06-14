# 1. Create tgw
# 2. Create VPC attachments to tgw (tgw attachments)
# 3. create tgw rt
# 4. Create routes in the tgw RT tht says 
#     4.1 Add routes in vpc RTs to point to corresponding tgw attachments
#     4.2 In tgw RT, for each spoke CIDR, 
#         go to the corresponding tgw attachments
# 5. create tgw rt association to each tgw attachments
    # Note: you have to associate tgw rt to all tgw attachments 
    # else, ping wont work


# 1
resource "aws_ec2_transit_gateway" "tgw" {
#   count = local.create_tgw ? 1 : 0
  provider = aws.virginia
  description                     = "Transit_Gateway"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "disable"
  dns_support                     = "enable"
  multicast_support               = "disable"
  transit_gateway_cidr_blocks     = []
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "chrisTGW"
    Createdby = "Chris"
    Env = "dev"
  }
}

# 2
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke1_TGW_attach" {
#   count = var.transit_gateway_vpc_attachment_count
  provider = aws.virginia
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id = module.spoke1.my_vpc_id
  subnet_ids = [module.spoke1.public_subnet_a_id, ]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
      Name = "spoke1_TGW_attach"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke2_TGW_attach" {
#   count = var.transit_gateway_vpc_attachment_count
  provider = aws.virginia
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id = module.spoke2.my_vpc_id
  subnet_ids = [module.spoke2.public_subnet_a_id, ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
      Name = "spoke2_TGW_attach"
  }
}

# 3
resource "aws_ec2_transit_gateway_route_table" "tgw_route_table" {
  provider = aws.virginia
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  tags = {
    Name = "tgw-RT"
  }
}

# 4
resource "aws_ec2_transit_gateway_route" "To_spoke2_routing_tgw" {
  provider = aws.virginia
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke2_TGW_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}
resource "aws_ec2_transit_gateway_route" "To_spoke1_routing_tgw" {
  provider = aws.virginia
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke1_TGW_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}


# 5
resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_spoke1_Attach" {
  provider = aws.virginia
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke1_TGW_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw_route_table_spoke2_Attach" {
  provider = aws.virginia
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke2_TGW_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}

# ------------------- INTER REGION -----------------------------
# TGW peering route

resource "aws_ec2_transit_gateway_route" "spoke1-To_spoke3-via_TGW-Peering_routing" {
  provider = aws.virginia
  destination_cidr_block         = "10.3.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peer.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}
resource "aws_ec2_transit_gateway_route_table_association" "tgwPeering_route_table_assoc" {
  provider = aws.virginia
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peer.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_route_table.id
}