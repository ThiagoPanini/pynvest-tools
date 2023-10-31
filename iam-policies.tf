/* --------------------------------------------------------
ARQUIVO: iam-policy.tf

Arquivo Terraform responsável por definir todas as policy
IAM utilizadas para criação de roles de aplicação.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM Policy
    pynvest-lambda-invoke-functions
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-lambda-invoke-functions" {
  template = file("${path.module}/iam/policy-templates/pynvest-lambda-invoke-functions.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-lambda-invoke-functions" {
  name   = "pynvest-lambda-invoke-functions"
  policy = data.template_file.pynvest-lambda-invoke-functions.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-cloudwatch-logs
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-cloudwatch-logs" {
  template = file("${path.module}/iam/policy-templates/pynvest-cloudwatch-logs.json")

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
    pynvest-gluedatacatalog-check-partitions-sor-tables
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-gluedatacatalog-check-partitions-sor-tables" {
  template = file("${path.module}/iam/policy-templates/pynvest-gluedatacatalog-check-partitions-sor-tables.json")

  vars = {
    region_name       = local.region_name,
    account_id        = local.account_id,
    sor_database_name = var.databases_names_map["sor"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-gluedatacatalog-check-partitions-sor-tables" {
  name   = "pynvest-gluedatacatalog-check-partitions-sor-tables"
  policy = data.template_file.pynvest-gluedatacatalog-check-partitions-sor-tables.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-sqs-send-msgs-to-tickers-queues
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-sqs-send-msgs-to-tickers-queues" {
  template = file("${path.module}/iam/policy-templates/pynvest-sqs-send-msgs-to-tickers-queues.json")

  vars = {
    region_name = local.region_name,
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
  template = file("${path.module}/iam/policy-templates/pynvest-sqs-poll-msgs-from-tickers-queues.json")

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
  template = file("${path.module}/iam/policy-templates/pynvest-sqs-poll-msgs-from-tickers-queues.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id,
    ticker_type = "fiis"
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-sqs-poll-msgs-from-fiis-queue" {
  name   = "pynvest-sqs-poll-msgs-from-fiis-queue"
  policy = data.template_file.pynvest-sqs-poll-msgs-from-fiis-queue.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-s3-manage-sor-data-for-acoes
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-s3-manage-sor-data-for-acoes" {
  template = file("${path.module}/iam/policy-templates/pynvest-s3-manage-sor-data.json")

  vars = {
    sor_bucket_name = local.bucket_names_map["sor"],
    sor_table_name  = var.sor_acoes_table_name
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-s3-manage-sor-data-for-acoes" {
  name   = "pynvest-s3-manage-sor-data-for-acoes"
  policy = data.template_file.pynvest-s3-manage-sor-data-for-acoes.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-s3-manage-sor-data-for-fiis
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-s3-manage-sor-data-for-fiis" {
  template = file("${path.module}/iam/policy-templates/pynvest-s3-manage-sor-data.json")

  vars = {
    sor_bucket_name = local.bucket_names_map["sor"],
    sor_table_name  = var.sor_fiis_table_name
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-s3-manage-sor-data-for-fiis" {
  name   = "pynvest-s3-manage-sor-data-for-fiis"
  policy = data.template_file.pynvest-s3-manage-sor-data-for-fiis.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-gluedatacatalog-manage-sor-acoes-table
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-gluedatacatalog-manage-sor-acoes-table" {
  template = file("${path.module}/iam/policy-templates/pynvest-gluedatacatalog-manage-sor-tables.json")

  vars = {
    region_name       = local.region_name,
    account_id        = local.account_id,
    sor_database_name = var.databases_names_map["sor"],
    sor_table_name    = var.sor_acoes_table_name
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-gluedatacatalog-manage-sor-acoes-table" {
  name   = "pynvest-gluedatacatalog-manage-sor-acoes-table"
  policy = data.template_file.pynvest-gluedatacatalog-manage-sor-acoes-table.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-gluedatacatalog-manage-sor-fiis-table
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-gluedatacatalog-manage-sor-fiis-table" {
  template = file("${path.module}/iam/policy-templates/pynvest-gluedatacatalog-manage-sor-tables.json")

  vars = {
    region_name       = local.region_name,
    account_id        = local.account_id,
    sor_database_name = var.databases_names_map["sor"],
    sor_table_name    = var.sor_fiis_table_name
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-gluedatacatalog-manage-sor-fiis-table" {
  name   = "pynvest-gluedatacatalog-manage-sor-fiis-table"
  policy = data.template_file.pynvest-gluedatacatalog-manage-sor-fiis-table.rendered
}
