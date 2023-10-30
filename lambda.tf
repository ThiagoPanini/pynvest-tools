/* --------------------------------------------------------
ARQUIVO: lambda.tf

Arquivo Terraform responsável por definir todas as funções
Lambda utilizadas para coleta e gerenciamento de dados no
projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    Lambda function
    pynvest-lambda-send-tickers-to-sqs-queues
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-send-tickers-to-sqs-queues" {
  type        = "zip"
  source_dir  = "${path.module}/app/lambda/functions/pynvest-lambda-send-tickers-to-sqs-queues/"
  output_path = "${path.module}/app/lambda/zip/pynvest-lambda-send-tickers-to-sqs-queues.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-send-tickers-to-sqs-queues" {
  function_name = "pynvest-lambda-send-tickers-to-sqs-queues"
  description   = "Coleta tickers de ativos da B3 e envia mensagens para filas no SQS"

  filename         = "${path.module}/app/lambda/zip/pynvest-lambda-send-tickers-to-sqs-queues.zip"
  source_code_hash = data.archive_file.pynvest-lambda-send-tickers-to-sqs-queues.output_base64sha256

  role    = aws_iam_role.pynvest-lambda-send-msgs-to-tickers-queues.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  depends_on = [
    data.archive_file.pynvest-lambda-send-tickers-to-sqs-queues,
    aws_iam_role.pynvest-lambda-send-msgs-to-tickers-queues
  ]
}

# Definindo regra de execução agendada via Eventbridge
resource "aws_cloudwatch_event_rule" "trigger-pynvest-lambda-send-tickers-to-sqs-queues" {
  name                = "trigger-${aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues.function_name}"
  description         = "Regra de execução agendada da função ${aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues.function_name}"
  schedule_expression = var.schedule_expression_to_initialize
}

# Vinculando regra de agendamento à função
resource "aws_cloudwatch_event_target" "trigger-pynvest-lambda-send-tickers-to-sqs-queues" {
  arn  = aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues.arn
  rule = aws_cloudwatch_event_rule.trigger-pynvest-lambda-send-tickers-to-sqs-queues.name

  depends_on = [
    aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues,
    aws_cloudwatch_event_rule.trigger-pynvest-lambda-send-tickers-to-sqs-queues
  ]
}

# Configurando permissões para função Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger-pynvest-lambda-send-tickers-to-sqs-queues.arn

  depends_on = [
    aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues,
    aws_cloudwatch_event_rule.trigger-pynvest-lambda-send-tickers-to-sqs-queues
  ]
}


/* -------------------------------------------------------
    Archive file:
    Zip comum a ser utlizado para próximas duas Lambdas
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-get-financial-data" {
  type        = "zip"
  source_dir  = "${path.module}/app/lambda/functions/pynvest-lambda-get-financial-data/"
  output_path = "${path.module}/app/lambda/zip/pynvest-lambda-get-financial-data.zip"
}


/* -------------------------------------------------------
    Lambda function
    pynvest-lambda-get-financial-data-for-acoes
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-financial-data-for-acoes" {
  function_name = "pynvest-lambda-get-financial-data-for-acoes"
  description   = "Extrai e consolida indicadores financeiros de Ações a partir de tickers coletados de fila SQS"

  filename         = "${path.module}/app/lambda/zip/pynvest-lambda-get-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-get-financial-data.output_base64sha256

  role    = aws_iam_role.pynvest-lambda-put-sor-data-for-acoes.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      DATABASE_NAME = var.database_name,
      TABLE_NAME    = "tbl_fundamentus_indicadores_acoes"
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data,
    aws_iam_role.pynvest-lambda-put-sor-data-for-acoes
  ]
}

# Definindo gatilho para função: fila SQS
resource "aws_lambda_event_source_mapping" "pynvest-tickers-queue-acoes" {
  function_name    = aws_lambda_function.pynvest-lambda-get-financial-data-for-acoes.arn
  event_source_arn = aws_sqs_queue.pynvest-tickers-acoes-queue.arn

  # Configuração do trigger
  batch_size                         = var.sqs_lambda_trigger_batch_size
  maximum_batching_window_in_seconds = var.sqs_lambda_trigger_batch_window

  scaling_config {
    maximum_concurrency = var.sqs_lambda_trigger_max_concurrency
  }

  depends_on = [
    aws_lambda_function.pynvest-lambda-get-financial-data-for-acoes,
    aws_sqs_queue.pynvest-tickers-acoes-queue
  ]
}


/* -------------------------------------------------------
    Lambda function
    pynvest-lambda-get-financial-data-for-fiis
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-financial-data-for-fiis" {
  function_name = "pynvest-lambda-get-financial-data-for-fiis"
  description   = "Extrai e consolida indicadores financeiros de FIIs a partir de tickers coletados de fila SQS"

  filename         = "${path.module}/app/lambda/zip/pynvest-lambda-get-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-get-financial-data.output_base64sha256

  role    = aws_iam_role.pynvest-lambda-put-sor-data-for-fiis.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      DATABASE_NAME = var.database_name,
      TABLE_NAME    = "tbl_fundamentus_indicadores_fiis"
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data,
    aws_iam_role.pynvest-lambda-put-sor-data-for-fiis
  ]
}

# Definindo gatilho para função: fila SQS
resource "aws_lambda_event_source_mapping" "pynvest-tickers-queue-fiis" {
  function_name    = aws_lambda_function.pynvest-lambda-get-financial-data-for-fiis.arn
  event_source_arn = aws_sqs_queue.pynvest-tickers-fiis-queue.arn

  # Configuração do trigger
  batch_size                         = var.sqs_lambda_trigger_batch_size
  maximum_batching_window_in_seconds = var.sqs_lambda_trigger_batch_window

  scaling_config {
    maximum_concurrency = var.sqs_lambda_trigger_max_concurrency
  }

  depends_on = [
    aws_lambda_function.pynvest-lambda-get-financial-data-for-fiis,
    aws_sqs_queue.pynvest-tickers-fiis-queue
  ]
}
