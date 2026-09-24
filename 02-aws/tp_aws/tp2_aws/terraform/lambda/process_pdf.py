import json
import logging
import os
from urllib.parse import unquote_plus

import boto3


logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client("s3")

DESTINATION_BUCKET = os.environ["DESTINATION_BUCKET"]
FILENAME_PREFIX = os.environ.get("FILENAME_PREFIX", "tech_mind_")


def build_destination_key(source_key: str) -> str:
    """
    Ajoute le préfixe tech_mind_ au nom du fichier tout en conservant
    son éventuel dossier S3.

    Exemple :
        documents/rapport.pdf
    devient :
        documents/tech_mind_rapport.pdf
    """
    if "/" in source_key:
        directory, filename = source_key.rsplit("/", 1)
        return f"{directory}/{FILENAME_PREFIX}{filename}"

    return f"{FILENAME_PREFIX}{source_key}"


def lambda_handler(event, context):
    """
    Traite les événements envoyés par Amazon S3.

    Pour chaque PDF :
    1. récupère le fichier depuis le bucket source ;
    2. lit son contenu ;
    3. ajoute le préfixe tech_mind_ à son nom ;
    4. écrit le résultat dans le bucket destination.
    """
    logger.info("Événement reçu : %s", json.dumps(event))

    processed_files = []
    ignored_files = []

    for record in event.get("Records", []):
        source_bucket = record["s3"]["bucket"]["name"]
        source_key = unquote_plus(record["s3"]["object"]["key"])

        # Sécurité supplémentaire :
        # les fichiers qui ne terminent pas par .pdf sont ignorés.
        if not source_key.lower().endswith(".pdf"):
            logger.warning(
                "Objet ignoré car il ne s'agit pas d'un PDF : s3://%s/%s",
                source_bucket,
                source_key,
            )

            ignored_files.append(
                {
                    "bucket": source_bucket,
                    "key": source_key,
                    "reason": "not-a-pdf",
                }
            )
            continue

        destination_key = build_destination_key(source_key)

        logger.info(
            "Traitement de s3://%s/%s vers s3://%s/%s",
            source_bucket,
            source_key,
            DESTINATION_BUCKET,
            destination_key,
        )

        # Téléchargement du PDF depuis le bucket source.
        source_object = s3_client.get_object(
            Bucket=source_bucket,
            Key=source_key,
        )

        pdf_content = source_object["Body"].read()

        # Enregistrement du PDF renommé dans le bucket destination.
        s3_client.put_object(
            Bucket=DESTINATION_BUCKET,
            Key=destination_key,
            Body=pdf_content,
            ContentType="application/pdf",
            ServerSideEncryption="AES256",
        )

        processed_files.append(
            {
                "source": f"s3://{source_bucket}/{source_key}",
                "destination": (
                    f"s3://{DESTINATION_BUCKET}/{destination_key}"
                ),
                "size_bytes": len(pdf_content),
            }
        )

        logger.info(
            "PDF traité correctement : s3://%s/%s",
            DESTINATION_BUCKET,
            destination_key,
        )

    result = {
        "processed_count": len(processed_files),
        "ignored_count": len(ignored_files),
        "processed_files": processed_files,
        "ignored_files": ignored_files,
    }

    logger.info("Résultat : %s", json.dumps(result))

    return {
        "statusCode": 200,
        "body": json.dumps(result),
    }
