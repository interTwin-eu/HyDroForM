import logging
import os
import time

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger(__name__)


def main():
    # Read environment variables (simulate required inputs)
    input1 = os.getenv("DUMMY_INPUT1", "default1")
    input2 = os.getenv("DUMMY_INPUT2", "default2")
    input_stac = os.getenv("INPUT_STAC", "default_stac")
    logger.info(f"Received inputs: DUMMY_INPUT1={input1},\n DUMMY_INPUT2={
        input2},\n INPUT_STAC={input_stac}")

    # Simulate processing
    logger.info("Simulating processing...")
    time.sleep(2)

    # Return a fixed URL as output
    output_url = "https://stac.intertwin.fedcloud.eu/collections/8db57c23-4013-45d3-a2f5-a73abf64adc4_WFLOW_FORCINGS_STATICMAPS"
    logger.info(f"STAC OUTPUT URL {output_url}")


if __name__ == "__main__":
    main()
