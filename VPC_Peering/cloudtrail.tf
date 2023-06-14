# data "aws_caller_identity" "current" {}

# resource "aws_cloudtrail" "foobar" {
#   name                          = "tf-trail-foobar"
#   s3_bucket_name                = aws_s3_bucket.foo.id
#   s3_key_prefix                 = "prefix"
#   include_global_service_events = true
#   is_multi_region_trail         = true
# }

# resource "aws_s3_bucket" "foo" {
#   bucket        = "tf-test-trail-41424242525"
#   force_destroy = true
# }

# data "aws_iam_policy_document" "foo" {
#   statement {
#     sid    = "AWSCloudTrailAclCheck"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     actions   = ["s3:GetBucketAcl"]
#     resources = [aws_s3_bucket.foo.arn]
#   }

#   statement {
#     sid    = "AWSCloudTrailWrite"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     actions   = ["s3:PutObject"]
#     resources = ["${aws_s3_bucket.foo.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

#     condition {
#       test     = "StringEquals"
#       variable = "s3:x-amz-acl"
#       values   = ["bucket-owner-full-control"]
#     }
#   }
# }
# resource "aws_s3_bucket_policy" "foo" {
#   bucket = aws_s3_bucket.foo.id
#   policy = data.aws_iam_policy_document.foo.json
# }