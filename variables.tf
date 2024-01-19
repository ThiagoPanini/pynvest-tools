/* --------------------------------------------------------
ARQUIVO: variables.tf @ root module

Arquivo de variáveis do módulo root do projeto Terraform
contendo todas as declarações de variáveis de todos os
submódulos do projeto
-------------------------------------------------------- */

/* -------------------------------------------------------
    VARIABLES: catalog
    Variáveis aceitas pelo módulo catalog
------------------------------------------------------- */

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

  validation {
    condition     = join(", ", tolist(keys(var.databases_names_map))) == "sor, sot, spec"
    error_message = "Variável databases_names_map precisa ser fornecida como um dicionário (map) contendo exatamente as chaves 'sor', 'sot' e 'spec'. O dicionário fornecido não contém exatamente as chaves mencionadas e, portanto, é considerado inválido."
  }
}

variable "tables_names_map" {
  description = "Dicionário (map) contendo os nomes de todas as tabelas a serem criadas no Glue Data Catalog para armazenamento de dados de indicadores financeiros em todas as camadas SoR, SoT e Spec"
  type        = map(map(string))
  default = {
    "fundamentus" = {
      "sor_acoes" = "tbsor_fundamentus_indicadores_brutos_acoes",
      "sor_fiis"  = "tbsor_fundamentus_indicadores_brutos_fiis"
    }
  }
}
