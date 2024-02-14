/* --------------------------------------------------------
ARQUIVO: outputs.tf @ iam module

Arquivo Terraform responsável por consolidar todas as saídas
expostas pelo módulo IAM. Tais saídas são, em geral,
representadas por informações (atributos) de recursos criados
dentro do módulo e que podem ser úteis para serem utilizados
e acessados em outros módulos do projeto (ex: ARN de roles)
-------------------------------------------------------- */

output "iam_roles_arns_map" {
  value = {
    "pynvest-lambda-check-and-delete-partitions" = aws_iam_role.pynvest-lambda-check-and-delete-partitions.arn,
    "pynvest-lambda-send-msgs-to-tickers-queue"  = aws_iam_role.pynvest-lambda-send-msgs-to-tickers-queue.arn,
    "pynvest-lambda-share-sor-financial-data"    = aws_iam_role.pynvest-lambda-share-sor-financial-data.arn,
    "pynvest-lambda-share-sot-financial-data"    = aws_iam_role.pynvest-lambda-share-sot-financial-data.arn,
    "pynvest-lambda-share-spec-financial-data"   = aws_iam_role.pynvest-lambda-share-spec-financial-data.arn
  }
}
