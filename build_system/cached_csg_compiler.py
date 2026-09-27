"""Compile CSG files into STL files, using cached outputs if the inputs are unchanged."""

import argparse
import logging
import os
import sys
import subprocess

import yaml

from .hash_csg_files import generate_hash, normalise_path

def load_hash_file(hash_file_path):
    """Load the hash file and return a dictionary"""
    with open(hash_file_path, "r", encoding='utf-8') as hashfile:
        return yaml.safe_load(hashfile)

def needs_recompile(output_path, hashes, ignore_unchanged=False):
    """Check if a file needs to be recompiled.

    NB at the moment, to save on needless hashing of input SCAD files,
    we *always* recompile CSG files from the SCAD source, and don't
    bother checking.
    """
    # We deal with the first three cases first, because we don't need to calculate any
    # hashes in these cases.
    if output_path.endswith(".csg"):
        return True
    # Ensure the path is in the same format (relative, forward slashes) as the hash keys
    output_path = normalise_path(output_path)
    if output_path not in hashes:
        logging.info("BUILD %s because it's not mentioned in the hash file", output_path)
        return True
    if (not ignore_unchanged) and (not os.path.exists(output_path)):
        logging.info("BUILD %s because it is missing", output_path)
        return True
    # Now we check if any of the dependencies have changed - and rebuild if so.
    for dep_path, dep_hash in hashes[output_path]['dependency_hashes'].items():
        if generate_hash(dep_path) != dep_hash:
            # A dependency has changed, so we must recompile
            logging.info("BUILD %s because %s changed", output_path, dep_path)
            return True
    # If we reach here, the input files are unchanged so output won't have changed either
    if os.path.exists(output_path):
        if generate_hash(output_path) == hashes[output_path]["output_hash"]:
            logging.info("HIT %s is unchanged", output_path)
            return False
        logging.warning("BUILD %s as it doesn't match the output hash", output_path)
        if output_path.endswith(".stl"):
            logging.warning(
                "%s has been rebuilt because it doesn't match the output hash. "
                "STL builds in OpenSCAD are not deterministic, so "
                "the rebuilt file will also not match the old hash.",
                output_path
            )
        return True
    # If the output is missing, ignore_unchanged must have been false, or
    # we would have returned true before checking hashes. So, ignore_unchanged
    # is true, and we should not recompile a file that's missing but unchanged
    logging.info("SKIP %s as it's unchanged, even though it is missing.", output_path)
    return False

def run_openscad(input_path, output_path):
    """Run OpenSCAD to turn a CSG into an STL"""
    try:
        cli = ["openscad", "--hardwarnings", input_path, "-o", output_path, "-d", output_path + ".d"]
        subprocess.run(cli, check=True)
    except subprocess.CalledProcessError:
        print("\tERROR: Command failed:", " ".join(cli), file=sys.stderr)
        sys.exit(-1)

def parse_command_line_args():
    """Process command-line arguments"""
    parser = argparse.ArgumentParser(
        description="Compile a CSG file, checking for previous cached builds."
    )
    parser.add_argument("input", help="The input CSG filename")
    parser.add_argument("output", help="The output STL filename")
    parser.add_argument("--hash_file", default="csg_hashes.yaml", help="The hash file")
    parser.add_argument(
        "--ignore_unchanged_outputs",
        action="store_true",
        help="This option will not build outputs that have not changed, even if they are missing.",
    )
    return parser.parse_args()

def process_one_file(input_path, output_path, hash_file, ignore_unchanged_outputs=False):
    """Compile one input file into an output file, checking against the hashes"""
    try:
        hashes = load_hash_file(hash_file)
        if needs_recompile(output_path, hashes, ignore_unchanged=ignore_unchanged_outputs):
            run_openscad(input_path, output_path)
    except FileNotFoundError:
        logging.info("BUILD %s because the hash file is missing", output_path)
        run_openscad(input_path, output_path)

if __name__ == "__main__":
    logging.getLogger().setLevel(logging.INFO)
    args = parse_command_line_args()
    process_one_file(args.input, args.output, args.hash_file, args.ignore_unchanged_outputs)
