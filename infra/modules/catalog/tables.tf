/* --------------------------------------------------------
ARQUIVO: tbsor_fundamentus_indicadores_brutos_acoes.tf @ catalog module

Arquivo Terraform responsável pela criação da tabela SoR
tbsor_fundamentus_indicadores_brutos_acoes no Glue Data
Catalog para armazenamento de dados brutos de indicadores
financeiros de ações extraídos utilizando a biblioteca
pynvest aplicada ao site Fundamentus.
-------------------------------------------------------- */

# Criando tabela no Glue Data Catalog
resource "aws_glue_catalog_table" "all_catalog_tables" {
  for_each      = var.tables_info_map
  name          = each.value["table"]
  database_name = each.value["database"]
  description   = "Tabela ${each.value["table"]} criada na camada ${each.value["layer"]} para armazenar dados extraídos do scrapper ${each.value["scrapper"]}"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  storage_descriptor {
    location      = each.value["bucket_location"]
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "stream-${each.value["table"]}"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    dynamic "columns" {
      for_each = jsondecode(file("${path.module}/schemas/${each.value["table"]}.json"))["columns"]
      content {
        name    = columns.value["name"]
        type    = columns.value["type"]
        comment = columns.value["comment"]
      }
    }
  }

  partition_keys {
    name    = "anomesdia_exec"
    type    = "int"
    comment = "Referência de data exata (no formato '%Y%m%d' ou 'yyyMMdd') em que os dados foram processados"
  }

  # Explicitando dependência
  depends_on = [
    aws_glue_catalog_database.databases_fundamentus
  ]
}
