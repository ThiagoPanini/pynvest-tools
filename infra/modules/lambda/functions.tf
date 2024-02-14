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
  source_dir  = "${path.module}/../../../app/lambda/functions/pynvest-lambda-check-and-delete-partitions/"
  output_path = "${path.module}/../../../app/lambda/zip/pynvest-lambda-check-and-delete-partitions.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-check-and-delete-partitions" {
  function_name = "pynvest-lambda-check-and-delete-partitions"
  description   = "Verifica existência de partições já processadas de tabelas SoR e as elimina para evitar duplicidade"

  # Pacote da função
  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-check-and-delete-partitions.zip"
  source_code_hash = data.archive_file.pynvest-lambda-check-and-delete-partitions.output_base64sha256

  # Configurações adicionais
  role    = var.iam_roles_arns_map["pynvest-lambda-check-and-delete-partitions"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  # Configurando memória específica para essa função por conta de necessidades
  memory_size = 192

  # Layers
  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  # Variáveis de ambiente
  environment {
    variables = {
      DATABASES_AND_TABLES = join(
        ",",
        distinct(
          flatten(
            [
              for element in var.tables_info_map :
              "${element.database}.${element.table}"
            ]
          )
        )
      )
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
  source_dir  = "${path.module}/../../../app/lambda/functions/pynvest-lambda-get-tickers/"
  output_path = "${path.module}/../../../app/lambda/zip/pynvest-lambda-get-tickers.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-tickers" {
  function_name = "pynvest-lambda-get-tickers"
  description   = "Coleta tickers de ativos da B3 e envia mensagens para filas no SQS"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-get-tickers.zip"
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


/* -------------------------------------------------------
    ARCHIVE FILE
    Zip comum a ser utlizado para próximas duas Lambdas
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-get-financial-data" {
  type        = "zip"
  source_dir  = "${path.module}/../../../app/lambda/functions/pynvest-lambda-get-financial-data/"
  output_path = "${path.module}/../../../app/lambda/zip/pynvest-lambda-get-financial-data.zip"
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-get-financial-data-for-acoes
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-financial-data-for-acoes" {
  function_name = "pynvest-lambda-get-financial-data-for-acoes"
  description   = "Extrai e consolida indicadores financeiros de Ações a partir de tickers coletados de fila SQS"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-get-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-get-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-share-sor-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      OUTPUT_BUCKET   = var.bucket_names_map["sor"],
      OUTPUT_DATABASE = var.databases_names_map["sor"],
      OUTPUT_TABLE    = var.tables_names_map["fundamentus"]["sor_acoes"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data
  ]
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-get-financial-data-for-fiis
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-get-financial-data-for-fiis" {
  function_name = "pynvest-lambda-get-financial-data-for-fiis"
  description   = "Extrai e consolida indicadores financeiros de FIIs a partir de tickers coletados de fila SQS"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-get-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-get-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-share-sor-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      OUTPUT_BUCKET   = var.bucket_names_map["sor"],
      OUTPUT_DATABASE = var.databases_names_map["sor"],
      OUTPUT_TABLE    = var.tables_names_map["fundamentus"]["sor_fiis"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data
  ]
}


/* -------------------------------------------------------
    ARCHIVE FILE
    Zip comum a ser utlizado para próximas duas Lambdas
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-prep-financial-data" {
  type        = "zip"
  source_dir  = "${path.module}/../../../app/lambda/functions/pynvest-lambda-prep-financial-data/"
  output_path = "${path.module}/../../../app/lambda/zip/pynvest-lambda-prep-financial-data.zip"
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-prep-financial-data-for-acoes
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-prep-financial-data-for-acoes" {
  function_name = "pynvest-lambda-prep-financial-data-for-acoes"
  description   = "Lê indicadores brutos de Ações já extraídos e armazenados no S3 e prepara tipos primitivos para a camada SoT"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-prep-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-prep-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-share-sot-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      OUTPUT_BUCKET   = var.bucket_names_map["sot"],
      OUTPUT_DATABASE = var.databases_names_map["sot"],
      OUTPUT_TABLE    = var.tables_names_map["fundamentus"]["sot_acoes"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data
  ]
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-prep-financial-data-for-fiis
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-prep-financial-data-for-fiis" {
  function_name = "pynvest-lambda-prep-financial-data-for-fiis"
  description   = "Lê indicadores brutos de FIIs já extraídos e armazenados no S3 e prepara tipos primitivos para a camada SoT"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-prep-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-prep-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-share-sot-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      OUTPUT_BUCKET   = var.bucket_names_map["sot"],
      OUTPUT_DATABASE = var.databases_names_map["sot"],
      OUTPUT_TABLE    = var.tables_names_map["fundamentus"]["sot_fiis"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data
  ]
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-specialize-financial-data
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-specialize-financial-data" {
  type        = "zip"
  source_dir  = "${path.module}/../../../app/lambda/functions/pynvest-lambda-specialize-financial-data/"
  output_path = "${path.module}/../../../app/lambda/zip/pynvest-lambda-specialize-financial-data.zip"
}

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-specialize-financial-data" {
  function_name = "pynvest-lambda-specialize-financial-data"
  description   = "Lê indicadores de Ações ou FIIs para criar uma visão especializada de ativos de ambos os tipos"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-specialize-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-specialize-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-share-spec-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      OUTPUT_BUCKET   = var.bucket_names_map["spec"],
      OUTPUT_DATABASE = var.databases_names_map["spec"],
      OUTPUT_TABLE    = var.tables_names_map["fundamentus"]["spec_ativos"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-get-financial-data
  ]
}


/* -------------------------------------------------------
    ARCHIVE FILE
    Zip comum a ser utlizado para próximas três Lambdas
------------------------------------------------------- */

# Criando pacote zip da função a ser criada
data "archive_file" "pynvest-lambda-dedup-financial-data" {
  type        = "zip"
  source_dir  = "${path.module}/../../../app/lambda/functions/pynvest-lambda-dedup-financial-data/"
  output_path = "${path.module}/../../../app/lambda/zip/pynvest-lambda-dedup-financial-data.zip"
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-dedup-financial-data-for-acoes
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-dedup-financial-data-for-acoes" {
  function_name = "pynvest-lambda-dedup-financial-data-for-acoes"
  description   = "Realiza a leitura da tabela SoT de Ações e realiza a remoção de dados duplicados"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-dedup-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-dedup-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-dedup-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      TARGET_BUCKET   = var.bucket_names_map["sot"],
      TARGET_DATABASE = var.databases_names_map["sot"],
      TARGET_TABLE    = var.tables_names_map["fundamentus"]["sot_acoes"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-dedup-financial-data
  ]
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-dedup-financial-data-for-fiis
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-dedup-financial-data-for-fiis" {
  function_name = "pynvest-lambda-dedup-financial-data-for-fiis"
  description   = "Realiza a leitura da tabela SoT de FIIs e realiza a remoção de dados duplicados"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-dedup-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-dedup-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-dedup-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      TARGET_BUCKET   = var.bucket_names_map["sot"],
      TARGET_DATABASE = var.databases_names_map["sot"],
      TARGET_TABLE    = var.tables_names_map["fundamentus"]["sot_fiis"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-dedup-financial-data
  ]
}


/* -------------------------------------------------------
    LAMBDA FUNCTION
    pynvest-lambda-dedup-financial-data-for-spec-ativos
------------------------------------------------------- */

# Criando função Lambda
resource "aws_lambda_function" "pynvest-lambda-dedup-financial-data-for-spec-ativos" {
  function_name = "pynvest-lambda-dedup-financial-data-for-spec-ativos"
  description   = "Realiza a leitura da tabela Spec de cotação de ativos e realiza a remoção de dados duplicados"

  filename         = "${path.module}/../../../app/lambda/zip/pynvest-lambda-dedup-financial-data.zip"
  source_code_hash = data.archive_file.pynvest-lambda-dedup-financial-data.output_base64sha256

  role    = var.iam_roles_arns_map["pynvest-lambda-dedup-financial-data"]
  handler = "lambda_function.lambda_handler"
  runtime = var.functions_python_runtime
  timeout = var.functions_timeout

  layers = [
    "arn:aws:lambda:${var.region_name}:336392948345:layer:AWSSDKPandas-Python310:5"
  ]

  environment {
    variables = {
      TARGET_BUCKET   = var.bucket_names_map["spec"],
      TARGET_DATABASE = var.databases_names_map["spec"],
      TARGET_TABLE    = var.tables_names_map["fundamentus"]["spec_ativos"]
    }
  }

  depends_on = [
    data.archive_file.pynvest-lambda-dedup-financial-data
  ]
}
