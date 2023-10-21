/* --------------------------------------------------------
ARQUIVO: iam.tf

Arquivo Terraform responsável por definir todos os recursos
relacionados à policies e roles IAM.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM Policy
    pynvest-s3-ops-policy
------------------------------------------------------- */

# Definindo template file para policy s3-put-object-policy
data "template_file" "pynvest-s3-ops-policy" {
  template = file("${path.module}/iam/policies/pynvest-s3-ops-policy.json")

  vars = {
    sor_bucket_name = local.s3_bucket_names_map["sor"]
    account_id      = local.account_id
    region_name     = local.region_name
  }
}

# Definindo policy s3-put-object-policy
resource "aws_iam_policy" "pynvest-s3-ops-policy" {
  name   = "pynvest-s3-ops-policy"
  policy = data.template_file.pynvest-s3-ops-policy.rendered
}


/* -------------------------------------------------------
    IAM Role
    pynvest-lambda-get-raw-data-role
------------------------------------------------------- */

# Definindo role IAM para coleta e armazenamento de dados brutos
resource "aws_iam_role" "pynvest-lambda-get-raw-data-role" {
  name               = "pynvest-lambda-get-raw-data-role"
  assume_role_policy = file("${path.module}/iam/trust/trust-lambda.json")

  managed_policy_arns = [
    "arn:aws:iam::${local.account_id}:policy/pynvest-s3-ops-policy"
  ]

  depends_on = [
    aws_iam_policy.pynvest-s3-ops-policy
  ]
}
