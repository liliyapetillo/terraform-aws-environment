"""List every EC2 instance in the region with its Environment tag.

Instances from both Terraform workspaces show up side by side, so it's easy
to see that staging and production are separate copies of the same stack.

Usage:
    python scripts/list_instances.py
    AWS_REGION=us-west-2 python scripts/list_instances.py
"""

import os
import sys

import boto3
from botocore.exceptions import BotoCoreError, ClientError

REGION = os.getenv("AWS_REGION", "us-east-1")  # same default as var.region


def get_tag(instance, key):
    for tag in instance.get("Tags", []):
        if tag["Key"] == key:
            return tag["Value"]
    return "-"


def list_instances(client):
    rows = []
    for page in client.get_paginator("describe_instances").paginate():
        for reservation in page["Reservations"]:
            for instance in reservation["Instances"]:
                rows.append(
                    {
                        "environment": get_tag(instance, "Environment"),
                        "name": get_tag(instance, "Name"),
                        "id": instance["InstanceId"],
                        "type": instance["InstanceType"],
                        "state": instance["State"]["Name"],
                        "az": instance["Placement"]["AvailabilityZone"],
                    }
                )
    # Group by environment so staging and production sit next to each other
    return sorted(rows, key=lambda row: (row["environment"], row["name"]))


def print_table(rows):
    columns = ["environment", "name", "id", "type", "state", "az"]
    widths = {col: max(len(col), *(len(row[col]) for row in rows)) for col in columns}

    print("  ".join(col.upper().ljust(widths[col]) for col in columns))
    for row in rows:
        print("  ".join(row[col].ljust(widths[col]) for col in columns))


def main():
    client = boto3.client("ec2", region_name=REGION)

    try:
        rows = list_instances(client)
    except ClientError as error:
        # AWS answered with an error, e.g. missing ec2:DescribeInstances permission
        print(f"AWS error: {error.response['Error']['Code']}: {error.response['Error']['Message']}", file=sys.stderr)
        return 1
    except BotoCoreError as error:
        # No response from AWS, e.g. no credentials configured or no network
        print(f"Could not call AWS: {error}", file=sys.stderr)
        return 1

    if not rows:
        print(f"No instances found in {REGION}.")
        return 0

    print_table(rows)
    return 0


if __name__ == "__main__":
    sys.exit(main())
