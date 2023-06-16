# variable "my" {
# # type = list(map)
# default = [

#                   {
#                     "attachment": [
#                       {
#                         "endpoint_id": "vpce-0a226ce8b8ac61e24",
#                         "subnet_id": "subnet-0cc0bb11a8bd84909"
#                       }
#                     ],
#                     "availability_zone": "eu-west-1b"
#                   }
                  
#             ]

# }

# # element([for ss in tolist(my) : ss.attachment[0].endpoint_id ], 0)

