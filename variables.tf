/* --------------------------------------------------------
ARQUIVO: variables.tf @ root module

Arquivo contendo todas as variáveis do módulo Terraform
definidas neste projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    VARIABLES: SQS
    Variáveis de definição de filas SQS do módulo
------------------------------------------------------- */

/*
ToDos:
    - Configurar policy para acesso básico à fila SQS (put message e get queue URL com resources restritos (começando com pynvest?))
    - Adicionar policy à role da Lambda de get tickers (remover a s3 policy)
    - Testar
    - Configurar access policy da fila em si para restringir ainda mais as permissões de put e get messages
*/

variable "sqs_tickers_queue_name" {
  description = "Nome da fila SQS responsável por receber as mensagens contendo informações dos tickers extraídos"
  type        = string
  default     = "pynvest-tickers-queue"
}

variable "sqs_visibility_timeout_seconds" {
  description = "Tempo (em segundos) em que uma mensagem recebida por um consumidor ficará invisível para outros consumidores"
  type        = number
  default     = 60
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
