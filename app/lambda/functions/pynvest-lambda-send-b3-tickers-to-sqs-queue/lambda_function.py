# Importando bibliotecas
import boto3
import json

from pynvest.scrappers.fundamentus import Fundamentus
from pynvest.utils.log import log_config
import logging


# Configurando objeto logger
logger = log_config(logger_name=__file__, logger_level=logging.INFO)
logger.propagate = False


# Definindo função handler
def lambda_handler(
    event,
    context,
    sqs_queue_name: str = "pynvest-tickers-queue"
):
    """
    Extração de tickers de Ações e FIIs da B3 para fila no SQS.

    Esta função é responsável por utilizar as funcionalidades da biblioteca
    pynvest (módulo fundamentus) para extrair toda a listagem de tickers
    (códigos) de Ações e Fundos Imobiliários listados na B3 e, posteriormente,
    enviar tais informações para uma fila pré configurada no SQS.

    Args:
        event (dict): Evento de entrada da chamada da função.
        context (LambdaContext): Metadados da própria função.
        sqs_queue_name: Nome da fila SQS alvo do envio das mensagens.

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Instanciando objeto de scrapper do pynvest
    pynvest_scrapper = Fundamentus(logger_level=logging.DEBUG)
    pynvest_scrapper.logger.propagate = False

    # Instanciando client do SQS
    sqs_client = boto3.client("sqs")

    # Obtendo tickers de ações e fundos imobiliários
    tickers_acoes = pynvest_scrapper.extracao_tickers_de_ativos(tipo="ações")
    tickers_fiis = pynvest_scrapper.extracao_tickers_de_ativos(tipo="fiis")

    # Criando dicionário de identificação de tickers de Ações
    tickers_acoes_identified = [
        {
            "ticker": ticker,
            "tipo": "acao"
        }
        for ticker in tickers_acoes
    ]

    # Criando dicionário de identificação de tickers de FIIs
    ticker_fiis_identified = [
        {
            "ticker": ticker,
            "tipo": "fii"
        }
        for ticker in tickers_fiis
    ]

    # Unindo listas em estrutura única
    tickers_messages = tickers_acoes_identified + ticker_fiis_identified

    # (tmp) Reduzindo a quantidade de mensagens para fins de validação
    tickers_messages = tickers_messages[:50]

    # Iterando sobre todos os tickers para envio de mensagens para fila SQS
    logger.info(f"Iterando sobre os {len(tickers_messages)} códigos de ativos "
                "extraídos e enviando para fila no SQS")
    for msg in tickers_messages:
        # Coletando URL da fila
        r = sqs_client.get_queue_url(QueueName=sqs_queue_name)
        queue_url = r['QueueUrl']

        # Enviando mensagem
        r = sqs_client.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(msg)
        )
    logger.info(f"Mensagens enviadas com sucesso para fila SQS {queue_url}")

    return {
        "status_code": 200,
        "body": {
            "total_messages": len(tickers_messages),
            "queue_url": queue_url
        }
    }
