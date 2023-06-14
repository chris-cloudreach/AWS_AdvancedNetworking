# THIS IS FOR SHARING WIH OTHER 
# PRINCIPALS/RESOURCES

resource "aws_ram_resource_share" "tgw_share" {
  provider = aws.virginia
  name        = "TGW-Share"
  allow_external_principals = true
  tags = {
    Name = "TGW-Share"
  }
}

resource "aws_ram_principal_association" "tgw_share_pricipal_association" {
  provider = aws.virginia
  resource_share_arn = aws_ram_resource_share.tgw_share.id
  principal          = "418607562056"
#   principal          = "arn:aws:organizations::<account_id>:organization/<organization_id>"
}

#aws_ram_resource_association
resource "aws_ram_resource_association" "ram_associaiton" {
  provider = aws.virginia
  # ARN of the TGW to be shared. 
  # example arn : arn:aws:us-east-1-1:xxxxxxx:transit-gateway/tgw-jkl89kjdj9
  resource_arn       = aws_ec2_transit_gateway.tgw.arn
  resource_share_arn = aws_ram_resource_share.tgw_share.id
}

