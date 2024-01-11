/* --------------------------------------------------------
ARQUIVO: databases.tf @ catalog module

Arquivo Terraform responsável pela criação de todos os
databases no Glue Catalog para armazenamento de tabelas
nas camadas SoR, SoT e Spec capazes de armazenar todos os
dados de indicadores financeiros gerados no projeto
-------------------------------------------------------- */

# Criando databases SoR, SoT e Spec
resource "aws_glue_catalog_database" "databases_fundamentus" {
  for_each    = var.flag_create_databases ? var.databases_names_map : {}
  name        = each.value
  description = "Armazenamento de dados ${upper(each.key)} do projeto pynvest"
}
