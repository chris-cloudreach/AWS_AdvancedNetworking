# resource "aws_organizations_policy" "ScpPolicy" {
#   name = "scp_s3_block_public_access"
#   description = "This SCP prevents users or roles in any affected account from modifying the S3 Block Public Access Account Level Settings"
#   type = "SERVICE_CONTROL_POLICY"
#   content = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:PutAccountPublicAccessBlock"
#       ],
#       "Resource": "*",
#       "Effect": "Deny"
#     }
#   ]
# }
# POLICY

# }