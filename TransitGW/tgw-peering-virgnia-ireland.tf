# THIS IS ALL ABBOUT CREATING THE PEERING CONNECTION BTW TGWs
# No reference to VPC here

# PEERING FROM VIRGINIA TO IRELAND
data "aws_region" "ireland" {
  provider = aws
}

resource "aws_ec2_transit_gateway_peering_attachment" "peer" {
  provider = aws.virginia  
# SPECIFY IF DIFFERENT AWS ACCOUNTS
#   peer_account_id         = aws_ec2_transit_gateway.tgw-ireland.owner_id

  peer_region             = data.aws_region.ireland.name # Ireland region
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw-ireland.id # ireland tgw id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id # virgian tgw id

  tags = {
    Name = "Virginia-Ireland_TGWPeering"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Ireland-accept" {
  depends_on = [aws_ec2_transit_gateway.tgw, aws_ec2_transit_gateway.tgw-ireland, aws_ec2_transit_gateway_peering_attachment.peer]
  provider   = aws # provider for ireland

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.peer.id

  tags = {
    Name = "cross-region-tgw-attachment"
  }
}