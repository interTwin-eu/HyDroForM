#!/usr/bin/env python3
"""Decode base64 environment variable keys for S3 and update the environment variables."""
import os
import base64
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[logging.StreamHandler()],
)

def decode_base64_env_vars(access_key: str|None, secret_key: str|None) -> tuple[str, str]|None:
    """Decode base64 encoded environment variables for S3 credentials."""

    if access_key is None or secret_key is None:
        logger.error("Both access_key and secret_key must be provided.")
        exit()

    decoded_access_key = base64.b64decode(access_key).decode('utf-8')
    os.environ['AWS_ACCESS_KEY_ID'] = decoded_access_key
    logger.info("Decoded AWS_ACCESS_KEY_ID.")

    decoded_secret_key = base64.b64decode(secret_key).decode('utf-8')
    os.environ['AWS_SECRET_ACCESS_KEY'] = decoded_secret_key
    logger.info("Decoded AWS_SECRET_ACCESS_KEY.")
    return decoded_access_key, decoded_secret_key

if __name__ == "__main__":
    logger.info("Starting to decode environment variables for AWS credentials.")
    access_key = os.getenv("AWS_ACCESS_KEY_ID")
    secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
    decode_base64_env_vars(access_key, secret_key)
    logger.info("Environment variables decoded and updated.")
