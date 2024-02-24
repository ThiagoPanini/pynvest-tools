/* --------------------------------------------------------
ARQUIVO: main.tf @ sqs module

Arquivo principal do módulo sqs do projeto Terraform onde
recursos de infraestrutura relacionados à filas do SQS
são definidos e implantados.

-------------------------------------------------------- */

# Definindo fila SQS para recebimento de tickers de ações
resource "aws_sqs_queue" "pynvest-tickers-acoes-queue" {
  name = "pynvest-tickers-acoes-queue"

  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  sqs_managed_sse_enabled = true

  tags = var.module_default_tags
}

# Definindo fila SQS para recebimento de tickers de fiis
resource "aws_sqs_queue" "pynvest-tickers-fiis-queue" {
  name = "pynvest-tickers-fiis-queue"

  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  sqs_managed_sse_enabled = true

  tags = var.module_default_tags
}
