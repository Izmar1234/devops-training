import json
import logging
import os

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2_client = boto3.client("ec2")


def get_target_instance_ids():
    """
    Récupère les identifiants EC2 fournis par Terraform dans
    la variable d'environnement TARGET_INSTANCE_IDS.
    """
    raw_instance_ids = os.environ.get("TARGET_INSTANCE_IDS", "")

    instance_ids = [
        instance_id.strip()
        for instance_id in raw_instance_ids.split(",")
        if instance_id.strip()
    ]

    if not instance_ids:
        raise ValueError(
            "La variable TARGET_INSTANCE_IDS ne contient aucune EC2."
        )

    return instance_ids


def get_instance_states(instance_ids):
    """
    Retourne l'état actuel de chaque instance ciblée.
    """
    response = ec2_client.describe_instances(
        InstanceIds=instance_ids
    )

    states = {}

    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            states[instance["InstanceId"]] = instance["State"]["Name"]

    return states


def lambda_handler(event, context):
    """
    Attend un événement au format :
        {"action": "start"}
    ou :
        {"action": "stop"}
    """
    logger.info("Événement reçu : %s", json.dumps(event))

    action = event.get("action")

    if action not in ["start", "stop"]:
        raise ValueError(
            "L'action doit être exactement 'start' ou 'stop'."
        )

    target_instance_ids = get_target_instance_ids()
    instance_states = get_instance_states(target_instance_ids)

    logger.info(
        "États actuels des instances : %s",
        json.dumps(instance_states),
    )

    if action == "start":
        actionable_instance_ids = [
            instance_id
            for instance_id, state in instance_states.items()
            if state == "stopped"
        ]

        if actionable_instance_ids:
            ec2_client.start_instances(
                InstanceIds=actionable_instance_ids
            )

    else:
        actionable_instance_ids = [
            instance_id
            for instance_id, state in instance_states.items()
            if state == "running"
        ]

        if actionable_instance_ids:
            ec2_client.stop_instances(
                InstanceIds=actionable_instance_ids
            )

    result = {
        "action": action,
        "target_instance_ids": target_instance_ids,
        "actionable_instance_ids": actionable_instance_ids,
        "instance_states_before_action": instance_states,
        "message": (
            f"Action {action} envoyée à "
            f"{len(actionable_instance_ids)} instance(s)."
        ),
    }

    logger.info("Résultat : %s", json.dumps(result))

    return {
        "statusCode": 200,
        "body": json.dumps(result),
    }
