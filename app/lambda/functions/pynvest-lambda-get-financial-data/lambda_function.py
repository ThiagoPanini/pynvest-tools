# Importando bibliotecas
import json
import os

import awswrangler as wr
import pandas as pd
import numpy as np
import boto3

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


# Função auxiliar para transformação de colunas numéricas
def parse_numeric_cols(df: pd.DataFrame, cols_list: list):
    # Iterando sobre colunas
    for col in cols_list:
        # Substituindo todos os caracteres não numéricos para string vazia
        df[col] = df[col].replace('[^0-9,]', '', regex=True)

        # Substituindo strings vazias por nulos
        df[col] = df[col].replace("", np.nan)

        # Substituindo delimitador de vírgula por ponto
        df[col] = df[col].replace(",", ".", regex=True)

        # Convertendo string para float
        df[col] = df[col].astype(float)

    return df


# Função auxiliar para transformação de colunas com percentual
def parse_percent_cols(df: pd.DataFrame, cols_list: list):
    # Iterando sobre colunas
    for col in cols_list:
        # Dividindo valor percentual por 100
        df[col] = df[col] / 100

    return df


# Definindo função handler
def lambda_handler(
    event,
    context,
    pynvest_scrapper: Fundamentus = pynvest_scrapper,
    partition_cols: list = ["anomesdia_scrapper_exec"]
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

    # Criando client do Glue
    glue_client = boto3.client("glue")

    # Coletando dados da tabela no s3
    r = glue_client.get_table(
        DatabaseName=output_database,
        Name=output_table
    )

    # Extraindo nome e tipo primitivo de cada atributo
    table_columns = [
        {
            "name": col["Name"],
            "type": col["Type"]
        }
        for col in r["Table"]["StorageDescriptor"]["Columns"]
    ]

    # Extraindo colunas numéricas a serem transformadas
    numeric_cols_to_parse = [
        col["name"] for col in table_columns if col["type"] in ("float", "int")
    ]

    # Extraindo colunas contendo valor percentual para serem transformadas
    percent_cols_to_parse = [
        col for col in numeric_cols_to_parse if col[:4] == "pct_"
    ]

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

        # Aplicando transformações específicas em colunas
        df = parse_numeric_cols(df=df, cols_list=numeric_cols_to_parse)
        df = parse_percent_cols(df=df, cols_list=percent_cols_to_parse)

        # Iterando sobre os tipos primitivos das colunas e aplicando casting
        for col_info in table_columns:
            # Extraindo nome e tipo primitivo da coluna
            col_name = col_info["name"]
            col_type = col_info["type"]

            # Aplicando casting no DataFrame final
            if col_type not in ("date", "datetime", "timestamp"):
                df[col_name] = df[col_name].astype(col_type)

        # Criando coluna de partição
        df["anomesdia_scrapper_exec"] = pd.to_datetime(
            df["date_exec"], format="%d-%m-%Y"
        ).apply(lambda x: int(str(x).replace("-", "")[:8]))

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
