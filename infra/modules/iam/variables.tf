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

variable "bucket_names_map" {
  description = "Dicionário (map) contendo nomes dos buckets SoR, SoT e Spec da conta AWS alvo de implantação dos recursos. O objetivo desta variável e permitir que o usuário forneça seus próprios buckets para armazenamento dos arquivos gerados. O correto preenchimento desta variável exige que as referências de nomes sejam fornecidas dentro das chaves 'sor', 'sot' e 'spec'. O usuário também pode fornecer o mesmo nome de bucket para as três quebras, caso queira armazenar os dados das tabelas em um único bucket."
  type        = map(string)
}
