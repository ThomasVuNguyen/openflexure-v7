#!/usr/bin/env python3
"""
This is used to write version string on CI int a .env file.
It is needed due to a weird LFS bug in GitLab
https://gitlab.com/gitlab-org/gitlab/-/issues/325299
"""
from build_system.util import version_string, commit_string

version_string = version_string(force_clean=True, check_env=False)
commit_string = commit_string(force_clean=True, check_env=False)
with open('build.env', 'w', encoding="utf-8") as file_obj:
    file_obj.write(f"CI_VERSION_STRING={version_string}\n")
    file_obj.write(f"CI_COMMIT_STRING={commit_string}")
