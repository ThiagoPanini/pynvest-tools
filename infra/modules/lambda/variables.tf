/* --------------------------------------------------------
ARQUIVO: variables.tf @ lambda module

Arquivo de variáveis aceitas pelo módulo lambda do projeto
Terraform.
-------------------------------------------------------- */

variable "functions_python_runtime" {
  description = "Definição do runtime (versão) da linguagem Python associada às funções"
  type        = string
}

variable "functions_timeout" {
  description = "Timeout das funções Lambda"
  type        = number
}

variable "functions_memory_size" {
  description = "Quantidade de memória (MB) a ser alocada para as funções Lambda"
  type        = number
}

variable "region_name" {
  description = "Nome da região alvo da implantação utilizado para composição de ARNs de recursos mapeados às funções Lambda"
  type        = string
}

variable "databases_names_map" {
  description = "Dicionário (map) contendo os nomes dos databases no Glue Data Catalog para catalogação de tabelas SoR, SoT e Spec. O correto preenchimento desta variável exige que as referências de nomes sejam fornecidas dentro das chaves 'sor', 'sot' e 'spec'. O usuário também pode fornecer o mesmo nome de database para as três quebras, caso queira armazenar os dados das tabelas em um único database."
  type        = map(string)
}

variable "tables_names_map" {
  description = "Dicionário (map) contendo os nomes de todas as tabelas a serem criadas no Glue Data Catalog para armazenamento de dados de indicadores financeiros em todas as camadas SoR, SoT e Spec"
  type        = map(map(string))
}

variable "tables_info_map" {
  description = "Dicionário (map) com todas as informações das tabelas a serem criadas no Glue Data Catalog em todas as camadas do projeto (SoR, SoT e Spec)"
  type        = map(map(string))
}

variable "iam_roles_arns_map" {
  description = "Dicionário (map) contendo informações sobre todas as ARNs de roles criadas no módulo IAM para serem vinculadas às funções Lambda criadas neste módulo"
  type        = map(string)
}

variable "bucket_names_map" {
  description = "Dicionário (map) contendo nomes dos buckets SoR, SoT e Spec da conta AWS alvo de implantação dos recursos. O objetivo desta variável e permitir que o usuário forneça seus próprios buckets para armazenamento dos arquivos gerados. O correto preenchimento desta variável exige que as referências de nomes sejam fornecidas dentro das chaves 'sor', 'sot' e 'spec'. O usuário também pode fornecer o mesmo nome de bucket para as três quebras, caso queira armazenar os dados das tabelas em um único bucket."
  type        = map(string)
}

variable "sqs_queues_arn_map" {
  description = "Dicionário (map) contendo informações sobre ARNs de filas SQS criadas no módulo sqs a serem associadas como gatilhos para execução de funções Lambda neste módulo."
  type        = map(string)
}

variable "cron_expression_to_initialize_process" {
  description = "Expressão cron responsável por engatilhar todo o processo de obtenção e atualização dos dados"
  type        = string
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

variable "module_default_tags" {
  description = "Conjunto de tags padrão a serem associadas aos recursos do módulo"
  type        = map(string)
}
