/* --------------------------------------------------------
ARQUIVO: lambda.tf

Arquivo Terraform responsável por definir todas as funções
Lambda utilizadas para coleta e gerenciamento de dados no
projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    Lambda function
    pynvest-get-tickers-to-queue
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-get-tickers-to-queue" {
  type        = "zip"
  source_dir  = "${path.module}/app/lambda/functions/pynvest-get-tickers-to-queue/"
  output_path = "${path.module}/app/lambda/zip/pynvest-get-tickers-to-queue.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-get-tickers-to-queue" {
  function_name = "pynvest-get-tickers-to-queue"
  filename      = "${path.module}/app/lambda/zip/pynvest-get-tickers-to-queue.zip"
  role          = aws_iam_role.pynvest-lambda-get-raw-data-role.arn

  source_code_hash = data.archive_file.pynvest-get-tickers-to-queue.output_base64sha256

  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 30

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]
}
