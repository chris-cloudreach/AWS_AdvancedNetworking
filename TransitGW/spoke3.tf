# THIS IS A DIFFERENT REGION SO NEEDS TGW SHARING

data "aws_ami" "my_aws_ami" {
    owners = ["099720109477"]
    most_recent = true
    filter {
        name = "name"
        values = [ "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" ]
    }
}

resource "tls_private_key" "ssh_Ncalifornia" {
    # do not include aws provider or aws alias provider
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair_ssh_Ncalifornia" {
  provider = aws
  key_name   = "ta-lab-key-Ncal"
  public_key = tls_private_key.ssh_Ncalifornia.public_key_openssh

}

resource "local_file" "ssh_key_Ncalifornia" {
    # do not include aws provider or aws alias provider
  filename = "${aws_key_pair.ec2_keypair_ssh_Ncalifornia.key_name}.pem"
  content  = tls_private_key.ssh_Ncalifornia.private_key_pem 
}


module "spoke3" {
  source = "github.com/chris-cloudreach/talent-academy-vpc-module"
  providers = {
    aws = aws
  }
  vpc_cidr         = "10.3.0.0/16"
  region           = "eu-west-1"
  vpc_name         = "spoke3"
  internet_gw_name = "spoke3_IGW"
  public_a_cidr    = "10.3.224.0/20"
  private_a_cidr   = "10.3.240.0/20"

# NOT YET AVAILABLE FOR MODULES
  #   lifecycle {
  #   ignore_changes = [
  #     route,
  #   ]
  # }
}

resource "aws_instance" "spoke3-VM" {
  provider = aws
  ami                    = data.aws_ami.my_aws_ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2_keypair_ssh_Ncalifornia.key_name
  subnet_id              = module.spoke3.public_subnet_a_id
  vpc_security_group_ids = [aws_security_group.my_app_sg_spk3.id]

  user_data = file("installTools.sh")

  depends_on = [ module.spoke3 ]

  tags = {
    Name = "spoke3-VM"
  }
}

resource "aws_security_group" "my_app_sg_spk3" {
  provider = aws
  name        = "my_app_sg_spk3"
  description = "Allow access to my Server"
  vpc_id      = module.spoke3.my_vpc_id

  # INBOUND RULES
  ingress {
    description = "SSH from my mac"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.15.241.215/32"]
  }

  ingress {
    description = "allow icmp within spoke vpc"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.3.0.0/16"]
  }
  ingress {
    # This is crucial to allow ping from hub vpc work 
    description = "allow icmp from spoke2 vpc"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.2.0.0/16"]
  }
  ingress {
    # This is crucial to allow ping from hub vpc work 
    description = "allow icmp from spoke1 vpc"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    description = "SSH from this spoke3 VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.3.0.0/16"]
  }

  # ingress {
  #   description = "test ncat connection from spoke 2"
  #   from_port   = 100
  #   to_port     = 100
  #   protocol    = "tcp"
  #   cidr_blocks = ["10.2.0.0/16"]
  # }

  # ingress {
  #   description = "open port 23 for telnet spoke 2"
  #   from_port   = 23
  #   to_port     = 23
  #   protocol    = "tcp"
  #   cidr_blocks = ["10.2.0.0/16"]
  # }

  ingress {
    description = "http from the world"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https from the world"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow access to the world"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_app_sg_ue1"
  }
}


data "aws_route_table" "rt-pub-spoke3" {
  provider = aws
  route_table_id  = module.spoke3.public_to_internet_rt_id

}
data "aws_route_table" "rt-priv-spoke3" {
  provider = aws
  route_table_id  = module.spoke3.private_to_public_subnet_rt_id
}

resource "aws_route" "tgwAttach-route-3-toSpoke2pub" {
  provider = aws
  route_table_id            = data.aws_route_table.rt-pub-spoke3.id
  destination_cidr_block    = "10.2.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw-ireland.id
}
resource "aws_route" "tgwAttach-route-3-toSpoke1pub" {
  provider = aws
  route_table_id            = data.aws_route_table.rt-pub-spoke3.id
  destination_cidr_block    = "10.1.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.tgw-ireland.id
}


# resource "aws_route" "peer-conn-priv" {
#   provider = aws
#   route_table_id            = data.aws_route_table.rt-priv.id
#   destination_cidr_block    = "10.0.0.0/16"
#   vpc_peering_connection_id = aws_vpc_peering_connection.Hub-spoke3-Peering.id
# }

