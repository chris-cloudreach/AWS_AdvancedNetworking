# ---------- EC2 INSTANCES & SECURITY GROUP (in each Spoke VPC) ----------
# Data resource to determine the latest Amazon Linux2 AMI
data "aws_ami" "amazon_linux" {
  provider = aws.Ncalifornia
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

#   filter {
#     name = "owner-alias"
#     values = [
#       "amazon",
#     ]
#   }
}

# data "aws_ami" "my_aws_ami" {
#     owners = ["099720109477"]
#     most_recent = true
#     filter {
#         name = "name"
#         values = [ "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" ]
#     }
# }

# data "aws_ami" "my_ue1_ami2" {
#     provider = aws.virginia
#     owners = ["099720109477"]
#     most_recent = true
#     filter {
#         name = "name"
#         values = [ "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*" ]
#     }
# }

# data "aws_ami" "amazonLinuxAmi" {
#     owners = ["137112412989"]
#     most_recent = true
#     filter {
#         name = "name"
#         values = [ "*-kernel-6.1-arm64" ]
#     }
# }

