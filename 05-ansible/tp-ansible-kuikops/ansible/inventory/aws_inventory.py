#!/usr/bin/env python3
import json
import os
import subprocess
import sys

REGION = os.environ.get("AWS_REGION") or os.environ.get("AWS_DEFAULT_REGION") or "eu-west-3"
PREFIX = "tech-mind-izmar-abderrahim-tp-ansible"

GROUPS = {
    "fronts": ["front-01", "front-02"],
    "jenkins": ["front-01"],
    "jenkins_worker": ["front-02"],
    "glpi_app": ["glpi-app"],
    "glpi_db": ["glpi-db"],
}

ALIASES = ["front-01", "front-02", "glpi-app", "glpi-db"]
NAME_TO_ALIAS = {f"{PREFIX}-{alias}": alias for alias in ALIASES}


def build_inventory():
    command = [
        "aws", "ec2", "describe-instances",
        "--region", REGION,
        "--filters",
        "Name=tag:Name,Values=" + ",".join(NAME_TO_ALIAS),
        "Name=instance-state-name,Values=running",
        "--output", "json",
    ]
    environment = os.environ.copy()
    environment["AWS_PAGER"] = ""
    response = json.loads(
        subprocess.check_output(command, text=True, env=environment)
    )

    hostvars = {}
    for reservation in response.get("Reservations", []):
        for instance in reservation.get("Instances", []):
            tags = {tag["Key"]: tag["Value"] for tag in instance.get("Tags", [])}
            alias = NAME_TO_ALIAS.get(tags.get("Name"))
            if alias is None:
                continue
            if alias in hostvars:
                raise ValueError(f"Plusieurs instances portent le nom de {alias}.")

            address = (
                instance.get("PrivateIpAddress")
                if alias == "glpi-db"
                else instance.get("PublicIpAddress")
            )
            if not address:
                raise ValueError(f"Adresse indisponible pour {alias}.")

            hostvars[alias] = {
                "ansible_host": address,
                "private_ip_address": instance["PrivateIpAddress"],
            }

    if not hostvars:
        raise ValueError("Aucune instance running trouvée pour ce projet.")

    if "glpi-db" in hostvars and "front-01" in hostvars:
        bastion_ip = hostvars["front-01"]["ansible_host"]
        hostvars["glpi-db"]["ansible_ssh_common_args"] = (
            f"-o ProxyJump=ubuntu@{bastion_ip} -o IdentitiesOnly=yes"
        )

    inventory = {
        "_meta": {"hostvars": hostvars},
        "all": {"children": list(GROUPS)},
    }
    for group, aliases in GROUPS.items():
        inventory[group] = {
            "hosts": [alias for alias in aliases if alias in hostvars]
        }
    return inventory


if __name__ == "__main__":
    try:
        inventory = build_inventory()
        if "--host" in sys.argv:
            hostname = sys.argv[sys.argv.index("--host") + 1]
            print(json.dumps(inventory["_meta"]["hostvars"].get(hostname, {})))
        else:
            print(json.dumps(inventory))
    except (OSError, ValueError, subprocess.CalledProcessError, IndexError) as error:
        print(f"Erreur inventaire AWS : {error}", file=sys.stderr)
        sys.exit(1)
