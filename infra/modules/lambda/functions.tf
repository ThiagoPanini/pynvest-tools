/* --------------------------------------------------------
ARQUIVO: functions.tf @ lambda module

Arquivo responsável por consolidar todas as definições
de funções Lambda existentes no projeto. Para consultar
recursos alternativos, como triggers e permissionamentos,
arquivos Terraform específicos são disponibilizados neste
módulo.
-------------------------------------------------------- */

/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-check-and-delete-partitions
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-check-and-delete-partitions" {
  type        = "zip"
  source_dir  = "${path.root}/app/lambda/functions/pynvest-lambda-check-and-delete-partitions/"
  output_path = "${path.root}/app/lambda/zip/pynvest-lambda-check-and-delete-partitions.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-check-and-delete-partitions" {
  function_name = "pynvest-lambda-check-and-delete-partitions"
  description   = "Verifica existência de partições já processadas de tabelas SoR e as elimina para evitar duplicidade"

  # Pacote da função
  filename         = "${path.root}/app/lambda/zip/pynvest-lambda-check-and-delete-partitions.zip"
  source_code_hash = data.archive_file.pynvest-lambda-check-and-delete-partitions.output_base64sha256

  # Configurações adicionais
  role    = var.iam_roles_arns_map["pynvest-lambda-check-and-delete-partitions"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  # Layers
  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  # Variáveis de ambiente
  environment {
    variables = {
      DATABASE_NAME = var.databases_names_map["sor"],
      TABLE_NAMES   = "${var.tables_names_map["fundamentus"]["sor_acoes"]},${var.tables_names_map["fundamentus"]["sor_fiis"]}"
    }
  }

  # Dependências de recursos
  depends_on = [
    data.archive_file.pynvest-lambda-check-and-delete-partitions
  ]
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-get-tickers
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-get-tickers" {
  type        = "zip"
  source_dir  = "${path.root}/app/lambda/functions/pynvest-lambda-get-tickers/"
  output_path = "${path.root}/app/lambda/zip/pynvest-lambda-get-tickers.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-tickers" {
  function_name = "pynvest-lambda-get-tickers"
  description   = "Coleta tickers de ativos da B3 e envia mensagens para filas no SQS"

  filename         = "${path.root}/app/lambda/zip/pynvest-lambda-get-tickers.zip"
  source_code_hash = data.archive_file.pynvest-lambda-get-tickers.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-send-msgs-to-tickers-queue"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  depends_on = [
    data.archive_file.pynvest-lambda-get-tickers
  ]
}
