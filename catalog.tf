/* --------------------------------------------------------
ARQUIVO: catalog.tf

Arquivo Terraform responsável por definir recursos
relacionados ao Glue Data Catalog para fins de catalogação
de databases e tabelas geradas a partir deste projeto.
-------------------------------------------------------- */

/*
resource "aws_glue_catalog_database" "db_fundamentus_sor" {
  count = var.flag_create_databases ? 1 : 0
  name  = var.sor_database_name
}
*/

resource "aws_glue_catalog_database" "databases_fundamentus" {
  for_each    = var.flag_create_databases ? var.databases_names_map : {}
  name        = each.value
  description = "Armazenamento de dados ${upper(each.key)} do projeto pynvest"
}
