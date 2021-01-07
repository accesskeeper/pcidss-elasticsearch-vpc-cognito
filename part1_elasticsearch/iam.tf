resource "aws_cloudwatch_log_group" "es_cloudwatch_log_group" {
  name = "${var.es_domain_name}-log_group"
  tags = var.tags
}

resource "aws_cloudwatch_log_resource_policy" "es_aws_cloudwatch_log_resource_policy" {
  policy_name = "${var.es_domain_name}-policy"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

# Service-linked role to give Amazon ES permissions to access your VPC
resource "aws_iam_service_linked_role" "es_vpc" {
  count            = var.create_service_link_role == true ? 1 : 0
  aws_service_name = "es.amazonaws.com"
  description      = "Service-linked role to give Amazon ES permissions to access your VPC"
}


#resource "aws_iam_role" "kibana_to_es" {
#  name = "kibana_to_es"
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}

#resource "aws_iam_role_policy" "kibana_to_es" {
#  name   = "kibana_to_es"
#  role   = "kibana_to_es"
#  depends_on = [aws_iam_role.kibana_to_es]
#  policy = <<CONFIG
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "es:Describe*",
#        "es:List*"
#      ],
#      "Effect": "Allow",
#      "Resource": "*"
#    }
#  ]
#}
#CONFIG
#}

#resource "aws_iam_role" "hids_to_es" {
#  name = "hids_to_es"
#  depends_on = [aws_iam_role.instance_role]
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    },
#    {
#      "Effect": "Allow",
#      "Principal": {
#        "AWS": [
#	  "${aws_iam_role.instance_role.arn}"
#      ]
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF
#}

#resource "aws_iam_role_policy" "hids_to_es" {
#  name   = "hids_to_es"
#  role   = "hids_to_es"
#  depends_on = [aws_iam_role.hids_to_es]
#  policy = <<CONFIG
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "es:*"
#      ],
#      "Effect": "Allow",
#      "Resource": "*"
#    }
#  ]
#}
#CONFIG
#}

#resource "aws_iam_instance_profile" "hids_to_es" {
#  name = "hids_to_es"
#  role = aws_iam_role.hids_to_es.name
#}

#resource "aws_iam_instance_profile" "kibana_to_es" {
#  name = "kibana_to_es"
#  role = aws_iam_role.kibana_to_es.name
#}

#resource "aws_iam_instance_profile" "instance_role" {
#  name = "instance_role"
#  role = aws_iam_role.instance_role.name
#}


#resource "aws_iam_role" "instance_role" {
#  name = "instance_role"
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "ec2.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}

#resource "aws_iam_role_policy_attachment" "ssm-attach" {
#  role       = aws_iam_role.hids_to_es.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#}

#resource "aws_iam_role_policy_attachment" "cloudwatch-attach" {
#  role       = aws_iam_role.hids_to_es.name
#  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#}

#resource "aws_iam_role_policy_attachment" "ssm-attach2" {
#  role       = aws_iam_role.instance_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#}

#resource "aws_iam_role_policy_attachment" "cloudwatch-attach2" {
#  role       = aws_iam_role.instance_role.name
#  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
#}
