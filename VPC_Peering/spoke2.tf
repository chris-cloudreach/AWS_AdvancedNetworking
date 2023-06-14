module "spoke2" {
  source = "github.com/chris-cloudreach/talent-academy-vpc-module"
  providers = {
    aws = aws.Ncalifornia
  }
  vpc_cidr         = "10.2.0.0/16"
  region           = "us-west-2"
  vpc_name         = "spoke2"
  internet_gw_name = "spoke2_IGW"
  public_a_cidr    = "10.2.224.0/20"
  private_a_cidr   = "10.2.240.0/20"

}

resource "aws_instance" "spoke2-VM" {
  provider = aws.Ncalifornia
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_keypair_ssh_Ncalifornia.key_name
  subnet_id              = module.spoke2.public_subnet_a_id
  vpc_security_group_ids = [aws_security_group.my_app_sg_Ncalifornia.id]

  user_data = file("installTools.sh")

  depends_on = [ module.spoke2 ]

  tags = {
    Name = "spoke2-VM"
  }
}

resource "aws_security_group" "my_app_sg_Ncalifornia" {
  provider = aws.Ncalifornia
  name        = "my_app_sg_Ncalifornia"
  description = "Allow access to my Server"
  vpc_id      = module.spoke2.my_vpc_id

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
    cidr_blocks = ["10.2.0.0/16"]
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
    cidr_blocks = ["10.2.0.0/16"]
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
    Name = "my_app_sg_Ncalifornia"
  }
}

resource "tls_private_key" "ssh_Ncalifornia" {
    # do not include aws provider or aws alias provider
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair_ssh_Ncalifornia" {
  provider = aws.Ncalifornia
  key_name   = "ta-lab-key-Ncal"
  public_key = tls_private_key.ssh_Ncalifornia.public_key_openssh

}

resource "local_file" "ssh_key_Ncalifornia" {
    # do not include aws provider or aws alias provider
  filename = "${aws_key_pair.ec2_keypair.key_name}-ncal.pem"
  content  = tls_private_key.ssh_Ncalifornia.private_key_pem 
}

data "aws_route_table" "rt-pub-spoke2" {
  provider = aws.Ncalifornia
  route_table_id  = module.spoke2.public_to_internet_rt_id

}
data "aws_route_table" "rt-priv-spoke2" {
  provider = aws.Ncalifornia
  route_table_id  = module.spoke2.private_to_public_subnet_rt_id
}

resource "aws_route" "peer-conn-pub-spoke2" {
  provider = aws.Ncalifornia
  route_table_id            = data.aws_route_table.rt-pub-spoke2.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.Hub-spoke2-Peering.id
}
resource "aws_route" "peer-conn-priv-spoke2" {
  provider = aws.Ncalifornia
  route_table_id            = data.aws_route_table.rt-priv-spoke2.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.Hub-spoke2-Peering.id 
}

