# # I THINK THIS IS FOR SHARING WIH OTHER PRINCIPALS/RESOURCES
# NOT IN USE
# NOT IN USE
# NOT IN USE
# NOT IN USE
# NOT IN USE
# NOT IN USE
# NOT IN USE


# resource "aws_ram_resource_share" "tgw_share" {
#   name        = "TGW-Share"
#   allow_external_principals = true
#   tags = {
#     Name = "TGW-Share"
#   }
# }

# resource "aws_ram_principal_association" "tgw_share_association" {
#   resource_share_arn = aws_ram_resource_share.tgw_share.id
#   principal          = "arn:aws:organizations::<account_id>:organization/<organization_id>"
# }

