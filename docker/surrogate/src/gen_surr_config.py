#!/usr/bin/env python3

import yaml
import ast
import logging
import argparse
from omegaconf import OmegaConf

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger(__name__)


def parse_arguments():
    parser = argparse.ArgumentParser(
        description=(
            "Generate a surrogate YAML configuration file from a template and command line overrides.\n\n"
            "Examples:\n"
            "  python gen_surr_config.py --config config.yaml --output test.yaml \\\n"
            "    --cp \"model=TEST_MODEL\" \\\n"
            "    --cp \"metric_fn._target_=hython.metrics.MAE_TEST\" \\\n"
            "    --cp 'train_temporal_range=[\"3500-01-01\", \"3600-01-01\"]'\n\n"
            "Formatting for --cp:\n"
            "  - Use dot notation for nested keys, e.g. metric_fn._target_=hython.metrics.MAE_TEST\n"
            "  - Lists: train_temporal_range=[\"YYYY-MM-DD\", \"YYYY-MM-DD\"]\n"
            "  - Strings: key=value\n"
            "  - Numbers: key=123\n"
            "  - Booleans: key=True\n"
            "  - Multiple --cp can be used to override multiple parameters."
        ),
        formatter_class=argparse.RawTextHelpFormatter
    )

    parser.add_argument(
        "--c",
        "--config",
        required=True,
        type=str,
        help="Path to the surrogate configuration YAML file.",
        dest="config_path",
    )
    parser.add_argument(
        "--o",
        "--output",
        required=True,
        type=str,
        help="Path to save the generated YAML configuration file.",
        dest="output_path",
    )
    parser.add_argument(
        "--cp",
        "--config_param",
        type=str,
        metavar="KEY=VALUE",
        help=(
            "Override configuration parameters. "
            "Use dot notation for nested keys. "
            "Example: --cp metric_fn._target_=hython.metrics.MAE_TEST"
        ),
        action="append",
        dest="config_params",
    )

    return parser.parse_args()


def load_config(config_path):
    return OmegaConf.load(config_path)


def set_nested(cfg, dotted_key, value):
    """Set a value in a nested OmegaConf DictConfig using dot notation."""
    OmegaConf.update(cfg, dotted_key, value, merge=True)


def main():
    logger.info("Starting configuration generation...")
    args = parse_arguments()

    if not args.config_path.endswith(".yaml"):
        logger.error("Configuration file must be a YAML file.")
        return

    if not args.output_path.endswith(".yaml"):
        logger.error("Output file must be a YAML file.")
        return

    logger.info(f"Loading configuration from {args.config_path}")
    config = load_config(args.config_path)

    if args.config_params:
        logger.info("Applying overrides...")
        for param in args.config_params:
            if "=" in param:
                key, value = param.split("=", 1)
                try:
                    parsed_value = ast.literal_eval(value)
                except (ValueError, SyntaxError):
                    parsed_value = value
                logger.info(f"Setting parameter: {key} = {parsed_value}")
                set_nested(config, key, parsed_value)
            else:
                logger.warning(
                    f"Ignoring malformed parameter: {param} (expected key=value)"
                )

    logger.info(f"Saving updated configuration to {args.output_path}")
    yaml.add_representer(
        dict,
        lambda dumper, data: dumper.represent_mapping(
            "tag:yaml.org,2002:map", data, flow_style=False
        ),
    )
    with open(args.output_path, "w") as f:
        yaml.dump(
            OmegaConf.to_container(config, resolve=False),
            f,
            default_flow_style=None,
            sort_keys=False,
        )
    logger.info("Configuration saved successfully.")


if __name__ == "__main__":
    main()
