/* --------------------------------------------------------
ARQUIVO: variables.tf @ sfn module

Arquivo de variáveis aceitas pelo módulo sfn do projeto
Terraform.
-------------------------------------------------------- */

variable "iam_roles_arns_map" {
  description = "Dicionário (map) contendo informações sobre todas as ARNs de roles criadas no módulo IAM para serem vinculadas às funções Lambda criadas neste módulo"
  type        = map(string)
}

variable "cron_expression_to_start_sfn_workflow" {
  description = "Expressão cron responsável por engatilhar o workflow da máquina de estado responsável por aplicar o processo de deduplicação de dados nas camadas SoT e Spec"
  type        = string
}

variable "module_default_tags" {
  description = "Conjunto de tags padrão a serem associadas aos recursos do módulo"
  type        = map(string)
}
