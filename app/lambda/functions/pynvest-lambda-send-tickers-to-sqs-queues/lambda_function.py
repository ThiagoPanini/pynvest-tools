# Importando bibliotecas
import boto3
import json

from pynvest.scrappers.fundamentus import Fundamentus
from pynvest.utils.log import log_config
import logging


# Configurando objeto logger
logger = log_config(logger_name="lambda-logger", logger_level=logging.INFO)
logger.propagate = False

# Instanciando objeto de scrapper do pynvest
pynvest_scrapper = Fundamentus(logger_level=logging.DEBUG)
pynvest_scrapper.logger.propagate = False


# Definindo função handler
def lambda_handler(
    event,
    context,
    pynvest_scrapper: Fundamentus = pynvest_scrapper,
    sqs_acoes_queue_name: str = "pynvest-tickers-acoes-queue",
    sqs_fiis_queue_name: str = "pynvest-tickers-fiis-queue"
):
    """
    Extração de tickers de Ações e FIIs da B3 para filas no SQS.

    Args:
        event (dict): Evento de entrada da chamada da função.
        context (LambdaContext): Metadados da própria função.
        sqs_acoes_queue_name: Fila SQS para envio de tickers de ações.
        sqs_fiis_queue_name: Fila SQS para envio de tickers de FIIs.

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Instanciando client do SQS
    sqs_client = boto3.client("sqs")

    # Coletando URL de filas SQS para ações e fiis
    sqs_acoes_queue_url = sqs_client.get_queue_url(
        QueueName=sqs_acoes_queue_name
    )['QueueUrl']
    sqs_fiis_queue_url = sqs_client.get_queue_url(
        QueueName=sqs_fiis_queue_name
    )['QueueUrl']

    # Obtendo tickers de ações e fundos imobiliários
    tickers_acoes = pynvest_scrapper.extracao_tickers_de_ativos(tipo="ações")
    tickers_fiis = pynvest_scrapper.extracao_tickers_de_ativos(tipo="fiis")

    # Criando dicionário de identificação de tickers de Ações
    tickers_acoes_identified = [
        {
            "ticker": ticker,
            "tipo": "acao",
            "queue_url": sqs_acoes_queue_url
        }
        for ticker in tickers_acoes
    ]

    # Criando dicionário de identificação de tickers de FIIs
    ticker_fiis_identified = [
        {
            "ticker": ticker,
            "tipo": "fii",
            "queue_url": sqs_fiis_queue_url
        }
        for ticker in tickers_fiis
    ]

    # Unindo listas em estrutura única
    tickers_messages = tickers_acoes_identified + ticker_fiis_identified

    # Iterando sobre todos os tickers para envio de mensagens para fila SQS
    logger.info(f"Iterando sobre os {len(tickers_messages)} códigos de ativos "
                "extraídos e enviando para fila no SQS")
    for msg in tickers_messages:
        # Enviando mensagem
        _ = sqs_client.send_message(
            QueueUrl=msg["queue_url"],
            MessageBody=json.dumps(msg)
        )

    # Comunicando totais
    total_msgs_acoes = len(tickers_acoes)
    total_msgs_fiis = len(tickers_fiis)
    logger.info("Mensagens enviadas com sucesso para filas SQS. Totalizando: "
                f"\n{sqs_acoes_queue_name}: {total_msgs_acoes} mensagens "
                f"\n{sqs_fiis_queue_name}: {total_msgs_fiis} mensagens")

    return {
        "status_code": 200,
        "body": {
            "sqs_queues": {
                sqs_acoes_queue_name: {
                    "total_messages": total_msgs_acoes
                },
                sqs_fiis_queue_name: {
                    "total_messages": total_msgs_acoes
                }
            }
        }
    }
