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
      "sor_acoes" = "tbsor_fundamentus_ind_financeiros_acoes",
      "sor_fiis"  = "tbsor_fundamentus_ind_financeiros_fiis"
    }
  }
}
