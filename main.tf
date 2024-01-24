/* --------------------------------------------------------
ARQUIVO: main.tf @ root module

Arquivo principal do projeto Terraform cuja responsabilidade
é, essencialmente, chamar todos os submódulos do projeto
com as respectivas configurações obtidas através de chamadas
realizadas pelos usuários.

ToDos:
- [x] Criar de tabelas SoR no Glue Data Catalog
- [x] Criar filas SQS para armazenamento de mensagens contendo tickers de Ações e FIIs
- [x] Revisitar estratégia de policies e roles IAM visando propor uma consolidação dos JSONs e a utilização do resource template_dir (1 policy por Lambda exceto policy de logs?)
- [x] Criar role IAM para Lambda de extração de tickers de Ações e FIIs
- [x] Subir primeira Lambda de extração de tickers de Ações e FIIs
      Obs: renomear pynvest-lambda-send-tickers-to-sqs-queues para pynvest-lambda-get-tickers
- [x] Subir segunda Lambda para envio de tickers para filas no SQS
- [x] Configurar triggers e permissões de invocação
- [ ] Subir terceira e quarta Lambda para processar indicadores de Ações e FIIs, respectivamente
- [ ] Ajustar código para alterar tipagem dos campos (testar escrita sem alterações e contando com metadados)
- [ ] Ajustar código para considerar nova coluna de partição com novo formato (anomesdia_scrapper_exec=%Y%m%d)
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
  sqs_visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  sqs_message_retention_seconds  = var.sqs_message_retention_seconds
  sqs_max_message_size           = var.sqs_max_message_size
  sqs_delay_seconds              = var.sqs_delay_seconds
  sqs_receive_wait_time_seconds  = var.sqs_receive_wait_time_seconds
}

# Chamando módulo iam
module "iam" {
  source = "./infra/modules/iam"

  # Configurando variáveis para substituição de templates JSON
  account_id          = local.account_id
  region_name         = local.region_name
  databases_names_map = var.databases_names_map
  tables_names_map    = var.tables_names_map
  bucket_names_map    = var.bucket_names_map
}

# Chamando módulo lambda
module "lambda" {
  source = "./infra/modules/lambda"

  # Nome da região para composição de ARN de layer AWS SDK for Pandas
  region_name = local.region_name

  # Dicionários de databases, tabelas, buckets no S3, ARNs de roles IAM e ARNs de filas SQS para uso nas funções
  databases_names_map = var.databases_names_map
  tables_names_map    = var.tables_names_map
  bucket_names_map    = var.bucket_names_map
  iam_roles_arns_map  = module.iam.iam_roles_arns_map
  sqs_queues_arn_map  = module.sqs.sqs_queues_arn_map

  # Características das funções (versão do Python e timeout)
  functions_python_runtime = var.functions_python_runtime
  functions_timeout        = var.functions_timeout

  # Expressão cron para agendamento do processo
  cron_expression_to_initialize_process = var.cron_expression_to_initialize_process

  # Configuração de triggers SQS para Lambdas de processamento de SoRs
  sqs_lambda_trigger_batch_size      = var.sqs_lambda_trigger_batch_size
  sqs_lambda_trigger_batch_window    = var.sqs_lambda_trigger_batch_window
  sqs_lambda_trigger_max_concurrency = var.sqs_lambda_trigger_max_concurrency

  # Explicitando dependências
  depends_on = [
    module.iam,
    module.sqs,
    module.catalog
  ]
}
