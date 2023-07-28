module "spoke1" {
  source = "github.com/chris-cloudreach/talent-academy-vpc-module"
  providers = {
    aws = aws.virginia
  }
  vpc_cidr         = "10.1.0.0/16"
  region           = "us-east-1"
  vpc_name         = "spoke1"
  internet_gw_name = "spoke1_IGW"
  public_a_cidr    = "10.1.224.0/20"
  private_a_cidr   = "10.1.240.0/20"

# NOT YET AVAILABLE FOR MODULES
  #   lifecycle {
  #   ignore_changes = [
  #     route,
  #   ]   
  # }
}

resource "aws_instance" "spoke1-VM" {
  provider = aws.virginia
  ami                    = data.aws_ami.my_ue1_ami2.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_keypair_ssh_ue1.key_name
  subnet_id              = module.spoke1.public_subnet_a_id
  vpc_security_group_ids = [aws_security_group.my_app_sg_ue1.id]

  user_data = file("installTools.sh")

  depends_on = [ module.spoke1 ]

  tags = {
    Name = "spoke1-VM"
  }
}

resource "aws_security_group" "my_app_sg_ue1" {
  provider = aws.virginia
  name        = "my_app_sg_ue1"
  description = "Allow access to my Server"
  vpc_id      = module.spoke1.my_vpc_id

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
    cidr_blocks = ["10.1.0.0/16"]
  }
  ingress {
    # This is crucial to allow ping from hub vpc work 
    description = "allow icmp from hub vpc"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "SSH from spoke VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    description = "test ncat connection from hub ec2"
    from_port   = 100
    to_port     = 100
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "open port 23 for telnet"
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

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

resource "tls_private_key" "ssh_ue1" {
    # do not include aws provider or aws alias provider
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair_ssh_ue1" {
  provider = aws.virginia
  key_name   = "ta-lab-key-ue1"
  public_key = tls_private_key.ssh_ue1.public_key_openssh

}

resource "local_file" "ssh_key_ue1" {
    # do not include aws provider or aws alias provider
  filename = "${aws_key_pair.ec2_keypair.key_name}-ue1.pem"
  content  = tls_private_key.ssh_ue1.private_key_pem 
}

data "aws_route_table" "rt-pub" {
  provider = aws.virginia
  route_table_id  = module.spoke1.public_to_internet_rt_id

}
data "aws_route_table" "rt-priv" {
  provider = aws.virginia
  route_table_id  = module.spoke1.private_to_public_subnet_rt_id
}

resource "aws_route" "peer-conn-pub" {
  provider = aws.virginia
  route_table_id            = data.aws_route_table.rt-pub.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.Hub-spoke1-Peering.id
}
resource "aws_route" "peer-conn-priv" {
  provider = aws.virginia
  route_table_id            = data.aws_route_table.rt-priv.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.Hub-spoke1-Peering.id
}

