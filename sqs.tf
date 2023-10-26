/* --------------------------------------------------------
ARQUIVO: sqs.tf

Arquivo Terraform responsável por definir as filas SQS
responsáveis por armazenar as mensagens geradas na dinâmica
do projeto.
-------------------------------------------------------- */

# Definindo fila SQS para recebimento de tickers de ações
resource "aws_sqs_queue" "pynvest-tickers-acoes-queue" {
  name = var.sqs_tickers_acoes_queue_name

  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  sqs_managed_sse_enabled = true
}

# Definindo fila SQS para recebimento de tickers de fiis
resource "aws_sqs_queue" "pynvest-tickers-fiis-queue" {
  name = var.sqs_tickers_fiis_queue_name

  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  sqs_managed_sse_enabled = true
}
