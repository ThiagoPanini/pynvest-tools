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
    partition_cols: list = ["date_exec"]
):
    """
    Checagem e limpeza de partições já existentes das tabelas SoRs

    Args:
        event (dict): Evento de entrada da chamada da função
        context (LambdaContext): Metadados da própria função
        partition_cols (list): Referência de colunas de partição da tabela

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Coletando variáveis de ambiente para escrita dos dados
    database_name = os.getenv("DATABASE_NAME")
    tables = os.getenv("TABLE_NAMES").split(",")

    # Montando partição de data de execução
    now = datetime.now(timezone(timedelta(hours=-3)))
    partition_value = now.strftime("%d-%m-%Y")

    # Iterando sobre tabelas SoRs mapeadas
    for table in tables:
        # Coletando partições existentes em tabela
        partitions = wr.catalog.get_parquet_partitions(
            database=database_name,
            table=table
        )

        # Obtendo lista de chaves e valores das partições
        partition_paths = list(partitions.keys())
        partition_values = list(partitions.values())

        # Validando existência de partição processada
        dropped_partitions = []
        if [partition_value] in partition_values:
            # Dropando partição da tabela no Glue Data Catalog
            logger.info(f"Partição {partition_cols[0]}={partition_value} "
                        f"existente na tabela {table}. Eliminando partição.")
            wr.catalog.delete_partitions(
                database=database_name,
                table=table,
                partitions_values=[[partition_value]]
            )

            # Dropando arquivos físicos da partição no s3
            partition_path = partition_paths[partition_values.index(
                [partition_value])
            ]
            logger.info("Eliminando arquivos físicos da partição no S3 "
                        f"existentes no caminho {partition_path}")
            wr.s3.delete_objects(partition_path)

            # Adicionando informação à lista de partições dropadas
            dropped_partitions.append({
                "database": database_name,
                "table": table,
                "partition_value": partition_value,
                "s3_partition_path": partition_path,
            })

    return {
        "status_code": 200,
        "body": {
            "dropped_partitions": dropped_partitions
        }
    }
