# Importando bibliotecas
import os
from datetime import datetime, timezone, timedelta

import awswrangler as wr

import logging
from pynvest.utils.log import log_config

from warnings import filterwarnings
filterwarnings("ignore")


# Configurando objeto logger
logger = log_config(logger_name=__file__, logger_level=logging.INFO)
logger.propagate = False


# Definindo função handler
def lambda_handler(
    event,
    context,
    partition_col_name: str = "anomesdia_exec",
    partition_date_format: str = "%Y%m%d",
    timezone_hours: int = -3
):
    """
    Análise e eliminação de partições físicas e lógicas de tabelas no catálogo.

    Esta é uma função Lambda capaz de ser utilizada no início de processos
    encadeados de processamento de dados para verificar e eliminar, quando
    existente, partições físicas e lógicas de tabelas existentes no Glue
    Data Catalog. Para isso, esta função é parametrizada com argumentos
    que fazem referência às tabelas alvo do processo de verificação e
    informações sobre as partições de data a serem eventualmente eliminadas.

    A aplicabilidade desta função se dá em cenários onde dados são gerados
    periodicamente e escritos no ambiente distribuído (S3) no formato append.
    Em casos deste tipo, essa função é capaz de garantir que não haja dados
    duplicados na tabela alvo.

    Args:
        event (dict):
            Evento de entrada da chamada da função

        context (LambdaContext):
            Metadados da própria função

        partition_col_name (str):
            Referência do nome de partição de data alvo da checagem

        partition_date_format (str):
            Formato de data a ser utilizado como forma configurar o resultado
            do método datetime.now()

        timezone_hours (int):
            Informação de timezone usada dentro do cálculo do método
            datetime.now()

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Coletando variáveis de ambiente para escrita dos dados
    database_name = os.getenv("DATABASE_NAME")
    tables = os.getenv("TABLE_NAMES").split(",")

    # Montando partição de data de execução
    now = datetime.now(timezone(timedelta(hours=timezone_hours)))
    partition_value = now.strftime(partition_date_format)

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
            logger.info(f"Partição {partition_col_name}={partition_value} "
                        f"existente na tabela {table}. Eliminando partição.")

            # Dropando partição
            wr.catalog.delete_partitions(
                database=database_name,
                table=table,
                partitions_values=[[partition_value]]
            )

            # Indexando path de partição física no S3
            partition_path_index = partition_values.index([partition_value])
            # Dropando arquivos físicos da partição no s3
            partition_path = partition_paths[partition_path_index]

            logger.info("Eliminando arquivos físicos da partição no S3 "
                        f"existentes no caminho {partition_path}")

            # Dropando partição física no S3
            wr.s3.delete_objects(partition_path)

            # Adicionando informação à lista de partições dropadas
            dropped_partitions.append({
                "database": database_name,
                "table": table,
                "partition_value": partition_value,
                "s3_partition_path": partition_path,
            })

        # Nenhuma partição existente na referência de data atual
        else:
            logger.info("Nenhuma partição de data com referência "
                        f"{partition_col_name}={partition_value} encontrada "
                        f"na tabela {table}")

    return {
        "status_code": 200,
        "body": {
            "dropped_partitions": dropped_partitions
        }
    }
