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

    # Coletando variáveis de ambiente para escrita dos dados
    target_database = os.getenv("TARGET_DATABASE")
    target_table = os.getenv("TARGET_TABLE")
    target_bucket = os.getenv("TARGET_BUCKET")
    partition_name = os.getenv("PARTITION_NAME")
    subset_col_to_dedup = os.getenv("SUBSET_COL_TO_DEDUP")

    # Criando coluna de partição
    now = datetime.now(timezone(timedelta(hours=-3)))
    partition_value = now.strftime("%Y%m%d")

    # Definindo variáveis de saída do S3
    partition_suffix = f"{partition_name}={partition_value}/"
    input_s3_path = f"s3://{target_bucket}/{target_table}/{partition_suffix}"
    output_s3_path = f"s3://{target_bucket}/{target_table}"

    # Lendo arquivo parquet como DataFrame do pandas
    df = wr.s3.read_parquet(
        path=input_s3_path
    )

    # Removendo dados duplicados
    df_dedup = df.drop_duplicates(subset=[subset_col_to_dedup])

    # Adicionando coluna de partição no DataFrame deduplicado
    df_dedup["anomesdia_exec"] = int(partition_value)

    # Comunicando resultado
    logger.info("Remoção de dados duplicados realizada com sucesso nos "
                f"arquivos presentes em s3://{target_bucket}/{target_table}. "
                f"Quantidade original de registros: {len(df)}. "
                f"Quantidade atualizada de registros: {len(df_dedup)}")

    # Escrevendo dados no s3 e catalogando no Glue Data Catalog
    wr.s3.to_parquet(
        df=df_dedup,
        path=output_s3_path,
        dataset=True,
        database=target_database,
        table=target_table,
        partition_cols=partition_cols,
        mode="overwrite",
        schema_evolution=True,
        compression=None
    )

    logger.info("Dados escritos com sucesso na tabela "
                f"{target_database}.{target_table} e armazenados fisicamente "
                f"no S3 em {output_s3_path}")

    return {
        "status_code": 200,
        "body": {
            "total_rows_pre_dedup": len(df),
            "total_rows_pos_dedup": len(df_dedup),
            "output_table": f"{target_database}.{target_table}",
            "output_s3_uri": output_s3_path
        }
    }
