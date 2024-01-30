/* --------------------------------------------------------
ARQUIVO: outputs.tf @ sqs module

Arquivo Terraform responsável por consolidar todas as saídas
expostas pelo módulo SQS. Tais saídas são, em geral,
representadas por informações (atributos) de recursos criados
dentro do módulo e que podem ser úteis para serem utilizados
e acessados em outros módulos do projeto (ex: ARN de filas)
-------------------------------------------------------- */

output "sqs_queues_arn_map" {
  value = {
    "pynvest-tickers-acoes-queue" = aws_sqs_queue.pynvest-tickers-acoes-queue.arn
    "pynvest-tickers-fiis-queue"  = aws_sqs_queue.pynvest-tickers-fiis-queue.arn
  }
}
