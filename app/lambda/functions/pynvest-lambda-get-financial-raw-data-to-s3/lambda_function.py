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
    Extração de indicadores de financeiros de tickers de Ações e FIIs da B3.

    Esta função é responsável por utilizar as funcionalidades da biblioteca
    pynvest (módulo fundamentus) para extrair indicadores financeiros através
    de tickers previamente disponibilizados como mensagens em uma fila SQS.

    Args:
        event (dict):
            Evento de entrada da chamada da função. Nesse caso, como o gatilho
            da função é dado como uma fila SQS, o dicionário de eventos contém
            informações sobre mensagens enviadas para a fila.

        context (LambdaContext): Metadados da própria função.

    Return:
        Dicionário contendo informações sobre o resultado de execução da função
    """

    # Instanciando objeto de scrapper do pynvest
    pynvest_scrapper = Fundamentus(logger_level=logging.DEBUG)
    pynvest_scrapper.logger.propagate = False

    total_msgs = len(event["Records"])
    logger.info("Quantidade de mensagens recebidas para processamento: "
                f"{total_msgs}")

    return 200
