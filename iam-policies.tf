/* --------------------------------------------------------
ARQUIVO: iam-policies.tf

Arquivo Terraform responsável por definir todas as policies
IAM utilizadas para criação de roles de aplicação.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM Policy
    pynvest-cloudwatch-logs
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-cloudwatch-logs" {
  template = file("${path.module}/iam/policies/pynvest-cloudwatch-logs.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-cloudwatch-logs" {
  name   = "pynvest-cloudwatch-logs"
  policy = data.template_file.pynvest-cloudwatch-logs.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-sqs-send-msgs-to-tickers-queues
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-sqs-send-msgs-to-tickers-queues" {
  template = file("${path.module}/iam/policies/pynvest-sqs-send-msgs-to-tickers-queues.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-sqs-send-msgs-to-tickers-queues" {
  name   = "pynvest-sqs-send-msgs-to-tickers-queues"
  policy = data.template_file.pynvest-sqs-send-msgs-to-tickers-queues.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-sqs-poll-msgs-from-acoes-queue
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-sqs-poll-msgs-from-acoes-queue" {
  template = file("${path.module}/iam/policies/pynvest-sqs-poll-msgs-from-ticker-queue.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id,
    ticker_type = "acoes"
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-sqs-poll-msgs-from-acoes-queue" {
  name   = "pynvest-sqs-poll-msgs-from-acoes-queue"
  policy = data.template_file.pynvest-sqs-poll-msgs-from-acoes-queue.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-sqs-poll-msgs-from-fiis-queue
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-sqs-poll-msgs-from-fiis-queue" {
  template = file("${path.module}/iam/policies/pynvest-sqs-poll-msgs-from-ticker-queue.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id,
    ticker_type = "fiis"
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-sqs-poll-msgs-from-fiis-queue" {
  name   = "pynvest-sqs-poll-msgs-from-fiis-queue"
  policy = data.template_file.pynvest-sqs-poll-msgs-from-acoes-queue.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-s3-put-sor-data-acoes
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-s3-put-sor-data-acoes" {
  template = file("${path.module}/iam/policies/pynvest-s3-put-sor-data.json")

  vars = {
    sor_bucket_name   = local.s3_bucket_names_map["sor"],
    table_name_prefix = "tbl_fundamentus_indicadores_acoes"
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-s3-put-sor-data-acoes" {
  name   = "pynvest-s3-put-sor-data-acoes"
  policy = data.template_file.pynvest-s3-put-sor-data-acoes.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-s3-put-sor-data-fiis
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-s3-put-sor-data-fiis" {
  template = file("${path.module}/iam/policies/pynvest-s3-put-sor-data.json")

  vars = {
    sor_bucket_name   = local.s3_bucket_names_map["sor"],
    table_name_prefix = "tbl_fundamentus_indicadores_fiis"
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-s3-put-sor-data-fiis" {
  name   = "pynvest-s3-put-sor-data-fiis"
  policy = data.template_file.pynvest-s3-put-sor-data-fiis.rendered
}
