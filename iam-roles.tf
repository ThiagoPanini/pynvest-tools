/* --------------------------------------------------------
ARQUIVO: iam-roles.tf

Arquivo Terraform responsável por definir todas as roles
a serem assumidas por aplicações neste projeto de IaC.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-send-msgs-to-tickers-queues
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-send-msgs-to-tickers-queues" {
  name               = "pynvest-lambda-send-msgs-to-tickers-queues"
  assume_role_policy = file("${path.module}/iam/trust/trust-lambda.json")

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
    pynvest-lambda-put-sor-data-for-acoes
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-put-sor-data-for-acoes" {
  name               = "pynvest-lambda-put-sor-data-for-acoes"
  assume_role_policy = file("${path.module}/iam/trust/trust-lambda.json")

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-cloudwatch-logs",
    "arn:aws:iam::${local.account_id}:policy/pynvest-sqs-poll-msgs-from-acoes-queue",
    "arn:aws:iam::${local.account_id}:policy/pynvest-s3-put-sor-data-acoes",
  ]

  depends_on = [
    aws_iam_policy.pynvest-cloudwatch-logs,
    aws_iam_policy.pynvest-sqs-poll-msgs-from-acoes-queue,
    aws_iam_policy.pynvest-s3-put-sor-data-acoes
  ]
}


/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-put-sor-data-for-fiis
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-put-sor-data-for-fiis" {
  name               = "pynvest-lambda-put-sor-data-for-fiis"
  assume_role_policy = file("${path.module}/iam/trust/trust-lambda.json")

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-cloudwatch-logs",
    "arn:aws:iam::${local.account_id}:policy/pynvest-sqs-poll-msgs-from-fiis-queue",
    "arn:aws:iam::${local.account_id}:policy/pynvest-s3-put-sor-data-fiis",
  ]

  depends_on = [
    aws_iam_policy.pynvest-cloudwatch-logs,
    aws_iam_policy.pynvest-sqs-poll-msgs-from-fiis-queue,
    aws_iam_policy.pynvest-s3-put-sor-data-fiis
  ]
}
