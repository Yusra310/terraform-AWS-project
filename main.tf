# # Get the AWS Account ID dynamically
# data "aws_caller_identity" "current" {
# }

module "IAM" {
    source = "./iam"
    # data_table = module.DynamoDB.data_table
    # Demo_lambda_name = module.lambda.Demo_lambda_name
    # account_id    = data.aws_caller_identity.current.account_id
  
}

module "lambda" {
  source          = "./Lambda"
  depends_on = [ module.IAM ]
  #data_table      = module.DynamoDB.data_table
  lambda_role_arn = module.IAM.lambda_role_arn
}

module "apigateway" {
    source = "./Api_Gateway"
    Demo_lambda_arn = module.lambda.Demo_lambda_arn
    depends_on = [ module.lambda ]
}

module "DynamoDB" {
    source = "./Dynamodb"
  
}
