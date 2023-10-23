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
def lambda_handler(event, context):
    for msg in event["Records"]:
        msg_body = json.loads(msg["body"])
        print(msg_body)

"""
# (tmp) Recebendo mensagens
    r = sqs_client.get_queue_url(QueueName=sqs_queue_name)
    queue_url = r['QueueUrl']
    r = sqs_client.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=10,
        VisibilityTimeout=30,
        WaitTimeSeconds=10
    )
    messages = r["Messages"]
    print(len(messages))
    print(messages[0].keys())
    print(messages[0]["ReceiptHandle"])
    print(json.loads(messages[0]["Body"]))
    
    for msg in messages:
        msg_body = json.loads(msg["Body"])
        print(msg_body["ticker"])
    exit()
"""