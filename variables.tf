/* --------------------------------------------------------
ARQUIVO: variables.tf @ root module

Arquivo contendo todas as variáveis do módulo Terraform
definidas neste projeto.
-------------------------------------------------------- */

/* -------------------------------------------------------
    VARIABLES: Eventbridge
    Variáveis de definição de gatilhos do Eventbridge
------------------------------------------------------- */

variable "schedule_expression_to_initialize" {
  description = "Expressão cron responsável por engatilhar a primeira etapa do processo"
  type        = string
  default     = "cron(0 22 ? * MON-FRI *)"
}


/* -------------------------------------------------------
    VARIABLES: SQS
    Variáveis de definição de filas SQS do módulo
------------------------------------------------------- */

variable "sqs_tickers_acoes_queue_name" {
  description = "Nome da fila SQS responsável por receber as mensagens contendo informações dos tickers de Ações extraídos"
  type        = string
  default     = "pynvest-tickers-acoes-queue"
}

variable "sqs_tickers_fiis_queue_name" {
  description = "Nome da fila SQS responsável por receber as mensagens contendo informações dos tickers de FIIs extraídos"
  type        = string
  default     = "pynvest-tickers-fiis-queue"
}

variable "sqs_visibility_timeout_seconds" {
  description = "Tempo (em segundos) em que uma mensagem recebida por um consumidor ficará invisível para outros consumidores"
  type        = number
  default     = 1080
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
  default     = 10
}


/* -------------------------------------------------------
    VARIABLES: S3 e Glue Data Catalog
    Armazenamento e catalogação dos dados gerados
------------------------------------------------------- */

variable "bucket_names_map" {
  description = "Dicionário (map) contendo nomes dos buckets SoR, SoT e Spec da conta AWS alvo de implantação dos recursos. O objetivo desta variável e permitir que o usuário forneça seus próprios buckets para armazenamento dos arquivos gerados. O correto preenchimento desta variável exige que as referências de nomes sejam fornecidas dentro das chaves 'sor', 'sot' e 'spec'. O usuário também pode fornecer o mesmo nome de bucket para as três quebras, caso queira armazenar os dados das tabelas em um único bucket."
  type        = map(string)
  default = {
    "sor" = "value"
  }
}

variable "flag_create_databases" {
  description = "Flag para validar a criação de databases no Glue Data Catalog caso o usuário não tenha ou não queira utilizar databases já existentes para catalogação das tabelas geradas"
  type        = bool
  default     = true
}

variable "databases_names_map" {
  description = "Dicionário (map) contendo os nomes dos databases no Glue Data Catalog para catalogação de tabelas SoR, SoT e Spec. O correto preenchimento desta variável exige que as referências de nomes sejam fornecidas dentro das chaves 'sor', 'sot' e 'spec'. O usuário também pode fornecer o mesmo nome de database para as três quebras, caso queira armazenar os dados das tabelas em um único database."
  type        = map(string)
  default = {
    "sor"  = "db_pynvest_sor"
    "sot"  = "db_pynvest_sot"
    "spec" = "db_pynvest_spec"
  }
}

variable "sor_acoes_table_name" {
  description = "Nome da tabela SoR gerada a partir do processamento de indicadores financeiros de Ações"
  type        = string
  default     = "tbsor_fundamentus_indicadores_brutos_fiis"
}

variable "sor_fiis_table_name" {
  description = "Nome da tabela SoR gerada a partir do processamento de indicadores financeiros de Fundos Imobiliários"
  type        = string
  default     = "tbsor_fundamentus_indicadores_brutos_fiis"
}
