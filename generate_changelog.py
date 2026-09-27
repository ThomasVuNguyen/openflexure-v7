#!/usr/bin/env python

import argparse
import os
import re
import requests
import subprocess
import semver

endpoint = 'https://gitlab.com'
project_path = 'openflexure/openflexure-microscope'
project_id = '12049246'
# To find project_id for another project, see 
# https://stackoverflow.com/questions/39559689/where-do-i-find-the-project-id-for-the-gitlab-api
# Go to the project page in a browser and open dev tools (Ctrl+Shift+I)
# Paste `document.getElementById('project_id').value` into the console
changelog_fname = "CHANGELOG.md"

def get_releases():
    """Return a list of tagged releases
    
    Currently this returns all tags starting with v and a number that are
    parents of the current commit.
    """
    stdout = subprocess.check_output(["git", "tag", "--merged", "HEAD", "--list", "v*"]).decode("utf8")
    release_semvers = []
    semvers_to_tags = {}
    for line in stdout.split("\n"):
        if line.startswith("v"):
            tag = line.strip()
            if line=="v5.15.2a":
                line="v5.15.2-a"
            try:
                v = semver.VersionInfo.parse(line.lstrip("v ").rstrip())
                release_semvers.append(v)
                semvers_to_tags[str(v)] = tag
            except:
                # the tag was not a release
                print(f"{line.strip()} was not a release.")
                pass
    # Use semantic versioning to sort the releases in order
    release_semvers.sort()
    # Convert them back into the tags for return
    return [semvers_to_tags[str(v)] for v in release_semvers]

_merge_request_data = None
def get_merge_requests():
    global _merge_request_data
    if _merge_request_data:
        return _merge_request_data
    print("Retrieving MR data from GitLab", end="")
    r = requests.get(f"{endpoint}/api/v4/projects/{project_id}/merge_requests?state=merged&scope=all")
    mrs = r.json()
    print(".", end="")
    while "next" in r.links:
        r = requests.get(r.links['next']['url'])
        mrs += r.json()
        print(".", end="")
    print()
    _merge_request_data = mrs
    return mrs

_mr_by_sha = None
def generate_mr_by_sha_dict():
    global _mr_by_sha
    if _mr_by_sha:
        return _mr_by_sha
    mrs = get_merge_requests()
    _mr_by_sha = {}
    for mr in mrs:
        if mr['merge_commit_sha']:
            _mr_by_sha[mr['merge_commit_sha']] = mr
    return _mr_by_sha

def get_mr_for_commit(sha):
    mr_by_sha_dict = generate_mr_by_sha_dict()
    return mr_by_sha_dict.get(sha)


def get_commits_between_refs(start, end):
    command = ["git", "log", "--merges", "--pretty=format:%H", end]
    if start:
        command.append("^"+start)  # exclude commits before start
    commits = subprocess.check_output(command).decode("utf8")
    return [c.strip() for c in commits.split("\n")]

def get_mrs_for_commits(commits):
    mrs = []
    for c in commits:
        mr = get_mr_for_commit(c)
        if mr:
            mrs.append(mr)
    return mrs
    

def get_date_for_tag(tag):
    return subprocess.check_output(["git", "log", "-1", "--pretty=tformat:%ad", "--date=short", tag]).decode("utf8").strip()

def describe_merge_request(mr):
    return f"* [!{mr['iid']}]({mr['web_url']}): {mr['title']}\n"

def describe_mrs_between_tags(start, end, head_tag="HEAD"):
    new_text = ""
    date = get_date_for_tag(end)
    end_name = head_tag if end == "HEAD" else end
    new_text += f"## [{end_name}]({endpoint}/{project_path}/compare/{start}..{end_name}/) ({date})\n\n"
    commits = get_commits_between_refs(start, end)
    mrs = get_mrs_for_commits(commits)
    for mr in mrs:
        new_text += describe_merge_request(mr)
    new_text += "\n"
    return new_text

def find_releases_in_changelog():
    changelog_releases = {}
    with open(changelog_fname, "r") as f:
        for i, l in enumerate(f):
            m = re.match(r"^## \[(HEAD|v[^\]]+)\]", l)
            if m:
                changelog_releases[m.group(1)] = i
    return changelog_releases


if __name__ == "__main__":
    p = argparse.ArgumentParser(description="Generate or update a changelog using GitLab merge request data.")
    p.add_argument("head_tag", help="The name of the tag you will assign to this release.", default="HEAD", nargs="?")
    p.add_argument("--dry_run", help="Don't modify the changelog and print what would be added", action="store_true")
    args = p.parse_args()
    print("Generating changelog")
    if not os.path.exists(changelog_fname):
        mrs = set()
        releases = get_releases()
        releases.reverse()  # Start with the newest release
        print(f"Generating changelog for releases: HEAD, {', '.join(releases)}")
        with open(changelog_fname, "w") as f:
            for end, start in zip(["HEAD"] + releases, releases + [None]):
                f.write(describe_mrs_between_tags(start, end, head_tag=args.head_tag))
    else:
        # Find the last tagged release
        with open(changelog_fname, "r") as f:
            changelog = f.readlines()
        changelog_releases = find_releases_in_changelog()
        releases = get_releases()
        releases.reverse()  # new at the start, old at the end
        missing_releases = []
        latest_release_in_changelog = None
        for r in releases[:-1]:  # NB the oldest release won't show up, so we ignore it here.
            print("release", r)
            if r not in changelog_releases:
                missing_releases.append(r)
            elif latest_release_in_changelog is None:
                latest_release_in_changelog = r
        
        print(f"{changelog_fname} exists, adding releases {['HEAD'] + missing_releases}.")
        new_text = ""
        for end, start in zip(["HEAD"] + missing_releases, missing_releases + [latest_release_in_changelog]):
            new_text += describe_mrs_between_tags(start, end, head_tag=args.head_tag)
        if args.dry_run:
            print(new_text)
        else:
            # Insert this just before the latest tag, so first we have to find the latest tag
            with open(changelog_fname, "r") as f:
                changelog = f.readlines()
            if "HEAD" in changelog_releases:
                # Remove the "HEAD" section
                del changelog[changelog_releases['HEAD']:changelog_releases[latest_release_in_changelog]]
            with open(changelog_fname, "w") as f:
                f.write(new_text)
                f.writelines(changelog)
            print(f"Changelog file `{changelog_fname}` updated.")
