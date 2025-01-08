resource "aws_iam_role" "demo_role" {
  name               = "demo-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Define the custom policy
resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "AWSLambdaBasicExecutionPolicy-demo"
  description = "Custom Lambda execution policy with basic permissions"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-east-1:222634404358:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-1:222634404358:log-group:/aws/lambda/demo:*"
            ]
        }
    ]
}
EOF
}

# Attach the policy to the IAM Role
resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.demo_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.demo_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}