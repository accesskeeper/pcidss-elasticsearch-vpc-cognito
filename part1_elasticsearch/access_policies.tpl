{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:ESHttpGet",
      "Resource": "arn:aws:es:eu-west-1:AWS-ACCOUNT:domain/es-company-name/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:ESHttpHead",
      "Resource": "arn:aws:es:eu-west-1:AWS-ACCOUNT:domain/es-company-name/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "*",
      "Resource": "arn:aws:es:eu-west-1:AWS-ACCOUNT:domain/*"
    }
  ]
}
