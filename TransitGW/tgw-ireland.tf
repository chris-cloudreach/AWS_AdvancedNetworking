# 1. Create tgw-ireland
# 2. Create VPC attachments to tgw-ireland (tgw-ireland attachments)
# 3. create tgw-ireland rt
# 4. Create routes in the tgw-ireland RT tht says 
#     4.1 Add routes in vpc RTs to point to corresponding tgw-ireland attachments
#     4.2 In tgw-ireland RT, for each spoke CIDR, 
#         go to the corresponding tgw-ireland attachments
# 5. create tgw-ireland rt association to each tgw-ireland attachments
    # Note: you have to associate tgw-ireland rt to all tgw-ireland attachments 
    # else, ping wont work


# 1
resource "aws_ec2_transit_gateway" "tgw-ireland" {
#   count = local.create_tgw-ireland ? 1 : 0
  provider = aws
  description                     = "Transit_Gateway_Ireland"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = "disable"
  dns_support                     = "enable"
  multicast_support               = "disable"
  transit_gateway_cidr_blocks     = []
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "christgw-ireland"
    Createdby = "Chris"
    Env = "dev"
  }
}

# 2
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke3_tgw-ireland_attach" {
#   count = var.transit_gateway_vpc_attachment_count
  provider = aws
  transit_gateway_id = aws_ec2_transit_gateway.tgw-ireland.id
  vpc_id = module.spoke3.my_vpc_id
  subnet_ids = [module.spoke3.public_subnet_a_id, ]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = {
      Name = "spoke3_tgw-ireland_attach"
  }
}

# resource "aws_ec2_transit_gateway_vpc_attachment" "spoke2_tgw-ireland_attach" {
# #   count = var.transit_gateway_vpc_attachment_count
#   provider = aws
#   transit_gateway_id = aws_ec2_transit_gateway.tgw-ireland.id
#   vpc_id = module.spoke2.my_vpc_id
#   subnet_ids = [module.spoke2.public_subnet_a_id, ]

#   transit_gateway_default_route_table_association = false
#   transit_gateway_default_route_table_propagation = false

#   tags = {
#       Name = "spoke2_tgw-ireland_attach"
#   }
# }

# 3
resource "aws_ec2_transit_gateway_route_table" "tgw-ireland_route_table" {
  provider = aws
  transit_gateway_id = aws_ec2_transit_gateway.tgw-ireland.id

  tags = {
    Name = "tgw-ireland-RT"
  }
}

# 4
resource "aws_ec2_transit_gateway_route" "To_spoke3_routing_tgwIreland" {
  provider = aws
  destination_cidr_block         = "10.3.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke3_tgw-ireland_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-ireland_route_table.id
}
resource "aws_ec2_transit_gateway_route" "To_spoke1_routing_tgwIrePeerAccepter" {
  provider = aws
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Ireland-accept.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-ireland_route_table.id
}
resource "aws_ec2_transit_gateway_route" "To_spoke2_routing_tgwIrePeerAccepter" {
  provider = aws
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Ireland-accept.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-ireland_route_table.id
}

# 5
resource "aws_ec2_transit_gateway_route_table_association" "tgw-ireland_route_table_spoke1_Attach" {
  provider = aws
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke3_tgw-ireland_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-ireland_route_table.id
}
resource "aws_ec2_transit_gateway_route_table_association" "tgw-ireland_route_table_peeringAccepter_Assoc" {
  provider = aws
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Ireland-accept.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw-ireland_route_table.id
}