# Importando bibliotecas
import boto3
import json

import awswrangler as wr
import pandas as pd

from pynvest.scrappers.fundamentus import Fundamentus
from pynvest.utils.log import log_config
import logging


# Configurando objeto logger
logger = log_config(logger_name=__file__, logger_level=logging.INFO)
logger.propagate = False


# Definindo função handler
def lambda_handler(event, context):
    """
    Extração de indicadores de financeiros de tickers de Ações e FIIs da B3.

    Args:
        event (dict): Evento de entrada da chamada da função (fila SQS).
        context (LambdaContext): Metadados da própria função.

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Coletando variáveis dinâmicas via boto3
    session = boto3.session.Session()
    sts_client = boto3.client("sts")
    account_id = sts_client.get_caller_identity()["Account"]
    region_name = session.region_name

    # Instanciando objeto de scrapper do pynvest
    pynvest_scrapper = Fundamentus(logger_level=logging.INFO)
    pynvest_scrapper.logger.propagate = False

    # Definindo variáveis de saída do S3
    s3_sor_bucket_name = f"datadelivery-sor-data-{account_id}-{region_name}"
    tbl_prefix = "fundamentus"
    tbl_name = "tbl_indicadores_ativos_fundamentus_raw"
    output_path = f"s3://{s3_sor_bucket_name}/{tbl_prefix}/{tbl_name}"

    # Informando total de mensagens recebidas para processamento
    total_msgs = len(event["Records"])
    logger.info("Quantidade de mensagens recebidas para processamento: "
                f"{total_msgs}")

    # Coletando tickers do batch
    tickers = [
        json.loads(record["body"])["ticker"] for record in event["Records"]
    ]
    logger.info("Ativos a terem seus indicadores extraídos: "
                f"{', '.join(tickers)}")

    # Criando DataFrame vazio para appendar extrações
    df_financial_data = pd.DataFrame()

    # Iterando sobre mensagens
    for ticker in tickers:
        # Iniciando extração de indicadores de ativo
        df = pynvest_scrapper.coleta_indicadores_de_ativo(ticker=ticker)

        # Appendando em DataFrame final
        df_financial_data = pd.concat(objs=[df_financial_data, df])
        df_financial_data.reset_index(drop=True, inplace=True)

    # Comunicando
    logger.info("Quantidade de registros na base de indicadores financeiros "
                f"processada: {len(df_financial_data)}")

    # Validando resultado da extração de indicadores
    if len(df_financial_data) == len(tickers):
        # Todos os tickers foram processados, salvando DataFrame no S3
        """
        ToDo:
            - Avaliar erro NoSuchBucket
            - Separar ações e fiis (layouts diferentes)
            - Incluir parâmetros para catalogação dos dados

            - Separar filas para processamento de ações e de FIIs
            - Criar lambda adicional para processamento das filas
        """
        wr.s3.to_parquet(
            df=df_financial_data,
            path=output_path
        )

    return 200
