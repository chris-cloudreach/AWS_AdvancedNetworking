data "aws_caller_identity" "spoke2" {
}

resource "aws_vpc_peering_connection" "Hub-spoke2-Peering" {
  vpc_id        = aws_vpc.main_vpc.id  # Hub vpc id  aws_vpc" "vpc1
  peer_vpc_id   = module.spoke2.my_vpc_id  # The destination vpc id

  peer_region = "us-west-2"
  auto_accept = false
  peer_owner_id = data.aws_caller_identity.spoke2.account_id



#   peer_vpc_id   = aws_vpc.vpc1.id  # The destination vpc id
#   auto_accept  = true  
  # Automatically accept the peering connection request
  # works for when vpcs are in same region
  # if you specify peer-region = "xyz", you cant set auto-accept
  tags = {
    Name = "Hub-spoke2-Peering"
    Side = "Requester"
  }
  depends_on = [ module.spoke2, aws_vpc.main_vpc ]
}

# Accepter's side of the connection.
resource "aws_vpc_peering_connection_accepter" "spoke2" {
  provider                  = aws.Ncalifornia
  vpc_peering_connection_id = aws_vpc_peering_connection.Hub-spoke2-Peering.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

# resource "aws_vpc" "vpc1" {
#   cidr_block = "10.4.0.0/16"
#   # Add more configuration for VPC1 as needed
# }


