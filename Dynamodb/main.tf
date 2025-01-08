resource "aws_dynamodb_table" "data_table" {
  name         = "datatable"                # Name of your DynamoDB table
  hash_key     = "email"                    # Partition key for the table
  billing_mode = "PAY_PER_REQUEST"          # Use On-Demand capacity mode (automatic scaling)

  # Define the attributes used for keys
  attribute {
    name = "email"      # Name of the partition key
    type = "S"          # Type of the attribute, 'S' for string
  }

  tags = {
    Name        = "datatable"
    Environment = "dev"
  }
}
