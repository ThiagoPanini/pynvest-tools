/* --------------------------------------------------------
ARQUIVO: roles.tf

Arquivo Terraform responsável por definir todas as roles
a serem assumidas por aplicações neste projeto de IaC.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM ROLE
    pynvest-lambda-check-and-delete-partitions
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-check-and-delete-partitions" {
  name                  = "pynvest-lambda-check-and-delete-partitions"
  assume_role_policy    = file("${path.module}/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${var.account_id}:policy/pynvest-store-cloudwatch-logs",
    "arn:aws:iam::${var.account_id}:policy/pynvest-invoke-lambda-functions",
    "arn:aws:iam::${var.account_id}:policy/pynvest-check-and-delete-partitions"
  ]

  depends_on = [
    aws_iam_policy.pynvest-store-cloudwatch-logs,
    aws_iam_policy.pynvest-invoke-lambda-functions,
    aws_iam_policy.pynvest-check-and-delete-partitions
  ]
}


/* -------------------------------------------------------
    IAM ROLE
    pynvest-lambda-send-msgs-to-tickers-queue
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-send-msgs-to-tickers-queue" {
  name                  = "pynvest-lambda-send-msgs-to-tickers-queues"
  assume_role_policy    = file("${path.module}/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${var.account_id}:policy/pynvest-store-cloudwatch-logs",
    "arn:aws:iam::${var.account_id}:policy/pynvest-send-msgs-to-tickers-queues"
  ]

  depends_on = [
    aws_iam_policy.pynvest-store-cloudwatch-logs,
    aws_iam_policy.pynvest-send-msgs-to-tickers-queues
  ]
}


/* -------------------------------------------------------
    IAM ROLE
    pynvest-lambda-share-sor-financial-data
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-share-sor-financial-data" {
  name                  = "pynvest-lambda-share-sor-financial-data"
  assume_role_policy    = file("${path.module}/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${var.account_id}:policy/pynvest-store-cloudwatch-logs",
    "arn:aws:iam::${var.account_id}:policy/pynvest-share-sor-financial-data"
  ]

  depends_on = [
    aws_iam_policy.pynvest-store-cloudwatch-logs,
    aws_iam_policy.pynvest-share-sor-financial-data
  ]
}


/* -------------------------------------------------------
    IAM ROLE
    pynvest-lambda-share-sot-financial-data
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-share-sot-financial-data" {
  name                  = "pynvest-lambda-share-sot-financial-data"
  assume_role_policy    = file("${path.module}/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${var.account_id}:policy/pynvest-store-cloudwatch-logs",
    "arn:aws:iam::${var.account_id}:policy/pynvest-share-sot-financial-data"
  ]

  depends_on = [
    aws_iam_policy.pynvest-store-cloudwatch-logs,
    aws_iam_policy.pynvest-share-sot-financial-data
  ]
}


/* -------------------------------------------------------
    IAM ROLE
    pynvest-lambda-share-spec-financial-data
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-share-spec-financial-data" {
  name                  = "pynvest-lambda-share-spec-financial-data"
  assume_role_policy    = file("${path.module}/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${var.account_id}:policy/pynvest-store-cloudwatch-logs",
    "arn:aws:iam::${var.account_id}:policy/pynvest-share-spec-financial-data"
  ]

  depends_on = [
    aws_iam_policy.pynvest-store-cloudwatch-logs,
    aws_iam_policy.pynvest-share-spec-financial-data
  ]
}


/* -------------------------------------------------------
    IAM ROLE
    pynvest-lambda-dedup-financial-data
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-dedup-financial-data" {
  name                  = "pynvest-lambda-dedup-financial-data"
  assume_role_policy    = file("${path.module}/trust/trust-lambda.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${var.account_id}:policy/pynvest-store-cloudwatch-logs",
    "arn:aws:iam::${var.account_id}:policy/pynvest-dedup-financial-data"
  ]

  depends_on = [
    aws_iam_policy.pynvest-store-cloudwatch-logs,
    aws_iam_policy.pynvest-dedup-financial-data
  ]
}


/* -------------------------------------------------------
    IAM ROLE
    pynvest-sfn-invoke-lambda-functions
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-sfn-invoke-lambda-functions" {
  name                  = "pynvest-sfn-invoke-lambda-functions"
  assume_role_policy    = file("${path.module}/trust/trust-sfn.json")
  force_detach_policies = true

  managed_policy_arns = [
    "arn:aws:iam::${var.account_id}:policy/pynvest-invoke-lambda-functions"
  ]

  depends_on = [
    aws_iam_policy.pynvest-invoke-lambda-functions
  ]
}
