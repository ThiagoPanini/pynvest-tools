/* --------------------------------------------------------
ARQUIVO: main.tf @ sfn module

Arquivo principal do módulo sfn do projeto Terraform onde
recursos de infraestrutura relacionados à workflows do
Step Functions são criados
-------------------------------------------------------- */

# Definindo máquina de estado
resource "aws_sfn_state_machine" "pynvest-sfn-dedup-sot-spec-tables" {
  name     = "pynvest-sfn-dedup-sot-spec-tables"
  type     = "STANDARD"
  role_arn = var.iam_roles_arns_map["pynvest-sfn-invoke-lambda-functions"]

  definition = file("${path.module}/workflows/pynvest-sfn-dedup-sot-spec.json")
}
