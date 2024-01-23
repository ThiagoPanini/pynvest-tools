/* --------------------------------------------------------
ARQUIVO: outputs.tf

Arquivo Terraform responsável por consolidar todas as saídas
expostas pelo módulo IAM. Tais saídas são, em geral,
representadas por informações (atributos) de recursos criados
dentro do módulo e que podem ser úteis para serem utilizados
e acessados em outros módulos do projeto (ex: ARN de roles)
-------------------------------------------------------- */

output "iam_roles_arns_map" {
  value = {
    "pynvest-lambda-check-and-delete-partitions" = aws_iam_role.pynvest-lambda-check-and-delete-partitions.arn
  }
}
