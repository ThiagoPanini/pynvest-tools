# Importando bibliotecas
import json
import os
from datetime import datetime, timezone, timedelta

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
    partition_cols: list = ["anomesdia_exec"]
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
    output_database = os.getenv("OUTPUT_DATABASE_NAME")
    output_table = os.getenv("OUTPUT_TABLE_NAME")
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

    # Comunicando extração de tickers coletados da fila
    tickers_info = ", ".join(tickers)
    logger.info(f"Ativos a terem seus indicadores extraídos: {tickers_info}")

    # Criando DataFrame vazio para appendar extrações
    df_financial_data = pd.DataFrame()

    # Iterando sobre mensagens
    for ticker in tickers:
        # Iniciando extração de indicadores de ativo
        df = pynvest_scrapper.coleta_indicadores_de_ativo(ticker=ticker)

        # Criando coluna de partição
        now = datetime.now(timezone(timedelta(hours=-3)))
        df["anomesdia_exec"] = now.strftime("%Y%m%d")

        # Appendando em DataFrame final
        df_financial_data = pd.concat(objs=[df_financial_data, df])
        df_financial_data.reset_index(drop=True, inplace=True)

    # Comunicando processamento de ativos
    logger.info("Quantidade de registros na base de indicadores financeiros "
                f"processada: {len(df_financial_data)}")

    # Escrevendo dados no s3 e catalogando no Glue Data Catalog
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

    # Comunicando sucesso da operação
    logger.info(f"Indicadores financeiros dos ativos {tickers_info} "
                f"({len(tickers)}) foram extraídos com sucesso e armazenados "
                f"fisicamente no S3 em {output_path} e catalogados na "
                f"tabela {output_database}.{output_table} no Data Catalog.")

    return {
        "status_code": 200,
        "body": {
            "tickers_proccessed": tickers,
            "total_tickers": total_msgs,
            "output_table": f"{output_database}.{output_table}"
        }
    }
