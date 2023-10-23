/* --------------------------------------------------------
ARQUIVO: lambda.tf

Arquivo Terraform responsável por definir todas as funções
Lambda utilizadas para coleta e gerenciamento de dados no
projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    Lambda function
    pynvest-lambda-send-b3-tickers-to-sqs-queue
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-send-b3-tickers-to-sqs-queue" {
  type        = "zip"
  source_dir  = "${path.module}/app/lambda/functions/pynvest-lambda-send-b3-tickers-to-sqs-queue/"
  output_path = "${path.module}/app/lambda/zip/pynvest-lambda-send-b3-tickers-to-sqs-queue.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-send-b3-tickers-to-sqs-queue" {
  function_name = "pynvest-lambda-send-b3-tickers-to-sqs-queue"
  description   = "Coleta tickers de ativos da B3 e envia mensagens para fila SQS"

  filename         = "${path.module}/app/lambda/zip/pynvest-lambda-send-b3-tickers-to-sqs-queue.zip"
  source_code_hash = data.archive_file.pynvest-lambda-send-b3-tickers-to-sqs-queue.output_base64sha256

  role    = aws_iam_role.pynvest-lambda-send-msgs-to-queue.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  depends_on = [
    data.archive_file.pynvest-lambda-send-b3-tickers-to-sqs-queue,
    aws_iam_role.pynvest-lambda-send-msgs-to-queue
  ]
}


/* -------------------------------------------------------
    Lambda function
    pynvest-lambda-get-financial-raw-data-to-s3
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-get-financial-raw-data-to-s3" {
  type        = "zip"
  source_dir  = "${path.module}/app/lambda/functions/pynvest-lambda-get-financial-raw-data-to-s3/"
  output_path = "${path.module}/app/lambda/zip/pynvest-lambda-get-financial-raw-data-to-s3.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-financial-raw-data-to-s3" {
  function_name = "pynvest-lambda-get-financial-raw-data-to-s3"
  description   = "Processa mensagens de fila SQS, coleta indicadores financeiros de ativos e salva os dados no S3"

  filename         = "${path.module}/app/lambda/zip/pynvest-lambda-get-financial-raw-data-to-s3.zip"
  source_code_hash = data.archive_file.pynvest-lambda-get-financial-raw-data-to-s3.output_base64sha256

  role    = aws_iam_role.pynvest-lambda-poll-msgs-from-queue-and-put-sor-data-to-s3.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-raw-data-to-s3,
    aws_iam_role.pynvest-lambda-poll-msgs-from-queue-and-put-sor-data-to-s3
  ]
}

# Definindo gatilho para função: fila SQS
resource "aws_lambda_event_source_mapping" "pynvest-tickers-queue" {
  function_name    = aws_lambda_function.pynvest-lambda-get-financial-raw-data-to-s3.arn
  event_source_arn = aws_sqs_queue.pynvest-tickers-queue.arn

  # Configuração do trigger
  batch_size                         = var.sqs_lambda_trigger_batch_size
  maximum_batching_window_in_seconds = var.sqs_lambda_trigger_batch_window

  scaling_config {
    maximum_concurrency = var.sqs_lambda_trigger_max_concurrency
  }
}
