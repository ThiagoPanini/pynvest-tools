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

# Definindo mapeamento específico de colunas na tabela de Ações
SPECIFIC_ACOES_COLS_MAP = {
    "nome_papel": "codigo_ticker_ativo",
    "nome_empresa": "nome_ativo",
    "nome_setor": "nome_setor_segmento"
}

# Definindo mapeamento específico de colunas na tabela de FIIs
SPECIFIC_FIIS_COLS_MAP = {
    "fii": "codigo_ticker_ativo",
    "nome_fii": "nome_ativo",
    "segmento": "nome_setor_segmento"
}

# Definindo lista de colunas comuns em ambas as tabelas que permanecem
COMMON_COLS = [
    "codigo_ticker_ativo",
    "tipo_ativo",
    "nome_ativo",
    "nome_setor_segmento",
    "vlr_cot",
    "dt_ult_cot",
    "vlr_min_52_sem",
    "vlr_max_52_sem",
    "pct_var_dia",
    "pct_var_mes",
    "pct_var_30d",
    "pct_var_12m",
    "pct_var_2023",
    "pct_var_2022",
    "pct_var_2021",
    "pct_var_2020",
    "pct_var_2019",
    "pct_var_2018"
]


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
    output_bucket = os.getenv("OUTPUT_BUCKET")

    # Definindo variáveis de saída do S3
    output_s3_path = f"s3://{output_bucket}/{output_table}"

    # Coletando informações do evento de PUT no S3
    s3_event_info = event["Records"][0]["s3"]
    bucket_name = s3_event_info["bucket"]["name"]
    object_key = s3_event_info["object"]["key"].replace('%3D', '=')

    # Lendo arquivo parquet como DataFrame do pandas
    df_sot = wr.s3.read_parquet(
        path=f"s3://{bucket_name}/{object_key}"
    )

    # Coletando tickers do batch
    try:
        tickers = list(df_sot["nome_papel"].values)
    except KeyError:
        tickers = list(df_sot["fii"].values)

    # Comunicando extração de tickers coletados da fila
    tickers_info = ", ".join(tickers)
    logger.info(f"Ativos a terem seus indicadores preparados: {tickers_info}")

    # Verificando tipo de informação vinda da camada SoT (Ações ou FIIs)
    if 'fii' in df_sot.columns:
        # Renomando colunas específicas
        df_sot = df_sot.rename(columns=SPECIFIC_FIIS_COLS_MAP)

        # Adicionando coluna de indicativo de ativo
        df_sot["tipo_ativo"] = "Fundo Imobiliário"
    else:
        # Renomando colunas específicas
        df_sot = df_sot.rename(columns=SPECIFIC_ACOES_COLS_MAP)

        # Adicionando coluna de indicativo de ativo
        df_sot["tipo_ativo"] = "Ação"

    # Selecionando colunas comuns
    df_prep = df_sot.loc[:, COMMON_COLS]

    # Criando coluna de partição
    now = datetime.now(timezone(timedelta(hours=-3)))
    df_prep["anomesdia_exec"] = now.strftime("%Y%m%d")

    # Comunicando processamento de ativos
    logger.info("Quantidade de registros na base de indicadores financeiros "
                f"processada: {len(df_prep)}")

    # Escrevendo dados no s3 e catalogando no Glue Data Catalog
    wr.s3.to_parquet(
        df=df_prep,
        path=output_s3_path,
        dataset=True,
        database=output_database,
        table=output_table,
        partition_cols=partition_cols,
        mode="append",
        schema_evolution=True
    )

    # Comunicando sucesso da operação
    logger.info("Dados preparados foram lidos e especializados "
                "com sucesso. Os dados de saída foram armazenados "
                f"fisicamente no S3 em {output_s3_path} e catalogados na "
                f"tabela {output_database}.{output_table} no Data Catalog.")

    return {
        "status_code": 200,
        "body": {
            "total_rows": len(df_prep),
            "output_table": f"{output_database}.{output_table}"
        }
    }
