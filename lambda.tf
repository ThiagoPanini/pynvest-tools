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

  role    = aws_iam_role.pynvest-lambda-send-b3-tickers-to-sqs-queue.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]
}
