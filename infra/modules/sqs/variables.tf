/* --------------------------------------------------------
ARQUIVO: variables.tf @ sqs module

Arquivo de variáveis aceitas pelo módulo sqs do projeto
Terraform.
-------------------------------------------------------- */

variable "sqs_tickers_acoes_queue_name" {
  description = "Nome da fila SQS responsável por receber as mensagens contendo informações dos tickers de Ações extraídos"
  type        = string
}

variable "sqs_tickers_fiis_queue_name" {
  description = "Nome da fila SQS responsável por receber as mensagens contendo informações dos tickers de FIIs extraídos"
  type        = string
}

variable "sqs_visibility_timeout_seconds" {
  description = "Tempo (em segundos) em que uma mensagem recebida por um consumidor ficará invisível para outros consumidores"
  type        = number
}

variable "sqs_message_retention_seconds" {
  description = "Tempo (em segundos) em que uma mensagem não deletada continua armazenada. Após esse período, as mensagens da fila são deletadas"
  type        = number
}

variable "sqs_max_message_size" {
  description = "Tamanho máximo (em bytes) das mensagens da fila"
  type        = number
}

variable "sqs_delay_seconds" {
  description = "Delay em que novas mensagens chegam à fila caso os consumidores necessitem de mais tempo para processamento"
  type        = number
}

variable "sqs_receive_wait_time_seconds" {
  description = "Tempo máximo (em segundos) que processos de pooling irão aguardar por mensagens disponíveis (Short Pooling versus Long Pooling)"
  type        = number
}

variable "sqs_lambda_trigger_batch_size" {
  description = "Número máximo de registros a serem enviados para a função em cada batch"
  type        = number
}

variable "sqs_lambda_trigger_batch_window" {
  description = "Valor máximo de tempo (em segundos) que a função irá aguardar para a coleta de registros antes da invocação"
  type        = number
}

variable "sqs_lambda_trigger_max_concurrency" {
  description = "Número máximo de funções concorrentes a serem invocadas pelo gatilho"
  type        = number
}

