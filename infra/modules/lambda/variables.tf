/* --------------------------------------------------------
ARQUIVO: variables.tf @ lambda module

Arquivo de variáveis aceitas pelo módulo lambda do projeto
Terraform.
-------------------------------------------------------- */

variable "lambda_python_runtime" {
  description = "Definição do runtime (versão) da linguagem Python associada às funções"
  type        = string
}

variable "lambda_timeout" {
  description = "Timeout das funções Lambda"
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

variable "iam_roles_arns_map" {
  description = "Dicionário (map) contendo informações sobre todas as ARNs de roles criadas no módulo IAM para serem vinculadas às funções Lambda criadas neste módulo"
  type        = map(string)
}
