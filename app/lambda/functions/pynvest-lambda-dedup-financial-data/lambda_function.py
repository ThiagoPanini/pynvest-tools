# Importando bibliotecas
import os
from datetime import datetime, timezone, timedelta

import awswrangler as wr

from pynvest.utils.log import log_config
import logging

from warnings import filterwarnings
filterwarnings("ignore")


# Configurando objeto logger
logger = log_config(logger_name=__file__, logger_level=logging.INFO)
logger.propagate = False


# Definindo função handler
def lambda_handler(
    event,
    context,
    partition_cols: list = ["anomesdia_exec"]
):
    """
    Preparação de indicadores de financeiros de Ações e FIIs listados na B3.

    Args:
        event (dict): Evento de entrada da chamada da função (Put do S3)
        context (LambdaContext): Metadados da própria função
        partition_cols (list): Referência de colunas de partição da tabela

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Definindo template de query para consulta
    query_template = """
        SELECT DISTINCT
            *

        FROM <target_table>

        WHERE anomesdia_exec = <partition_filter>
    """

    # Coletando variáveis de ambiente para escrita dos dados
    target_database = os.getenv("TARGET_DATABASE")
    target_table = os.getenv("TARGET_TABLE")
    target_bucket = os.getenv("TARGET_BUCKET")

    # Definindo variáveis de saída do S3
    output_s3_path = f"s3://{target_bucket}/{target_table}"

    # Criando coluna de partição
    now = datetime.now(timezone(timedelta(hours=-3)))
    partition_filter = now.strftime("%Y%m%d")

    # Substituindo informações no template de query
    query = query_template.replace("<target_table>", target_table)\
        .replace("<partition_filter>", partition_filter)

    # Realizando a leitura de tabela via Athena
    df_dedup = wr.athena.read_sql_query(
        sql=query,
        database=target_database
    )

    # Comunicando resultado
    logger.info("Consulta de remoção de dados duplicados realizada com "
                f"sucesso na tabela {target_database}.{target_table}. Foram "
                f"retornados {len(df_dedup)} registros a serem sobrescritos "
                "na tabela alvo")

    # Escrevendo dados no s3 e catalogando no Glue Data Catalog
    wr.s3.to_parquet(
        df=df_dedup,
        path=output_s3_path,
        dataset=True,
        database=target_database,
        table=target_table,
        partition_cols=partition_cols,
        mode="overwrite",
        schema_evolution=True
    )

    logger.info("Dados escritos com sucesso na tabela "
                f"{target_database}.{target_table} e armazenados fisicamente "
                f"no S3 em {output_s3_path}")

    return {
        "status_code": 200,
        "body": {
            "total_rows": len(df_dedup),
            "output_table": f"{target_database}.{target_table}",
            "output_s3_uri": output_s3_path
        }
    }
