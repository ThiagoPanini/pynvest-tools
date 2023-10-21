/* --------------------------------------------------------
ARQUIVO: sqs.tf

Arquivo Terraform responsável por definir as filas SQS
responsáveis por armazenar as mensagens geradas na dinâmica
do projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    SQS queue
    pynvest-tickers-queue
------------------------------------------------------- */

# Definindo fila SQS para recebimento de tickers
resource "aws_sqs_queue" "pynvest-tickers-queue" {
  name = var.sqs_tickers_queue_name

  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  message_retention_seconds  = var.sqs_message_retention_seconds
  max_message_size           = var.sqs_max_message_size
  delay_seconds              = var.sqs_delay_seconds
  receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds

  sqs_managed_sse_enabled = true

}
