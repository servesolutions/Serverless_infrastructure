resource "aws_amplify_app" "PowerOfMath" {
  name = "PowerOfMath"

  # Setup redirect from https://example.com to https://www.example.com
  custom_rule {
    source = "https://PowerOfMath.com"
    status = "302"
    target = "https://www.PowerOfMath.com"
  }
  custom_rule {
    source = "https://www.PowerOfMath.com"
    status = "200"
    target = "/index.html"
  }
}

resource "aws_amplify_branch" "dev" {
  app_id      = aws_amplify_app.PowerOfMath.id
  branch_name = "dev"
}

resource "aws_amplify_domain_association" "PowerOfMathdomain" {
  app_id      = aws_amplify_app.PowerOfMath.id
  domain_name = "PowerOfMath.com"

  # https://PowerOfMath.com
  sub_domain {
    branch_name = aws_amplify_branch.dev.branch_name
    prefix      = ""
  }

  # https://www.PowerOfMath.com
  sub_domain {
    branch_name = aws_amplify_branch.dev.branch_name
    prefix      = "www"
  }
}

resource "aws_api_gateway_account" "PowerOfMath" {
}

resource "aws_api_gateway_rest_api" "PowerOfMathRestApi" {
  tags = merge(var.tags, {})
  name = aws_api_gateway_rest_api.PowerOfMathRestApi
}

resource "aws_api_gateway_resource" "aws_api_gateway_resource_4" {
  rest_api_id = aws_api_gateway_rest_api.PowerOfMathRestApi.id
  parent_id   = aws_api_gateway_rest_api.PowerOfMathRestApi.root_resource_id
}

resource "aws_api_gateway_method" "aws_api_gateway_method_5" {
  rest_api_id = aws_api_gateway_rest_api.PowerOfMathRestApi.id
  resource_id = aws_api_gateway_resource.aws_api_gateway_resource_4.id
  http_method = "GET"
}

resource "aws_api_gateway_integration" "aws_api_gateway_integration_6" {
  rest_api_id             = aws_api_gateway_account.PowerOfMath.id
  resource_id             = aws_api_gateway_resource.aws_api_gateway_resource_4.id
  integration_http_method = "POST"
  http_method             = aws_api_gateway_method.aws_api_gateway_method_5
}

resource "aws_api_gateway_deployment" "aws_api_gateway_deployment_7" {
  stage_name  = "dev"
  rest_api_id = aws_api_gateway_rest_api.PowerOfMathRestApi.id
}

#Creating an S3 bucket for the Lambda_function.zip file.

resource "random_pet" "lambda_bucket_name" {
  prefix = "lambda"
  length = 2
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = random_pet.lambda_bucket_name.id
  force_destroy = true
}


resource "aws_iam_role" "PowerOfMathRole" {
  name = "PowerOfMathRole"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "PowerOfMath_policy" {
  role       = aws_iam_role.PowerOfMathRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole", 
                "arn:aws:iam::aws:policy/service-role/PowerOfMathDynamoPolicy",
                "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "PowerOfMathfunction" {
  function_name    = "PowerOfMathfunction"
  filename         = "lambda_function.zip"
  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.PowerOfMath.key

  runtime = "python3.9"
  handler = "lambda_function.handler"

  source_code_hash = data.archive_file.lambda_function.output_base64sha256

  role = aws_iam_role.PowerOfMathRole.arn
}


resource "aws_dynamodb_table" "PowerofMath" {
  tags = merge(var.tags, {})
  name = "PowerofMath"
}