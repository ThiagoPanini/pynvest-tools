/* --------------------------------------------------------
ARQUIVO: iam-roles.tf

Arquivo Terraform responsável por definir todas as roles
a serem assumidas por aplicações neste projeto de IaC.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-send-msgs-to-tickers-queue
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-send-msgs-to-tickers-queue" {
  name                  = "pynvest-lambda-send-msgs-to-tickers-queue"
  assume_role_policy    = file("${path.module}/iam/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-cloudwatch-logs",
    "arn:aws:iam::${local.account_id}:policy/pynvest-sqs-send-msgs-to-tickers-queues"
  ]

  depends_on = [
    aws_iam_policy.pynvest-cloudwatch-logs,
    aws_iam_policy.pynvest-sqs-send-msgs-to-tickers-queues
  ]
}


/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-write-and-catalog-sor-data-for-acoes
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-write-and-catalog-sor-data-for-acoes" {
  name                  = "pynvest-lambda-write-and-catalog-sor-data-for-acoes"
  assume_role_policy    = file("${path.module}/iam/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-cloudwatch-logs",
    "arn:aws:iam::${local.account_id}:policy/pynvest-sqs-poll-msgs-from-acoes-queue",
    "arn:aws:iam::${local.account_id}:policy/pynvest-s3-manage-sor-data-for-acoes",
    "arn:aws:iam::${local.account_id}:policy/pynvest-gluedatacatalog-manage-sor-acoes-table",
  ]

  depends_on = [
    aws_iam_policy.pynvest-cloudwatch-logs,
    aws_iam_policy.pynvest-sqs-poll-msgs-from-acoes-queue,
    aws_iam_policy.pynvest-s3-manage-sor-data-for-acoes,
    aws_iam_policy.pynvest-gluedatacatalog-manage-sor-acoes-table
  ]
}


/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-write-and-catalog-sor-data-for-fiis
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-write-and-catalog-sor-data-for-fiis" {
  name                  = "pynvest-lambda-write-and-catalog-sor-data-for-fiis"
  assume_role_policy    = file("${path.module}/iam/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-cloudwatch-logs",
    "arn:aws:iam::${local.account_id}:policy/pynvest-sqs-poll-msgs-from-fiis-queue",
    "arn:aws:iam::${local.account_id}:policy/pynvest-s3-manage-sor-data-for-fiis",
    "arn:aws:iam::${local.account_id}:policy/pynvest-gluedatacatalog-manage-sor-fiis-table",
  ]

  depends_on = [
    aws_iam_policy.pynvest-cloudwatch-logs,
    aws_iam_policy.pynvest-sqs-poll-msgs-from-fiis-queue,
    aws_iam_policy.pynvest-s3-manage-sor-data-for-fiis,
    aws_iam_policy.pynvest-gluedatacatalog-manage-sor-fiis-table
  ]
}


/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-check-sor-partitions
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-check-sor-partitions" {
  name                  = "pynvest-lambda-check-sor-partitions"
  assume_role_policy    = file("${path.module}/iam/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-lambda-invoke-functions",
    "arn:aws:iam::${local.account_id}:policy/pynvest-cloudwatch-logs",
    "arn:aws:iam::${local.account_id}:policy/pynvest-s3-manage-sor-data-for-acoes",
    "arn:aws:iam::${local.account_id}:policy/pynvest-s3-manage-sor-data-for-fiis",
    "arn:aws:iam::${local.account_id}:policy/pynvest-gluedatacatalog-check-partitions-sor-tables"
  ]

  depends_on = [
    aws_iam_policy.pynvest-lambda-invoke-functions,
    aws_iam_policy.pynvest-cloudwatch-logs,
    aws_iam_policy.pynvest-s3-manage-sor-data-for-acoes,
    aws_iam_policy.pynvest-s3-manage-sor-data-for-fiis,
    aws_iam_policy.pynvest-gluedatacatalog-check-partitions-sor-tables
  ]
}

