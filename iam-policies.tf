/* --------------------------------------------------------
ARQUIVO: iam-policies.tf

Arquivo Terraform responsável por definir todas as policies
IAM utilizadas para criação de roles de aplicação.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM Policy
    pynvest-cloudwatch-logs
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-cloudwatch-logs" {
  template = file("${path.module}/iam/policies/pynvest-cloudwatch-logs.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-cloudwatch-logs" {
  name   = "pynvest-cloudwatch-logs"
  policy = data.template_file.pynvest-cloudwatch-logs.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-sqs-send-msgs-to-tickers-queues
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-sqs-send-msgs-to-tickers-queues" {
  template = file("${path.module}/iam/policies/pynvest-sqs-send-msgs-to-tickers-queues.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-sqs-send-msgs-to-tickers-queues" {
  name   = "pynvest-sqs-send-msgs-to-tickers-queues"
  policy = data.template_file.pynvest-sqs-send-msgs-to-tickers-queues.rendered
}


/* -------------------------------------------------------
    IAM Policy
    pynvest-sqs-poll-msgs-from-queue
------------------------------------------------------- */
/*
# Definindo template file para policy
data "template_file" "pynvest-sqs-poll-msgs-from-queue" {
  template = file("${path.module}/iam/policies/pynvest-sqs-poll-msgs-from-queue.json")

  vars = {
    region_name = local.region_name
    account_id  = local.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-sqs-poll-msgs-from-queue" {
  name   = "pynvest-sqs-poll-msgs-from-queue"
  policy = data.template_file.pynvest-sqs-poll-msgs-from-queue.rendered
}
*/

/* -------------------------------------------------------
    IAM Policy
    pynvest-s3-put-sor-data
------------------------------------------------------- */
/*
# Definindo template file para policy
data "template_file" "pynvest-s3-put-sor-data" {
  template = file("${path.module}/iam/policies/pynvest-s3-put-sor-data.json")

  vars = {
    sor_bucket_name = local.s3_bucket_names_map["sor"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-s3-put-sor-data" {
  name   = "pynvest-s3-put-sor-data"
  policy = data.template_file.pynvest-s3-put-sor-data.rendered
}
*/
