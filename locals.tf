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

  # Definindo map com nomes de buckets utilizados no projeto
  bucket_names_map = {
    "sor" : "datadelivery-sor-data-${local.account_id}-${local.region_name}"
    "sot" : "datadelivery-sot-data-${local.account_id}-${local.region_name}"
    "spec" : "datadelivery-spec-data-${local.account_id}-${local.region_name}"
  }
}
