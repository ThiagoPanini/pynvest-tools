<div align="center">
    <br><img src="https://github.com/ThiagoPanini/pynvest-tools/blob/main/docs/imgs/logo/logo.png?raw=true" width=200 alt="pynvest-logo">
</div>

<div align="center">

  <a href="https://www.terraform.io/">
    <img src="https://img.shields.io/badge/terraform-grey?style=for-the-badge&logo=terraform&logoColor=B252D0">
  </a>

  <a href="https://www.mkdocs.org/">
    <img src="https://img.shields.io/badge/mkdocs-grey?style=for-the-badge&logo=markdown&logoColor=B252D0">
  </a>

  <a href="https://readthedocs.org/">
    <img src="https://img.shields.io/badge/readthedocs-grey?style=for-the-badge&logo=readthedocs&logoColor=B252D0">
  </a>

  <a href="https://github.com/">
    <img src="https://img.shields.io/badge/github-grey?style=for-the-badge&logo=github&logoColor=B252D0">
  </a>

___

<div align="center">
  <br>
</div>

## Visão Geral

O `pynvest-tools` é um módulo Terraform criado para habilitar usuários a implantarem uma série de recursos AWS em seus próprios ambientes pessoais com o intuito de permitir a extração, preparação e armazenamento recorrente de indicadores financeiros de ativos listados na B3.

O módulo fornece uma experiência única de *deploy* de toda uma arquitetura AWS provisionada para ser executada de modo totalmente *serverless*. Ao toque de apenas um comando, os usuários poderão iniciar a construção de um "mini data lake" de dados financeiros!

## Vantagens do Módulo

- ✅ Processo agendado para obtenção de dados de indicadores financeiros de ativos
- ✅ Arquitetura *serverless*, resiliente e de baixo custo
- ✅ Tabelas atualizadas diariamente no Glue Data Catalog
- ✅ Possibilidade de realizar as mais variadas análises financeiras via queries do Athena
- ✅ Possibilidade de criar *dashboards* no Quicksight utilizando dados financeiros

## Arquitetura

Toda a solução foi desenhada dentro dos propósitos de uma arquitetura [serverless](https://aws.amazon.com/serverless/) utilizando serviços nativos da AWS que interagem entre si de forma [altamente desacoplada](https://aws.amazon.com/blogs/compute/decoupling-larger-applications-with-amazon-eventbridge/) e através de eventos.

![[Arquitetura de solução do módulo](https://github.com/ThiagoPanini/pynvest-tools/blob/main/docs/drawio/pynvest-tool-diagram-print.png?raw=true)](https://github.com/ThiagoPanini/pynvest-tools/blob/main/docs/drawio/pynvest-tool-diagram-print.png?raw=true)

Você encontrará detalhes sobre cada uma das etapas no [link da documentação](https://pynvest.readthedocs.io/pt/latest/tools/tools/) fornecido acima.

## Quickstart

O usuário poderá obter todos os insumos já detalhados através de uma [chamada de módulo Terraform](https://developer.hashicorp.com/terraform/language/modules/syntax) no seguinte formato:

```python
# Chamada de módulo pynvest-tools em arquivo main.tf
module "pynvest-tools" {
  source = "git::https://github.com/ThiagoPanini/pynvest-tools?ref=main"

  # Fornecendo nomes de buckets para armazenamento dos dados a serem gerados
  bucket_names_map = {
    "sor"  = "some-bucket-name-to-store-sor-data",
    "sot"  = "some-bucket-name-to-store-sot-data",
    "spec" = "some-bucket-name-to-store-spec-data"
  }
}
```

## Saiba Mais

> **Note**
> Uma página completa de documentação da `pynvest-tools` está disponível no [readthedocs](https://pynvest.readthedocs.io/pt/latest/tools/tools/) com detalhes mais aprofundados sobre essa solução.