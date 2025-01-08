resource "aws_api_gateway_rest_api" "data_api" {
  name        = "dataapi"
  description = "API for Data Insert and Fetch operations"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# resource "aws_api_gateway_resource" "insert" {
#   rest_api_id = aws_api_gateway_rest_api.data_api.id
#   parent_id   = aws_api_gateway_rest_api.data_api.root_resource_id
#   path_part   = "insert"
# }

# resource "aws_api_gateway_resource" "fetch" {
#   rest_api_id = aws_api_gateway_rest_api.data_api.id
#   parent_id   = aws_api_gateway_rest_api.data_api.root_resource_id
#   path_part   = "fetch"
# }

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.data_api.id
  resource_id   = aws_api_gateway_rest_api.data_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.data_api.id
  resource_id   = aws_api_gateway_rest_api.data_api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.Demo_lambda_arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.data_api.id
  resource_id   = aws_api_gateway_rest_api.data_api.root_resource_id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     ="arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.Demo_lambda_arn}/invocations"
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.data_api.id
  resource_id   = aws_api_gateway_rest_api.data_api.root_resource_id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.Demo_lambda_arn}/invocations"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "data_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.data_api.id

  depends_on = [
    aws_lambda_permission.allow_apigateway,
    aws_api_gateway_method.post_method,
    aws_api_gateway_method.get_method,
    aws_api_gateway_integration.post_integration,
    aws_api_gateway_integration.get_integration
  ]
}

# API Gateway Stage (new way to define stages)
resource "aws_api_gateway_stage" "data_api_stage" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.data_api.id
  deployment_id = aws_api_gateway_deployment.data_api_deployment.id
}












