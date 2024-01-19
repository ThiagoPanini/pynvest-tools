/* --------------------------------------------------------
ARQUIVO: iam-policy.tf

Arquivo Terraform responsável por definir todas as policies
IAM utilizadas para criação de roles de aplicação.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM POLICY TEMPLATE
    Substituindo variáveis em templates JSON
------------------------------------------------------- */

# Chamando recurso para substituição de variáveis em templates JSON
resource "template_dir" "iam-policies" {
  source_dir      = "${path.module}/policy-templates"
  destination_dir = "${path.module}/policy"

  # Substituindo variáveis
  vars = {
    account_id        = var.account_id
    region_name       = var.region_name
    sor_database_name = var.bucket_names_map["sor"]
  }
}


/* -------------------------------------------------------
    IAM POLICIES
    Definindo policies IAM com base em templates renderizados
------------------------------------------------------- */

resource "aws_iam_policy" "all_policies" {
  for_each = toset(fileset("${template_dir.iam-policies.destination_dir}", "**"))
  name     = split(".", each.key)[0]
  path     = "/"
  policy   = file("${template_dir.iam-policies.destination_dir}/${each.key}")

  depends_on = [
    template_dir.iam-policies
  ]
}

# Policy que permite a invocação de funções Lambda
/*
resource "aws_iam_policy" "pynvest-lambda-invoke-functions" {
  name   = "pynvest-lambda-invoke-functions"
  policy = "${template_dir.iam-policies.destination_dir}/pynvest-lambda-invoke-functions.json"

  depends_on = [  ]
}

# Policy que permite o armazenamento de logs no CloudWatch
resource "aws_iam_policy" "pynvest-cloudwatch-logs" {
  name   = "pynvest-cloudwatch-logs"
  policy = "${template_dir.iam-policies.destination_dir}/pynvest-lambda-invoke-functions.json"
}*/

output "files" {
  value = toset(fileset("${template_dir.iam-policies.destination_dir}", "**"))
}
