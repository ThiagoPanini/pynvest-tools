/* --------------------------------------------------------
ARQUIVO: lambda.tf

Arquivo Terraform responsável por definir todas as funções
Lambda utilizadas para coleta e gerenciamento de dados no
projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    Lambda function
    pynvest-lambda-check-sor-partitions
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-check-sor-partitions" {
  type        = "zip"
  source_dir  = "${path.module}/app/lambda/functions/pynvest-lambda-check-sor-partitions/"
  output_path = "${path.module}/app/lambda/zip/pynvest-lambda-check-sor-partitions.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-check-sor-partitions" {
  function_name = "pynvest-lambda-check-sor-partitions"
  description   = "Verifica existência de partições já processadas de tabelas SoR e as elimina para evitar duplicidade"

  # Pacote da função
  filename         = "${path.module}/app/lambda/zip/pynvest-lambda-check-sor-partitions.zip"
  source_code_hash = data.archive_file.pynvest-lambda-check-sor-partitions.output_base64sha256

  # Configurações adicionais
  role    = aws_iam_role.pynvest-lambda-check-sor-partitions.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  # Layers
  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  # Variáveis de ambiente
  environment {
    variables = {
      DATABASE_NAME = var.databases_names_map["sor"],
      TABLE_NAMES   = "${var.sor_acoes_table_name},${var.sor_fiis_table_name}"
    }
  }

  # Dependências de recursos
  depends_on = [
    data.archive_file.pynvest-lambda-check-sor-partitions,
    aws_iam_role.pynvest-lambda-check-sor-partitions
  ]
}

# Definindo regra de execução agendada via Eventbridge
resource "aws_cloudwatch_event_rule" "trigger-pynvest-lambda-check-sor-partitions" {
  name                = "trigger-${aws_lambda_function.pynvest-lambda-check-sor-partitions.function_name}"
  description         = "Regra de execução agendada da função ${aws_lambda_function.pynvest-lambda-check-sor-partitions.function_name}"
  schedule_expression = var.schedule_expression_to_initialize
}

# Vinculando regra de agendamento à função
resource "aws_cloudwatch_event_target" "trigger-pynvest-lambda-check-sor-partitions" {
  arn  = aws_lambda_function.pynvest-lambda-check-sor-partitions.arn
  rule = aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-sor-partitions.name

  depends_on = [
    aws_lambda_function.pynvest-lambda-check-sor-partitions,
    aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-sor-partitions
  ]
}

# Configurando permissões para invocação da função via Eventbridge
resource "aws_lambda_permission" "allow-eventbridge-to-pynvest-lambda-check-sor-partitions" {
  statement_id  = "AllowExecutionFromEventbridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-check-sor-partitions.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-sor-partitions.arn

  depends_on = [
    aws_lambda_function.pynvest-lambda-check-sor-partitions,
    aws_cloudwatch_event_rule.trigger-pynvest-lambda-check-sor-partitions
  ]
}


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

  role    = aws_iam_role.pynvest-lambda-send-msgs-to-tickers-queue.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  depends_on = [
    data.archive_file.pynvest-lambda-send-tickers-to-sqs-queues,
    aws_iam_role.pynvest-lambda-send-msgs-to-tickers-queue
  ]
}

# Configurando permissões para invocar função Lambda
resource "aws_lambda_permission" "invoke-permissions-to-pynvest-lambda-send-tickers-to-sqs-queues" {
  statement_id  = "AllowExecutionFromSourceLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues.function_name
  principal     = "lambda.amazonaws.com"
  source_arn    = aws_lambda_function.pynvest-lambda-check-sor-partitions.arn

  depends_on = [
    aws_lambda_function.pynvest-lambda-check-sor-partitions,
    aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues
  ]
}

# Configurando invocação da Lambda através de outra Lambda (em caso de sucesso)
resource "aws_lambda_function_event_invoke_config" "destination-pynvest-lambda-send-tickers-to-sqs-queues" {
  function_name = aws_lambda_function.pynvest-lambda-check-sor-partitions.function_name

  destination_config {
    on_success {
      destination = aws_lambda_function.pynvest-lambda-send-tickers-to-sqs-queues.arn
    }
  }

  depends_on = [
    aws_lambda_permission.invoke-permissions-to-pynvest-lambda-send-tickers-to-sqs-queues
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

  role    = aws_iam_role.pynvest-lambda-write-and-catalog-sor-data-for-acoes.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      OUTPUT_BUCKET = local.bucket_names_map["sor"],
      DATABASE_NAME = var.databases_names_map["sor"],
      TABLE_NAME    = var.sor_acoes_table_name
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data,
    aws_iam_role.pynvest-lambda-write-and-catalog-sor-data-for-acoes
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

  role    = aws_iam_role.pynvest-lambda-write-and-catalog-sor-data-for-fiis.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.10"
  timeout = 180

  layers = [
    "arn:aws:lambda:${local.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      OUTPUT_BUCKET = local.bucket_names_map["sor"],
      DATABASE_NAME = var.databases_names_map["sor"],
      TABLE_NAME    = var.sor_fiis_table_name
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data,
    aws_iam_role.pynvest-lambda-write-and-catalog-sor-data-for-fiis
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
