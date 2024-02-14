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

# Configurando permissões para invocar função Lambda (SoT Ações)
resource "aws_lambda_permission" "invoke-permissions-from-s3-to-pynvest-lambda-prep-financial-data-for-acoes" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-prep-financial-data-for-acoes.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_names_map["sor"]}"

  depends_on = [
    aws_lambda_function.pynvest-lambda-prep-financial-data-for-acoes
  ]
}

# Configurando permissões para invocar função Lambda (SoT FIIs)
resource "aws_lambda_permission" "invoke-permissions-from-s3-to-pynvest-lambda-prep-financial-data-for-fiis" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-prep-financial-data-for-fiis.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_names_map["sor"]}"

  depends_on = [
    aws_lambda_function.pynvest-lambda-prep-financial-data-for-fiis
  ]
}

# Definindo notificação do bucket para execução de funções Lambda para preparação dos dados (Ações e FIIs)
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


/* -------------------------------------------------------
    TRIGGER
    From: S3 (PUT event)
    To: pynvest-lambda-specialize-financial-data
------------------------------------------------------- */

# Configurando permissões para invocar função Lambda (Spec Ativos)
resource "aws_lambda_permission" "invoke-permissions-from-s3-to-pynvest-lambda-specialize-financial-data" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-specialize-financial-data.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_names_map["sot"]}"

  depends_on = [
    aws_lambda_function.pynvest-lambda-specialize-financial-data
  ]
}

# Definindo notificação do bucket para execução de funções Lambda para especialização dos dados
resource "aws_s3_bucket_notification" "s3-put-event-to-invoke-pynvest-lambda-specialize-financial-data" {
  bucket = var.bucket_names_map["sot"]

  # Configurando gatilho para função pynvest-lambda-specialize-financial-data
  lambda_function {
    lambda_function_arn = aws_lambda_function.pynvest-lambda-specialize-financial-data.arn

    # Configurando gatilho
    events = [
      "s3:ObjectCreated:Put"
    ]
    filter_prefix = "${var.tables_names_map["fundamentus"]["sot_acoes"]}/"
    filter_suffix = ".parquet"
  }

  # Configurando gatilho para função pynvest-lambda-specialize-financial-data
  lambda_function {
    lambda_function_arn = aws_lambda_function.pynvest-lambda-specialize-financial-data.arn

    # Configurando gatilho
    events = [
      "s3:ObjectCreated:Put"
    ]
    filter_prefix = "${var.tables_names_map["fundamentus"]["sot_fiis"]}/"
    filter_suffix = ".parquet"
  }

  # Explicitando dependências de permissionamento
  depends_on = [
    aws_lambda_permission.invoke-permissions-from-s3-to-pynvest-lambda-specialize-financial-data
  ]
}
