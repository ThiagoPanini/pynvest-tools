/* --------------------------------------------------------
ARQUIVO: policy.tf

Arquivo Terraform responsável por definir todas as policies
IAM utilizadas para criação de roles de aplicação.
-------------------------------------------------------- */

/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para armazenamento de logs no
    CloudWatch
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-store-cloudwatch-logs" {
  template = file("${path.module}/policy-templates/pynvest-store-cloudwatch-logs.json")

  vars = {
    region_name = var.region_name
    account_id  = var.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-store-cloudwatch-logs" {
  name   = "pynvest-store-cloudwatch-logs"
  policy = data.template_file.pynvest-store-cloudwatch-logs.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para invocação de funções Lambda
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-invoke-lambda-functions" {
  template = file("${path.module}/policy-templates/pynvest-invoke-lambda-functions.json")

  vars = {
    region_name = var.region_name
    account_id  = var.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-invoke-lambda-functions" {
  name   = "pynvest-invoke-lambda-functions"
  policy = data.template_file.pynvest-invoke-lambda-functions.rendered
}


/* ------------------------------------------------------- 
    IAM POLICY
    Definindo policy para deleção de partições
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-check-and-delete-partitions" {
  template = file("${path.module}/policy-templates/pynvest-check-and-delete-partitions.json")

  vars = {
    region_name        = var.region_name
    account_id         = var.account_id
    sor_database_name  = var.databases_names_map["sor"]
    sot_database_name  = var.databases_names_map["sot"]
    spec_database_name = var.databases_names_map["spec"]
    sor_bucket_name    = var.bucket_names_map["sor"]
    sot_bucket_name    = var.bucket_names_map["sot"]
    spec_bucket_name   = var.bucket_names_map["spec"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-check-and-delete-partitions" {
  name   = "pynvest-check-and-delete-partitions"
  policy = data.template_file.pynvest-check-and-delete-partitions.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para envio de mensagens para filas no
    SQS
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-send-msgs-to-tickers-queues" {
  template = file("${path.module}/policy-templates/pynvest-send-msgs-to-tickers-queues.json")

  vars = {
    region_name = var.region_name
    account_id  = var.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-send-msgs-to-tickers-queues" {
  name   = "pynvest-send-msgs-to-tickers-queues"
  policy = data.template_file.pynvest-send-msgs-to-tickers-queues.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para coleta, armazenamento e
    catalogação de dados brutos na camada SoR
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-share-sor-financial-data" {
  template = file("${path.module}/policy-templates/pynvest-share-sor-financial-data.json")

  vars = {
    region_name       = var.region_name
    account_id        = var.account_id
    sor_bucket_name   = var.bucket_names_map["sor"]
    sor_database_name = var.databases_names_map["sor"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-share-sor-financial-data" {
  name   = "pynvest-share-sor-financial-data"
  policy = data.template_file.pynvest-share-sor-financial-data.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para coleta, armazenamento e
    catalogação de dados preparados na camada SoT
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-share-sot-financial-data" {
  template = file("${path.module}/policy-templates/pynvest-share-sot-financial-data.json")

  vars = {
    region_name       = var.region_name
    account_id        = var.account_id
    sor_bucket_name   = var.bucket_names_map["sor"]
    sot_bucket_name   = var.bucket_names_map["sot"]
    sot_database_name = var.databases_names_map["sot"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-share-sot-financial-data" {
  name   = "pynvest-share-sot-financial-data"
  policy = data.template_file.pynvest-share-sot-financial-data.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para coleta, armazenamento e
    catalogação de dados especializados na camada Spec
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-share-spec-financial-data" {
  template = file("${path.module}/policy-templates/pynvest-share-spec-financial-data.json")

  vars = {
    region_name        = var.region_name
    account_id         = var.account_id
    sot_bucket_name    = var.bucket_names_map["sot"]
    spec_bucket_name   = var.bucket_names_map["spec"]
    spec_database_name = var.databases_names_map["spec"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-share-spec-financial-data" {
  name   = "pynvest-share-spec-financial-data"
  policy = data.template_file.pynvest-share-spec-financial-data.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para leitura e escrita de dados nas
    camadas SoT e Spec como parte de processo de deduplicação
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-dedup-financial-data" {
  template = file("${path.module}/policy-templates/pynvest-dedup-financial-data.json")

  vars = {
    region_name        = var.region_name
    account_id         = var.account_id
    sot_bucket_name    = var.bucket_names_map["sot"]
    sot_database_name  = var.databases_names_map["sot"]
    spec_bucket_name   = var.bucket_names_map["spec"]
    spec_database_name = var.databases_names_map["spec"]
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-dedup-financial-data" {
  name   = "pynvest-dedup-financial-data"
  policy = data.template_file.pynvest-dedup-financial-data.rendered
}


/* -------------------------------------------------------
    IAM POLICY
    Definindo policy para invocação de state machines
------------------------------------------------------- */

# Definindo template file para policy
data "template_file" "pynvest-invoke-state-machines" {
  template = file("${path.module}/policy-templates/pynvest-invoke-state-machines.json")

  vars = {
    region_name = var.region_name
    account_id  = var.account_id
  }
}

# Definindo policy
resource "aws_iam_policy" "pynvest-invoke-state-machines" {
  name   = "pynvest-invoke-state-machines"
  policy = data.template_file.pynvest-invoke-state-machines.rendered
}
