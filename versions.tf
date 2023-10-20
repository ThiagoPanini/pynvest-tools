/* ---------------------------------------------------------
ARQUIVO: versions.tf

Arquivo criado para consolidar definições explícitas de
versões do runtime Terraform e dos providers utilizados
para definição dos recursos do módulo.
--------------------------------------------------------- */

terraform {
  required_version = ">=1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.61"
    }
  }
}
