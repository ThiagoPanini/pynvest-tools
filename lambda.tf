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


/* -------------------------------------------------------
    Lambda function
    pynvest-lambda-get-financial-data-for-acoes
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-get-financial-data-for-acoes" {
  type        = "zip"
  source_dir  = "${path.module}/app/lambda/functions/pynvest-lambda-get-financial-data-for-acoes/"
  output_path = "${path.module}/app/lambda/zip/pynvest-lambda-get-financial-data-for-acoes.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-financial-data-for-acoes" {
  function_name = "pynvest-lambda-get-financial-data-for-acoes"
  description   = "Extrai e consolida indicadores financeiros de Ações a partir de tickers coletados de fila SQS"

  filename         = "${path.module}/app/lambda/zip/pynvest-lambda-get-financial-data-for-acoes.zip"
  source_code_hash = data.archive_file.pynvest-lambda-get-financial-data-for-acoes.output_base64sha256

  role    = aws_iam_role.pynvest-lambda-put-sor-data-for-acoes.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data-for-acoes,
    aws_iam_role.pynvest-lambda-put-sor-data-for-acoes
  ]
}

# Definindo gatilho para função: fila SQS
resource "aws_lambda_event_source_mapping" "pynvest-tickers-queue" {
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

