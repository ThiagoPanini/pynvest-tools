/* --------------------------------------------------------
ARQUIVO: locals.tf

Arquivo responsável por declarar variáveis/valores locais
capazes de auxiliar na obtenção de informações dinâmicas
utilizadas durante a implantação do projeto, como por
exemplo, o ID da conta alvo de implantação ou o nome da
região.
-------------------------------------------------------- */

locals {
  # Extraindo ID da conta e nome da região
  account_id  = data.aws_caller_identity.current.account_id
  region_name = data.aws_region.current.name

  # Definindo mapeamento contendo nomes de tabelas a serem criadas pelo módulo
  tables_names_map = {
    "fundamentus" = {
      "sor_acoes"   = "tbsor_fundamentus_indicadores_acoes_raw",
      "sor_fiis"    = "tbsor_fundamentus_indicadores_fiis_raw",
      "sot_acoes"   = "tbsot_fundamentus_indicadores_acoes_prep",
      "sot_fiis"    = "tbsot_fundamentus_indicadores_fiis_prep",
      "spec_ativos" = "tbspec_fundamentus_cotacao_ativos"
    }
  }

  # Mapeamento de informações relacionas à tabelas e bancos de dados
  tables_info_map = {
    for element in distinct(
      flatten(
        [
          for scrapper in keys(local.tables_names_map) : [
            for table_layer in keys(local.tables_names_map[scrapper]) : {
              scrapper        = scrapper
              database        = var.databases_names_map[split("_", table_layer)[0]]
              table           = local.tables_names_map[scrapper][table_layer]
              layer           = upper(split("_", table_layer)[0])
              bucket_location = "s3://${var.bucket_names_map[split("_", table_layer)[0]]}/${local.tables_names_map[scrapper][table_layer]}"
            }
          ]
        ]
      )
    ) : "${element.scrapper}.${element.table}" => element
  }

  # Definindo expressão cron de agendamento de processos: Lambda
  cron_expression_to_initialize_process = "cron(30 21 ? * MON-FRI *)"

  # Definindo expressão cron de agendamento de processos: Step Functions
  cron_expression_to_start_sfn_workflow = "cron(0 22 ? * MON-FRI *)"
}
