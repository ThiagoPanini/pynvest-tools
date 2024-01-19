/* --------------------------------------------------------
ARQUIVO: main.tf @ root module

Arquivo principal do projeto Terraform cuja responsabilidade
é, essencialmente, chamar todos os submódulos do projeto
com as respectivas configurações obtidas através de chamadas
realizadas pelos usuários.

ToDos:
- [x] Criar de tabelas SoR no Glue Data Catalog
- [x] Criar filas SQS para armazenamento de mensagens contendo tickers de Ações e FIIs
- [ ] Revisitar estratégia de policies e roles IAM visando propor uma consolidação dos JSONs e a utilização do resource template_dir (1 policy por Lambda exceto policy de logs?)
- [ ] Criar role IAM para Lambda de extração de tickers de Ações e FIIs
- [ ] Subir primeira Lambda de extração de tickers de Ações e FIIs
      Obs: renomear pynvest-lambda-send-tickers-to-sqs-queues para pynvest-lambda-get-tickers
-------------------------------------------------------- */

# Chamando módulo catalog
module "catalog" {
  source = "./infra/modules/catalog"

  # Configurando databases, tabelas e localização no S3
  flag_create_databases = var.flag_create_databases
  databases_names_map   = var.databases_names_map
  tables_names_map      = var.tables_names_map
  bucket_names_map      = var.bucket_names_map
}

# Chamando módulo sqs
module "sqs" {
  source = "./infra/modules/sqs"

  # Configurando características das filas
  sqs_tickers_acoes_queue_name       = var.sqs_tickers_acoes_queue_name
  sqs_tickers_fiis_queue_name        = var.sqs_tickers_fiis_queue_name
  sqs_visibility_timeout_seconds     = var.sqs_visibility_timeout_seconds
  sqs_message_retention_seconds      = var.sqs_message_retention_seconds
  sqs_max_message_size               = var.sqs_max_message_size
  sqs_delay_seconds                  = var.sqs_delay_seconds
  sqs_receive_wait_time_seconds      = var.sqs_receive_wait_time_seconds
  sqs_lambda_trigger_batch_size      = var.sqs_lambda_trigger_batch_size
  sqs_lambda_trigger_batch_window    = var.sqs_lambda_trigger_batch_window
  sqs_lambda_trigger_max_concurrency = var.sqs_lambda_trigger_max_concurrency
}

# Chamando módulo iam
module "iam" {
  source = "./infra/modules/iam"

  # Configurando variáveis para substituição de templates JSON
  account_id       = local.account_id
  region_name      = local.region_name
  bucket_names_map = var.bucket_names_map
}


output "iam_files" {
  value = module.iam.files
}
