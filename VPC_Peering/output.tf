# output "ec2_instance_ip_first" {
#  value = aws_instance.my_public_server1.public_ip
#   # value = aws_instance.my
# }
# output "ec2_instance_ip_second" {
#  value = aws_instance.my_public_server2.public_ip
#   # value = aws_instance.my
# }

output "my_vpc_id" {
    value = aws_vpc.main_vpc.id
}

output "public_subnet_a_id" {
    value = aws_subnet.public_a.id
}

output "private_subnet_a_id" {
    value = aws_subnet.private_a.id
}