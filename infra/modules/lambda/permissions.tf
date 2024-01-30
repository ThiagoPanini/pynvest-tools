/* --------------------------------------------------------
ARQUIVO: permissions.tf @ lambda module

Arquivo responsável por centralizar todos os recursos
relacionados à concessão de permissões para invocações
de funções Lambda
-------------------------------------------------------- */

/* -------------------------------------------------------
    LAMBDA PERMISSIONS
    From: Eventbridge
    To: pynvest-lambda-check-and-delete-partitions
------------------------------------------------------- */

# Configurando permissões para invocação da função via Eventbridge
resource "aws_lambda_permission" "allow-eventbridge-to-pynvest-lambda-check-and-delete-partitions" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-check-and-delete-partitions.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-and-delete-partitions.arn

  depends_on = [
    aws_lambda_function.pynvest-lambda-check-and-delete-partitions,
    aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-and-delete-partitions
  ]
}


/* -------------------------------------------------------
    LAMBDA PERMISSIONS
    From: pynvest-lambda-check-and-delete-partitions
    To: pynvest-lambda-get-tickers
------------------------------------------------------- */

# Configurando permissões para invocar função Lambda
resource "aws_lambda_permission" "invoke-permissions-to-pynvest-lambda-get-tickers" {
  statement_id  = "AllowExecutionFromSourceLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-get-tickers.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = aws_lambda_function.pynvest-lambda-check-and-delete-partitions.arn

  depends_on = [
    aws_lambda_function.pynvest-lambda-check-and-delete-partitions,
    aws_lambda_function.pynvest-lambda-get-tickers
  ]
}

# Configurando invocação da Lambda através de outra Lambda (em caso de sucesso)
resource "aws_lambda_function_event_invoke_config" "destination-pynvest-lambda-get-tickers" {
  function_name = aws_lambda_function.pynvest-lambda-check-and-delete-partitions.function_name

  destination_config {
    on_success {
      destination = aws_lambda_function.pynvest-lambda-get-tickers.arn
    }
  }

  depends_on = [
    aws_lambda_permission.invoke-permissions-to-pynvest-lambda-get-tickers
  ]
}
