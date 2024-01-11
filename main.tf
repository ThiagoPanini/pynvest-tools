/* --------------------------------------------------------
ARQUIVO: main.tf @ root module

Arquivo principal do projeto Terraform cuja responsabilidade
é, essencialmente, chamar todos os submódulos do projeto
com as respectivas configurações obtidas através de chamadas
realizadas pelos usuários.
-------------------------------------------------------- */

# Chamando módulo catalog
module "catalog" {
  source = "./infra/modules/catalog"

  # Definindo databases da solução
  flag_create_databases = var.flag_create_databases
  databases_names_map   = var.databases_names_map

  # Definindo detalhes das tabelas a serem criadas
  tables_names_map = var.tables_names_map
}

output "json_file" {
  value = jsondecode(
    file("${path.module}/infra/modules/catalog/table-schemas/tbsor_fundamentus_indicadores_brutos_acoes.json")
  )["columns"]
}
