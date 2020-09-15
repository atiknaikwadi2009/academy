resource "aws_lambda_function" "da_create_customer" {
  filename         = var.lamda_filename
  function_name    = "da_create_customer_function"
  handler          = "lambda_handler.lambda_handler"
  runtime          = var.lamda_runtime
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = filebase64sha256("lambda.zip")

  tags =  {
      Name = "${var.project_name}-lamda"
  }

environment {
    variables = {
      DB_NAME = data.aws_ssm_parameter.db_name.value
    }
  }

}


resource "aws_cloudwatch_log_group" "customer" {
  name              = "/aws/lambda/${aws_lambda_function.da_create_customer.function_name}"
  retention_in_days = 1
}


resource "aws_lambda_permission" "customerapigw" {

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.da_create_customer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.customer.execution_arn}/*/*"
}
