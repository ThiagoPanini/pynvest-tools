/* --------------------------------------------------------
ARQUIVO: variables.tf @ sfn module

Arquivo de variáveis aceitas pelo módulo sfn do projeto
Terraform.
-------------------------------------------------------- */

variable "iam_roles_arns_map" {
  description = "Dicionário (map) contendo informações sobre todas as ARNs de roles criadas no módulo IAM para serem vinculadas às funções Lambda criadas neste módulo"
  type        = map(string)
}
