"""
Helper script to move the whole output of CWLTOOL workflow to
the local filesystem. This solution will later be replaced by
cloud storage solutions.
Disclaimer: This is a temporary solution and should not be used in production.
"""
import os
import glob
import shutil
import logging
import argparse


argparser = argparse.ArgumentParser(description='Move data from input_dir to output_dir')
argparser.add_argument('--input_dir', help='Input directory, use directory used in cwltool --outdir option. The output will be matched and moved to the output_dir.')
argparser.add_argument('--output_dir', help='Output directory')

logging.basicConfig(level=logging.INFO,
       format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
       datefmt='%Y-%m-%d %H:%M:%S',
       filename='movedata.log',
      )

Logger = logging.getLogger(__name__)


def move_data(input_dir: str, output_dir: str) -> None:
    """
    Move the data from input_dir to output_dir

    Parameters:
    input_dir (str): The input directory

    output_dir (str): The output directory

    """
    input_dir_pattern = f"{input_dir}/*/*"
    Logger.info("Moving data from %s to %s", input_dir, output_dir)
    for src in glob.glob(input_dir_pattern, recursive=True):
        parts = src.split(os.sep)
        relative_path = os.sep.join(parts[2:])
        dst = os.path.join(output_dir, relative_path)
        if not os.path.exists(os.path.dirname(dst)):
            os.makedirs(os.path.dirname(dst))
        shutil.move(src, dst)
        Logger.info("Moved %s to %s", src, dst)
    Logger.info("Data moved successfully")

if __name__ == "__main__":
    args = argparser.parse_args()
    input_dir = args.input_dir
    output_dir = args.output_dir
    move_data(input_dir, output_dir)