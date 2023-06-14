resource "aws_security_group" "my_app_sg" {
  name        = "my_app_sg"
  description = "Allow access to my Server"
  vpc_id      = aws_vpc.main_vpc.id

  # INBOUND RULES
  ingress {
    description = "SSH from my mac"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.15.241.215/32"]
  }

  ingress {
    description = "allow icmp in vpc"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    # This is crucial to allow ping from spoke vpc work 
    description = "allow icmp from spoke1 vpc"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.1.0.0/16"]
  }
  ingress {
    # This is crucial to allow ping from spoke vpc work 
    description = "allow icmp from spoke2 vpc"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.2.0.0/16"]
  }

  ingress {
    description = "test ncat connection from spoke ec2"
    from_port   = 100
    to_port     = 100
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    description = "open port 23 for telnet spoke request"
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }


  ingress {
    description = "SSH from my VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "my_app_sg"
  }
}


resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_keypair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.example.public_key_openssh

  #  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
  #   command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  # }
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.ec2_keypair.key_name}.pem"
  content  = tls_private_key.example.private_key_pem
}


# EC2 - PUBLIC
resource "aws_instance" "my_public_server2" {
    ami = data.aws_ami.my_aws_ami.id
    instance_type = var.instance_type
    key_name = var.keypair_name
    subnet_id = aws_subnet.public_a.id
    vpc_security_group_ids = [ aws_security_group.my_app_sg.id ]
    user_data = file("installTools.sh")
      tags = {
    Name = "MyAmazonLinux"
  }
}

resource "aws_instance" "my_public_server1" {
  ami                    = data.aws_ami.my_aws_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ec2_keypair.key_name
  subnet_id              = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.my_app_sg.id]

  user_data = file("installTools.sh")

  

  tags = {
    Name = "MyUbuntu"
  }
}