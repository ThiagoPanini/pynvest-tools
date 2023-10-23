/* --------------------------------------------------------
ARQUIVO: iam-roles.tf

Arquivo Terraform responsável por definir todas as roles
a serem assumidas por aplicações neste projeto de IaC.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-send-b3-tickers-to-sqs-queue
------------------------------------------------------- */

# Definindo role IAM
resource "aws_iam_role" "pynvest-lambda-send-b3-tickers-to-sqs-queue" {
  name               = "pynvest-lambda-send-b3-tickers-to-sqs-queue"
  assume_role_policy = file("${path.module}/iam/trust/trust-lambda.json")

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-cloudwatch-logs",
    "arn:aws:iam::${local.account_id}:policy/pynvest-sqs-send-msgs-to-queue"
  ]

  depends_on = [
    aws_iam_policy.pynvest-cloudwatch-logs,
    aws_iam_policy.pynvest-sqs-send-msgs-to-queue
  ]
}
