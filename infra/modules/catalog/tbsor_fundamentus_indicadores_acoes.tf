/* --------------------------------------------------------
ARQUIVO: tbsor_fundamentus_indicadores_brutos_acoes.tf @ catalog module

Arquivo Terraform responsável pela criação da tabela SoR
tbsor_fundamentus_indicadores_brutos_acoes no Glue Data
Catalog para armazenamento de dados brutos de indicadores
financeiros de ações extraídos utilizando a biblioteca
pynvest aplicada ao site Fundamentus.
-------------------------------------------------------- */

# Criando tabela no Glue Data Catalog
resource "aws_glue_catalog_table" "tbsor_fundamentus_indicadores_brutos_acoes" {
  name          = var.tables_names_map["fundamentus"]["sor_acoes"]
  database_name = var.databases_names_map["sor"]
  description   = "Tabela responsável por armazenar dados de indicadores de ações financeiras extraídos através de um motor de web scrapping apontado para o site Fundamentus"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = "s3://${var.bucket_names_map["sor"]}/${var.tables_names_map["fundamentus"]["sor_acoes"]}"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "stream-${var.tables_names_map["fundamentus"]["sor_acoes"]}"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    dynamic "columns" {
      for_each = jsondecode(file("${path.module}/schemas/${var.tables_names_map["fundamentus"]["sor_acoes"]}.json"))["columns"]
      content {
        name    = columns.value["name"]
        type    = columns.value["type"]
        comment = columns.value["comment"]
      }
    }
  }

  partition_keys {
    name    = "anomesdia_scrapper_exec"
    type    = "int"
    comment = "Referência de data exata (no formato '%Y%m%d' ou 'yyyMMdd') em que os indicadores foram processados"
  }

  # Explicitando dependência
  depends_on = [
    aws_glue_catalog_database.databases_fundamentus
  ]

}
