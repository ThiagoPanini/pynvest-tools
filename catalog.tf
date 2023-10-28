/* --------------------------------------------------------
ARQUIVO: catalog.tf

Arquivo Terraform responsável por definir recursos
relacionados ao Glue Data Catalog para fins de catalogação
de databases e tabelas geradas a partir deste projeto.
-------------------------------------------------------- */

resource "aws_glue_catalog_database" "fundamentus" {
  count = var.flag_create_database ? 1 : 0
  name  = var.database_name
}
