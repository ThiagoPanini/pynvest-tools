# Pynvest Tools

Você já imaginou ter todo um conjunto de serviços AWS implantados em seu ambiente para obter, atualizar e analisar recorrentemente **indicadores financeiros** de ativos da B3?

Conheça o [pynvest-tools](https://github.com/ThiagoPanini/pynvest-tools), o seu módulo [Terraform](https://www.terraform.io/) para obter tudo isso com pouquíssimas linhas de código.

## O que é o pynvest-tools?

Como já mencionado, o *pynvest-tools* é um módulo Terraform capaz de fornecer uma experiência única de implantação de toda uma arquitetura AWS provisionada para garantir a obtenção e uma recorrente atualização de indicadores financeiros utilizando a biblioteca [pynvest](https://pynvest.readthedocs.io/pt/latest/).

Quais os benefícios ao utilizar o módulo pynvest-tools?

- ✅ Processo agendado para obtenção de dados de indicadores financeiros de ativos
- ✅ Arquitetura *serverless*, resiliente e de baixo custo
- ✅ Tabelas atualizadas diariamente no Glue Data Catalog
- ✅ Possibilidade de realizar as mais variadas análises financeiras via queries do Athena
- ✅ Possibilidade de criar *dashboards* no Quicksight utilizando dados financeiros

## Arquitetura

Toda a solução foi desenhada dentro dos propósitos de uma arquitetura [serverless](https://aws.amazon.com/serverless/) utilizando serviços nativos da AWS que interagem entre si de forma [altamente desacoplada](https://aws.amazon.com/blogs/compute/decoupling-larger-applications-with-amazon-eventbridge/) e através de eventos.

![[](https://github.com/ThiagoPanini/pynvest-tools/blob/v0.0.1/docs/drawio/pynvest-tool-diagram.png?raw=true)](https://github.com/ThiagoPanini/pynvest-tools/blob/v0.0.1/docs/drawio/pynvest-tool-diagram.png?raw=true)

## Quickstart

O usuário poderá obter todos os insumos já detalhados através de uma [chamada de módulo Terraform](https://developer.hashicorp.com/terraform/language/modules/syntax) no seguinte formato:

```python
# Chamada de módulo pynvest-tools em arquivo main.tf
module "pynvest-tools" {
  source = "git::https://github.com/ThiagoPanini/pynvest-tools?ref=main"

  bucket_names_map = {
    "sor" = "some-bucket-name-to-store-sor-data"
  }
}
```

## Saiba Mais

> **Note**
> Uma página completa de documentação da `pynvest-tools` está disponível no [readthedocs](https://pynvest.readthedocs.io/pt/latest/tools/pynvest-tools/) com detalhes mais aprofundados sobre essa solução.