/* --------------------------------------------------------
ARQUIVO: variables.tf @ root module

Arquivo contendo todas as variáveis do módulo Terraform
definidas neste projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    VARIABLES: SQS
    Variáveis de definição de filas SQS do módulo
------------------------------------------------------- */

variable "sqs_tickers_queue_name" {
  description = "Nome da fila SQS responsável por receber as mensagens contendo informações dos tickers extraídos"
  type        = string
  default     = "pynvest-tickers-queue"
}

variable "sqs_visibility_timeout_seconds" {
  description = "Tempo (em segundos) em que uma mensagem recebida por um consumidor ficará invisível para outros consumidores"
  type        = number
  default     = 360
}

variable "sqs_message_retention_seconds" {
  description = "Tempo (em segundos) em que uma mensagem não deletada continua armazenada. Após esse período, as mensagens da fila são deletadas"
  type        = number
  default     = 3600
}

variable "sqs_max_message_size" {
  description = "Tamanho máximo (em bytes) das mensagens da fila"
  type        = number
  default     = 131072 # 120Kb
}

variable "sqs_delay_seconds" {
  description = "Delay em que novas mensagens chegam à fila caso os consumidores necessitem de mais tempo para processamento"
  type        = number
  default     = 0
}

variable "sqs_receive_wait_time_seconds" {
  description = "Tempo máximo (em segundos) que processos de pooling irão aguardar por mensagens disponíveis (Short Pooling versus Long Pooling)"
  type        = number
  default     = 0
}

variable "sqs_lambda_trigger_batch_size" {
  description = "Número máximo de registros a serem enviados para a função em cada batch"
  type        = number
  default     = 10
}

variable "sqs_lambda_trigger_batch_window" {
  description = "Valor máximo de tempo (em segundos) que a função irá aguardar para a coleta de registros antes da invocação"
  type        = number
  default     = 5
}

variable "sqs_lambda_trigger_max_concurrency" {
  description = "Número máximo de funções concorrentes a serem invocadas pelo gatilho"
  type        = number
  default     = 2
}
