/* --------------------------------------------------------
ARQUIVO: variables.tf @ iam module

Arquivo de variáveis aceitas pelo módulo iam do projeto
Terraform.
-------------------------------------------------------- */

variable "account_id" {
  description = "ID da conta alvo da implantação usada para substituição de template JSON como forma de restringir permissões à ARNs específicas"
  type        = string
}

variable "region_name" {
  description = "Nome da região alvo da implantação usada para substituição de template JSON como forma de restringir permissões à ARNs específicas"
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

variable "bucket_names_map" {
  description = "Dicionário (map) contendo nomes dos buckets SoR, SoT e Spec da conta AWS alvo de implantação dos recursos. O objetivo desta variável e permitir que o usuário forneça seus próprios buckets para armazenamento dos arquivos gerados. O correto preenchimento desta variável exige que as referências de nomes sejam fornecidas dentro das chaves 'sor', 'sot' e 'spec'. O usuário também pode fornecer o mesmo nome de bucket para as três quebras, caso queira armazenar os dados das tabelas em um único bucket."
  type        = map(string)
}

variable "module_default_tags" {
  description = "Conjunto de tags padrão a serem associadas aos recursos do módulo"
  type        = map(string)
}
