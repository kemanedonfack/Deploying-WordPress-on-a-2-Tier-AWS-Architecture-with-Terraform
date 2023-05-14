#IAM policy for S3 access
resource "aws_iam_policy" "s3_ec2_policy" {
  name = "s3_ec2_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3-object-lambda:Get*",
          "s3-object-lambda:List*",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

#Create IAM role for Jenkins EC2 to allow S3 read/write access
resource "aws_iam_role" "s3_ec2_role" {
  name = "s3_ec2_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

#Attaches IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "s3_ec2_policy_attachment" {
  policy_arn = aws_iam_policy.s3_ec2_policy.arn
  role       = aws_iam_role.s3_ec2_role.name
}


#IAM instance profile for EC2 instance
resource "aws_iam_instance_profile" "s3_ec2_instance_profile" {
  name = "s3_ec2_instance_profile"
  role = aws_iam_role.s3_ec2_role.name
}

