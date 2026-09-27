"""
This module has a range of misc utilities for the build system.
"""
import sys
import os
import subprocess
from copy import copy
import re
import platform

def get_openscad_exe():
    """
    This returns the name of the openscad executable. It is needed as OpenSCAD is not
    on the path in MacOS.
    """
    if sys.platform.startswith("darwin"):
        return "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
    return "openscad"


def parameters_to_string(parameters):
    """
    Build an OpenScad parameter arguments string from a variable name and value

    Arguments:
        parameters {dict} -- Dictionary of parameters
    """
    strings = []
    for name in parameters:
        value = parameters[name]
        # Convert bools to lowercase
        if isinstance(value, bool):
            value = str(value).lower()
        # Wrap strings in quotes
        elif isinstance(value, str):
            if '"' in value or "'" in value:
                raise ValueError(
                    "Strings passed as parameters may not contain quotation marks. "
                    f"{name}=\"{value}\" is therefore not valid."
                )
            value = f'"{value}"'

            if platform.system() == 'Windows':
                # Add escape to quotes in value, so we can use double quotes around parameter below
                value = value.replace("\"", "\\\"")

        if platform.system() == 'Windows':
            # Nested single/double quotes were being stripped out on Windows, so we use
            # double quotes for both, and escape the inner ones (see above) for strings.
            # The inner double quotes appear in `value` for strings
            strings.append(f"-D \"{name}={value}\"")
        else:
            strings.append(f"-D '{name}={value}'")

    return " ".join(strings)

def version_string(force_clean, check_env=True):
    """
    The version string for the microscope.
    """
    if check_env:
        ci_version_string = os.getenv("CI_VERSION_STRING", None)
        if ci_version_string is not None:
            return ci_version_string
    if not _repo_is_clean():
        if force_clean:
            print("Warning! Git repository is not clean:")
            ret = _run_git(["status", "--porcelain"])
            print(ret)
            sys.exit(1)
        return "Custom"

    tag = _get_commit_tag()
    if _is_release(tag):
        return tag

    commit_hash = _get_commit_hash()
    if commit_hash is None:
        if force_clean:
            sys.exit(1)
        return "Custom"
    return commit_hash[0:7]

def commit_string(force_clean, check_env=True):
    """
    The version string for the microscope.
    """
    if check_env:
        ci_version_string = os.getenv("CI_COMMIT_STRING", None)
        if ci_version_string is not None:
            return ci_version_string
    if not _repo_is_clean():
        if force_clean:
            print("Warning! Git repository is not clean:")
            ret = _run_git(["status", "--porcelain"])
            print(ret)
            sys.exit(1)
        return "#untracked"

    commit_hash = _get_commit_hash()
    if commit_hash is None:
        if force_clean:
            sys.exit(1)
        return "#untracked"
    return commit_hash[0:7]

def _repo_is_clean():
    """
    Returns True if the repo is has no changes.
    Returns False if there are changes in the repo or if Git fails to check.
    """
    ret = _run_git(["status", "--porcelain"])
    if ret is None:
        return False
    # With `--porcelain` the output of `git status` should be empty is repo is clean
    if len(ret) == 0:
        return True

    return False

def _is_release(tag):
    """
    Returns true if the the tag is of the form: v1.3.5
    else returns false
    """
    if tag is None:
        print("No Git tag for this build.")
        return False
    match = re.match(r"^v(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)(?:-(?:beta|rc)[1-9]\d*)?$", tag)

    release = match is not None
    if release:
        print(f"The tag \"{tag}\" is a release tag. This will go on the microscope.")
    else:
        print(f"The tag \"{tag}\" is not a release tag. This won't go on the microscope.")
    return release

def _get_commit_tag():
    """
    Returns the git tag of the current commit.

    If current commit is not tagged returns None
    """
    # First try GitLab CI variable
    ci_tag_var = os.getenv("CI_COMMIT_TAG")
    if ci_tag_var is not None:
        return ci_tag_var
    return _run_git(["desribe", "--tags", "--exact-match"], warn_on_error=False)

def _get_commit_hash():
    """
    Returns commit hash. Will return None if hash cannot be read.
    """
    return _run_git(["log", "-n1", "--format=format:%H"])

def _run_git(git_args, warn_on_error=True):
    """
    Runs git with the input list of arguments. It will return the stdout if
    the command succeeds. On a non-zero exit code it will return None
    """
    args = copy(git_args)
    args.insert(0, "git")
    try:
        ret = subprocess.run(args, capture_output=True, check=True)
    except subprocess.CalledProcessError:
        if warn_on_error:
            print("Warning! Could not read git repository!")
        return None
    return ret.stdout.decode("UTF-8")
