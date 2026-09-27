"""
Generate hashes of all built files and their dependencies

This will enable us to reliably figure out which ones have changed. In time, it will
also form the basis of a proper cacheing system that enables incremental builds.
"""


import argparse
import os
import subprocess
import sys
import fnmatch
import yaml

_filepath_to_hash_cache = {}
def generate_hash(fpath: str):
    """Calculate a git-style SHA1 hash of a file

    I've switched to using git (much slower than hashlib) because
    it normalises line endings, and I think that's very helpful.

    If you always calculate the hashes on one machine there's no
    issue, but I think there is great value in consistency over
    speed.
    """
    if fpath not in _filepath_to_hash_cache:
        if not os.path.isfile(fpath):
            return None
        fhash = subprocess.check_output(["git", "hash-object", fpath])
        _filepath_to_hash_cache[fpath] = fhash.decode("utf-8").strip()
    return _filepath_to_hash_cache[fpath]

def normalise_path(fpath: str):
    """Normalise a path (with os.path.normpath) and ensure it uses forward slashes"""
    npath = os.path.normpath(os.path.relpath(fpath, '.'))
    return npath.replace("\\", "/")

def find_output_files(dirname, patterns=None):
    """Find all the output files

    This filters according to a series of patterns (default `['*.stl', '*.csg']`)
    and recursively traverses `dirname`.
    """
    if patterns is None:
        patterns = ["*.stl", "*.csg"]
    paths = []
    for folder, _subfolders, files in os.walk(dirname):
        # Filter out the matching files (probably just STL for now)
        for pattern in patterns:
            for fname in files:
                if fnmatch.fnmatch(fname, pattern):
                    paths.append(normalise_path(os.path.join(folder, fname)))
    return paths


def parse_dependencies(output_files):
    """Parse .d files for the outputs to construct a dependency graph

    Currently this only works for OpenSCAD depfiles, which put one file
    per line."""
    graph = {}
    for fname in output_files:
        depfname = fname + ".d"
        if fname not in graph and os.path.exists(depfname):
            with open(depfname, "r", encoding='utf-8') as depfile:
                first_line = depfile.readline()
                assert first_line.endswith(": \\\n")
                dependencies = [line.strip("\t \\\n") for line in depfile]
            normalised_dependencies = [
                normalise_path(d) for d in dependencies
            ]
            graph[fname] = {"dependencies": normalised_dependencies}
    return graph

def add_hashes_to_graph(graph):
    """Calculate hashes of input and output files, and add them to a dictionary"""
    for k in graph.keys():
        graph[k]["output_hash"] = generate_hash(k)
        graph[k]["dependency_hashes"] = {
            dep: generate_hash(dep) for dep in graph[k]["dependencies"]
        }
    return graph

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Calculate hashes of build products and dependencies"
    )
    parser.add_argument(
        "output_directory",
        help="The directory where output files are located"
    )
    parser.add_argument(
        "--output", "-o",
        nargs="?",
        help="Output filename for the YAML dictionary with hashes."
    )
    args = parser.parse_args()

    outputs = find_output_files(args.output_directory)
    depgraph = parse_dependencies(outputs)
    depgraph = add_hashes_to_graph(depgraph)

    if args.output:
        with open(args.output, "w", encoding='utf-8') as outfile:
            yaml.dump(depgraph, outfile)
    else:
        yaml.dump(depgraph, sys.stdout)
