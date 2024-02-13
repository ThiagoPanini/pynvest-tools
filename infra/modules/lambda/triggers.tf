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


/* -------------------------------------------------------
    TRIGGER
    From: S3 (PUT event)
    To: pynvest-lambda-prep-financial-data-for-acoes/fiis
------------------------------------------------------- */

resource "aws_s3_bucket_notification" "s3-put-event-to-invoke-pynvest-lambda-prep-financial-data-for-acoes" {
  bucket = var.bucket_names_map["sor"]

  # Configurando gatilho para função pynvest-lambda-prep-financial-data-for-acoes
  lambda_function {
    lambda_function_arn = aws_lambda_function.pynvest-lambda-prep-financial-data-for-acoes.arn

    # Configurando gatilho
    events = [
      "s3:ObjectCreated:Put"
    ]
    filter_prefix = "${var.tables_names_map["fundamentus"]["sor_acoes"]}/"
    filter_suffix = ".parquet"
  }

  # Configurando gatilho para função pynvest-lambda-prep-financial-data-for-fiis
  lambda_function {
    lambda_function_arn = aws_lambda_function.pynvest-lambda-prep-financial-data-for-fiis.arn

    # Configurando gatilho
    events = [
      "s3:ObjectCreated:Put"
    ]
    filter_prefix = "${var.tables_names_map["fundamentus"]["sor_fiis"]}/"
    filter_suffix = ".parquet"
  }

  # Explicitando dependências de permissionamento
  depends_on = [
    aws_lambda_permission.invoke-permissions-from-s3-to-pynvest-lambda-prep-financial-data-for-acoes,
    aws_lambda_permission.invoke-permissions-from-s3-to-pynvest-lambda-prep-financial-data-for-fiis
  ]
}
