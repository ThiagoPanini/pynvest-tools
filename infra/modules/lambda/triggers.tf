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


/* -------------------------------------------------------
    TRIGGER
    From: SQS
    To: pynvest-lambda-get-financial-data-for-acoes
------------------------------------------------------- */

# Definindo gatilho para função: fila SQS
resource "aws_lambda_event_source_mapping" "pynvest-tickers-queue-acoes" {
  function_name    = aws_lambda_function.pynvest-lambda-get-financial-data-for-acoes.arn
  event_source_arn = var.sqs_queues_arn_map["pynvest-tickers-acoes-queue"]

  # Configuração do trigger
  batch_size                         = var.sqs_lambda_trigger_batch_size
  maximum_batching_window_in_seconds = var.sqs_lambda_trigger_batch_window

  scaling_config {
    maximum_concurrency = var.sqs_lambda_trigger_max_concurrency
  }

  depends_on = [
    aws_lambda_function.pynvest-lambda-get-financial-data-for-acoes
  ]
}


/* -------------------------------------------------------
    TRIGGER
    From: SQS
    To: pynvest-lambda-get-financial-data-for-fiis
------------------------------------------------------- */

# Definindo gatilho para função: fila SQS
resource "aws_lambda_event_source_mapping" "pynvest-tickers-queue-fiis" {
  function_name    = aws_lambda_function.pynvest-lambda-get-financial-data-for-fiis.arn
  event_source_arn = var.sqs_queues_arn_map["pynvest-tickers-fiis-queue"]

  # Configuração do trigger
  batch_size                         = var.sqs_lambda_trigger_batch_size
  maximum_batching_window_in_seconds = var.sqs_lambda_trigger_batch_window

  scaling_config {
    maximum_concurrency = var.sqs_lambda_trigger_max_concurrency
  }

  depends_on = [
    aws_lambda_function.pynvest-lambda-get-financial-data-for-fiis
  ]
}
