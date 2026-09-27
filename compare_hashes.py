#! /usr/bin/env python3
"""
Comparing dependency_hashes.yaml.

This cannot be done easily with GitDiff as the ouput hash for a file is on
a different line and because the STL files are not reported in every
dependency_hashes.yaml depending on if that branch is unchanged from a previous
run. Therefore check the fixed CSG (to remove the timeshamp issue) with csgs
that import files.
"""

import json
import re

import yaml

CSG_REGEX = re.compile("fixed\.csg$")


def _to_stl_file(csg_file):
    return CSG_REGEX.sub("stl", csg_file)


import argparse
from argparse import Namespace


def parse_args() -> Namespace:
    """
    Parse command-line arguments for comparing dependency hash files.

    Returns:
        argparse.Namespace: Parsed arguments with 'branch_hash_file' and
        'master_hash_file' attributes.
    """
    parser = argparse.ArgumentParser(
        description="Compare two dependency hash YAML files and report differences."
    )

    parser.add_argument(
        "branch_hash_file",
        type=str,
        help="Path to the dependency_hashes.yaml file from the current branch.",
    )

    parser.add_argument(
        "master_hash_file",
        type=str,
        help="Path to the dependency_hashes.yaml file from the master branch.",
    )

    return parser.parse_args()


def main(branch_hash_file: str, master_hash_file: str) -> None:
    """
    Compare the hashes, print changes to terminal and make a summary for GitLab
    MR
    """
    with open(branch_hash_file, "r", encoding="utf-8") as f_obj:
        branch_hash_dict = yaml.safe_load(f_obj)
    with open(master_hash_file, "r", encoding="utf-8") as f_obj:
        master_hash_dict = yaml.safe_load(f_obj)

    # use sets to allow for subtraction comparison and boolean operations
    branch_csgs = {
        fname for fname in branch_hash_dict.keys() if fname.endswith(".fixed.csg")
    }
    master_csgs = {
        fname for fname in master_hash_dict.keys() if fname.endswith(".fixed.csg")
    }

    added = 0
    removed = 0
    changed = 0

    for csg_file in branch_csgs - master_csgs:
        added += 1
        print(f"!! {_to_stl_file(csg_file)} is new in branch")

    for csg_file in master_csgs - branch_csgs:
        removed += 1
        print(f"!! {_to_stl_file(csg_file)} is removed in branch")

    for csg_file in branch_csgs & master_csgs:
        branch_hash = branch_hash_dict[csg_file]["output_hash"]
        master_hash = master_hash_dict[csg_file]["output_hash"]
        if master_hash != branch_hash:
            changed += 1
            print(f"{_to_stl_file(csg_file)} has changed!")

    summary_txt = f"added_stls: {added}\n"
    summary_txt += f"removed_stls: {removed}\n"
    summary_txt += f"changed_stls: {changed}\n"

    with open("stl_changes.txt", "w", encoding="utf-8") as file_id:
        file_id.write(summary_txt)


if __name__ == "__main__":
    args = parse_args()
    main(args.branch_hash_file, args.master_hash_file)
