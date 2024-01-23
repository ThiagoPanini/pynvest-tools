/* --------------------------------------------------------
ARQUIVO: triggers.tf @ lambda module

Arquivo responsável por centralizar todos os gatilhos do
Eventbridge para engatilhamento/agendamento das funções
Lambda do módulo.
-------------------------------------------------------- */

/* -------------------------------------------------------
    TRIGGER
    From: Eventbridge
    To: pynvest-lambda-check-and-delete-partitions
------------------------------------------------------- */

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
