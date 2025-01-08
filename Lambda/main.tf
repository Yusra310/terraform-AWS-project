resource "aws_lambda_function" "Demo_lambda" {
  function_name = "demofunction" # Lambda function name
  role          = var.lambda_role_arn # The IAM role ARN that allows the Lambda to execute

  # The path to the ZIP file that contains the Lambda function code
  filename      = "./lambda_function(2).zip" 
  architectures = ["x86_64"]

  handler       = "lambda_function.lambda_handler" # The entry point in your Python file (assuming "handler" function inside "Lambda_function.py")
  runtime       = "python3.13" # The runtime for your Lambda function (adjust to the Python version you're using)

  # environment {
  #   variables = {
  #     TABLE_NAME = var.data_table # DynamoDB table name (or other environment variables)
  #   }
  # }
}


