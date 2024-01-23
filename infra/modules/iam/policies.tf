/* --------------------------------------------------------
ARQUIVO: policy.tf

Arquivo Terraform responsável por definir todas as policies
IAM utilizadas para criação de roles de aplicação.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para armazenamento de logs no
    CloudWatch
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-store-cloudwatch-logs" {
  template = file("${path.module}/policy-templates/pynvest-store-cloudwatch-logs.json")

  vars = {
    region_name = var.region_name
    account_id  = var.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-store-cloudwatch-logs" {
  name   = "pynvest-store-cloudwatch-logs"
  policy = data.template_file.pynvest-store-cloudwatch-logs.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para invocação de funções Lambda
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-invoke-lambda-functions" {
  template = file("${path.module}/policy-templates/pynvest-invoke-lambda-functions.json")

  vars = {
    region_name = var.region_name
    account_id  = var.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-invoke-lambda-functions" {
  name   = "pynvest-invoke-lambda-functions"
  policy = data.template_file.pynvest-invoke-lambda-functions.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para deleção de partições
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-check-and-delete-partitions" {
  template = file("${path.module}/policy-templates/pynvest-check-and-delete-partitions.json")

  vars = {
    region_name          = var.region_name
    account_id           = var.account_id
    sor_database_name    = var.databases_names_map["sor"]
    sor_acoes_table_name = var.tables_names_map["fundamentus"]["sor_acoes"]
    sor_fiis_table_name  = var.tables_names_map["fundamentus"]["sor_fiis"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-check-and-delete-partitions" {
  name   = "pynvest-check-and-delete-partitions"
  policy = data.template_file.pynvest-check-and-delete-partitions.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para envio de mensagens para filas no
    SQS
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-send-msgs-to-tickers-queues" {
  template = file("${path.module}/policy-templates/pynvest-send-msgs-to-tickers-queues.json")

  vars = {
    region_name = var.region_name
    account_id  = var.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-send-msgs-to-tickers-queues" {
  name   = "pynvest-send-msgs-to-tickers-queues"
  policy = data.template_file.pynvest-send-msgs-to-tickers-queues.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para coleta, armazenamento e catalogação
    de dados brutos na camada SoR
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-share-raw-financial-data" {
  template = file("${path.module}/policy-templates/pynvest-share-raw-financial-data.json")

  vars = {
    region_name          = var.region_name
    account_id           = var.account_id
    sor_bucket_name      = var.bucket_names_map["sor"]
    sor_database_name    = var.databases_names_map["sor"]
    sor_acoes_table_name = var.tables_names_map["fundamentus"]["sor_acoes"]
    sor_fiis_table_name  = var.tables_names_map["fundamentus"]["sor_fiis"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-share-raw-financial-data" {
  name   = "pynvest-share-raw-financial-data"
  policy = data.template_file.pynvest-share-raw-financial-data.rendered
}