# Importando bibliotecas
import os
from datetime import datetime, timezone, timedelta

import awswrangler as wr

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
    Preparação de indicadores de financeiros de Ações e FIIs listados na B3.

    Args:
        event (dict): Evento de entrada da chamada da função (Put do S3)
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

    # Coletando informações do evento de PUT no S3
    s3_event_info = event["Records"][0]["s3"]
    bucket_name = s3_event_info["bucket"]["name"]
    object_key = s3_event_info["object"]["key"]

    print(object_key)

    # Lendo arquivo parquet como DataFrame do pandas
    df_sor = wr.s3.read_parquet(
        path=f"s3://{bucket_name}/{object_key}"
    )

    # Coletando tickers do batch
    try:
        tickers = list(df_sor["nome_papel"].values)
    except KeyError:
        tickers = list(df_sor["fii"].values)

    # Comunicando extração de tickers coletados da fila
    tickers_info = ", ".join(tickers)
    logger.info(f"Ativos a terem seus indicadores preparados: {tickers_info}")

    # Coletando atributos de string que representam números
    float_cols_to_parse = [
        col for col in list(df_sor.columns)
        if col[:4] in (
            "vlr_", "vol_", "num_", "pct_", "qtd_", "max_", "min_",
            "total_"
        )
    ]

    # Coletando apenas atributos que representam percentuais
    percent_cols_to_parse = [
        col for col in float_cols_to_parse if col[:4] in ("pct_")
    ]

    # Transformando strings que representam números
    df_float_prep = pynvest_scrapper._parse_float_cols(
        df=df_sor,
        cols_list=float_cols_to_parse
    )

    # Transformando percentuais que representam números
    df_prep = pynvest_scrapper._parse_pct_cols(
        df=df_float_prep,
        cols_list=percent_cols_to_parse
    )

    # Criando coluna de partição
    now = datetime.now(timezone(timedelta(hours=-3)))
    df_prep["anomesdia_exec"] = now.strftime("%Y%m%d")

    # Comunicando processamento de ativos
    logger.info("Quantidade de registros na base de indicadores financeiros "
                f"processada: {len(df_prep)}")

    # Escrevendo dados no s3 e catalogando no Glue Data Catalog
    wr.s3.to_parquet(
        df=df_prep,
        path=output_path,
        dataset=True,
        database=output_database,
        table=output_table,
        partition_cols=partition_cols,
        mode="append",
        schema_evolution=True
    )

    # Comunicando sucesso da operação
    logger.info("Dados brutos de indicadores financeiros lidos e preparados "
                "com sucesso. Os dados de saída foram armazenados "
                f"fisicamente no S3 em {output_path} e catalogados na "
                f"tabela {output_database}.{output_table} no Data Catalog.")

    return {
        "status_code": 200,
        "body": {
            "total_rows": len(df_prep),
            "output_table": f"{output_database}.{output_table}"
        }
    }
