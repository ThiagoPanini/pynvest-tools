# Importando bibliotecas
from pynvest.scrappers.fundamentus import Fundamentus
import boto3
import json


def lambda_handler(
    event,
    context,
    sqs_queue_name: str = "tmp-pynvest-tickers-queue"
):

    # Instanciando clients e objetos necessários
    pynvest_scrapper = Fundamentus()
    sqs_client = boto3.client("sqs")

    # Obtendo tickers de ações e fundos imobiliários
    tickers_acoes = pynvest_scrapper.extracao_tickers_de_ativos(tipo="ações")
    tickers_fiis = pynvest_scrapper.extracao_tickers_de_ativos(tipo="fiis")

    # Criando dicionário de identificação de tickers de Ações
    tickers_acoes_identified = [
        {
            "ticker": ticker,
            "tipo": "ação"
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

    # Iterando sobre todos os tickers para envio de mensagens para fila SQS
    for msg in tickers_messages:
        # Coletando URL da fila
        r = sqs_client.get_queue_url(QueueName=sqs_queue_name)
        queue_url = r['QueueUrl']

        # Enviando mensagem
        r = sqs_client.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps(msg)
        )

    return {
        'statusCode': 200,
        'body': f"Quantidade de tickers: {len(tickers_messages)}"
    }


if __name__ == "__main__":
    r = lambda_handler(None, None)
    print(r)
