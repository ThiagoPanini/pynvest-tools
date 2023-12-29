# Importando bibliotecas
import json
import os

import awswrangler as wr
import pandas as pd

from pynvest.scrappers.fundamentus import Fundamentus
from pynvest.utils.log import log_config
import logging

from warnings import filterwarnings
filterwarnings("ignore")


# Configurando objeto logger
logger = log_config(logger_name=__file__, logger_level=logging.INFO)
logger.propagate = False

# Instanciando objeto de scrapper do pynvest
pynvest_scrapper = Fundamentus(logger_level=logging.INFO)
pynvest_scrapper.logger.propagate = False


# Definindo função handler
def lambda_handler(
    event,
    context,
    pynvest_scrapper: Fundamentus = pynvest_scrapper,
    partition_cols: list = ["date_exec"]
):
    """
    Extração de indicadores de financeiros de Ações e FIIs listados na B3.

    Args:
        event (dict): Evento de entrada da chamada da função (fila SQS)
        context (LambdaContext): Metadados da própria função
        pynvest_scrapper (Fundamentus): objeto para scrapper dos dados
        partition_cols (list): Referência de colunas de partição da tabela

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Coletando variáveis de ambiente para escrita dos dados
    output_database = os.getenv("DATABASE_NAME")
    output_table = os.getenv("TABLE_NAME")
    s3_sor_bucket_name = os.getenv("OUTPUT_BUCKET")

    # Definindo variáveis de saída do S3
    output_path = f"s3://{s3_sor_bucket_name}/{output_table}"

    # Informando total de mensagens recebidas para processamento
    total_msgs = len(event["Records"])
    logger.info(f"Mensagens recebidas para processamento: {total_msgs}")

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
        # Escrevendo dados no s3
        wr.s3.to_parquet(
            df=df_financial_data,
            path=output_path,
            dataset=True,
            database=output_database,
            table=output_table,
            partition_cols=partition_cols,
            mode="append",
            schema_evolution=True
        )

        # Comunicação final
        logger.info("Dados escritos no s3 e catalogados na tabela "
                    f"{output_table}")

    return {
        "status_code": 200,
        "body": {
            "tickers_proccessed": tickers,
            "total_tickers": total_msgs,
            "output_table": f"{output_database}.{output_table}"
        }
    }
