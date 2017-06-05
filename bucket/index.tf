variable "app" {}
variable "client" {}
variable "organization" {}
variable "env" {}

variable "use_versioning" {
  default = false
}

output "bucket" { value = "${aws_s3_bucket.bucket.id}" }
output "access_key_id" { value = "${aws_iam_access_key.access_key.id}" }
output "secret_access_key" { value = "${aws_iam_access_key.access_key.secret}" }
output "region" { value = "${aws_s3_bucket.bucket.region}" }


resource "aws_s3_bucket" "bucket" {
  bucket = "${var.app}"
  acl = "private"

  versioning {
    enabled = "${var.use_versioning}"
  }

  tags {
    Client = "${var.client}"
    Name = "${var.app}"
    Environment = "${var.env}"
  }
}

resource "aws_iam_policy" "policy" {
  name = "${var.app}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::${aws_s3_bucket.bucket.id}",
              "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_group" "group" {
  name = "${var.app}"
}

resource "aws_iam_group_policy_attachment" "group_policy" {
  group = "${aws_iam_group.group.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_user" "user" {
  name = "${var.app}-user"
  path = "/"
}

resource "aws_iam_access_key" "access_key" {
  user = "${aws_iam_user.user.name}"

  depends_on = [
    "aws_iam_user.user"
  ]
}

resource "aws_iam_group_membership" "user_group" {
  name = "${var.app}-group-membership"
  users = [
    "${aws_iam_user.user.name}"
  ]
  group = "${aws_iam_group.group.name}"
}
