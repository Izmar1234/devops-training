import logging
import os

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2 = boto3.client("ec2")

OWNER_TAG = os.environ["OWNER_TAG"]
SCHEDULE_TAG = os.environ["SCHEDULE_TAG"]


def find_instances(action):
    if action == "start":
        required_state = "stopped"
    elif action == "stop":
        required_state = "running"
    else:
        raise ValueError("L'action doit être 'start' ou 'stop'")

    filters = [
        {
            "Name": "tag:Owner",
            "Values": [OWNER_TAG],
        },
        {
            "Name": "tag:Schedule",
            "Values": [SCHEDULE_TAG],
        },
        {
            "Name": "instance-state-name",
            "Values": [required_state],
        },
    ]

    instance_ids = []
    paginator = ec2.get_paginator("describe_instances")

    for page in paginator.paginate(Filters=filters):
        for reservation in page["Reservations"]:
            for instance in reservation["Instances"]:
                instance_ids.append(instance["InstanceId"])

    return instance_ids


def lambda_handler(event, context):
    logger.info("Événement reçu : %s", event)

    action = event.get("action")

    if action not in {"start", "stop"}:
        raise ValueError(
            "Le champ event.action doit contenir 'start' ou 'stop'"
        )

    instance_ids = find_instances(action)

    if not instance_ids:
        result = {
            "action": action,
            "instances": [],
            "message": "Aucune instance ne nécessite cette action",
        }

        logger.info("Résultat : %s", result)
        return result

    if action == "start":
        response = ec2.start_instances(InstanceIds=instance_ids)
    else:
        response = ec2.stop_instances(InstanceIds=instance_ids)

    result = {
        "action": action,
        "instances": instance_ids,
        "request_id": response["ResponseMetadata"]["RequestId"],
    }

    logger.info("Résultat : %s", result)

    return result