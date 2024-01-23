/* --------------------------------------------------------
ARQUIVO: triggers.tf @ lambda module

Arquivo responsável por centralizar todos os gatilhos do
Eventbridge para engatilhamento/agendamento das funções
Lambda do módulo.
-------------------------------------------------------- */

# Definindo regra de execução agendada via Eventbridge
resource "aws_cloudwatch_event_rule" "trigger-pynvest-lambda-check-and-delete-partitions" {
  name                = "trigger-${aws_lambda_function.pynvest-lambda-check-and-delete-partitions.function_name}"
  description         = "Regra de execução agendada da função ${aws_lambda_function.pynvest-lambda-check-and-delete-partitions.function_name}"
  schedule_expression = var.cron_expression_to_initialize_process
}

# Vinculando regra de agendamento à função
resource "aws_cloudwatch_event_target" "trigger-pynvest-lambda-check-and-delete-partitions" {
  arn  = aws_lambda_function.pynvest-lambda-check-and-delete-partitions.arn
  rule = aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-and-delete-partitions.name

  depends_on = [
    aws_lambda_function.pynvest-lambda-check-and-delete-partitions,
    aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-and-delete-partitions
  ]
}

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
