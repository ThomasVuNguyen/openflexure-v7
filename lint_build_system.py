#! /usr/bin/env python3

"""
Linting for the GitLab CI to run
"""
import sys
from pylint.lint import Run
from colorama import Fore, Style

def main():
    """
    This will exit with a code of 1 for the CI to fail if:
    * There are any warnings, errors, or fatal errors.
    * The pylint score is less than 9.75
    Note this means that it fails if there are TODOs in th code.
    This means that TODOs are to warn you that is something is unfinished, if
    something needs doing in the future and you want to push to master then make an issue.
    """
    output = Run(['build.py', 'render.py', 'build_system/', '--rcfile=.pylintrc'], exit=False)

    clean_exit = True
    linter_threshold = 9.75

    if output.linter.stats.fatal > 0:
        print(Fore.RED
              +f"There are {output.linter.stats.fatal} fatal errors!"
              +Style.RESET_ALL)
        clean_exit = False

    if output.linter.stats.error > 0:
        print(Fore.RED
              +f"There are {output.linter.stats.error} errors!"
              +Style.RESET_ALL)
        clean_exit = False

    if output.linter.stats.warning > 0:
        print(Fore.RED
              +f"There are {output.linter.stats.warning} warning!"
              +Style.RESET_ALL)
        clean_exit = False

    if output.linter.stats.global_note < linter_threshold:
        print(Fore.RED
              +f"The linter score of {output.linter.stats.global_note:.2f}"
              +f" is less than {linter_threshold:.2f}"
              +Style.RESET_ALL)
        clean_exit = False

    if clean_exit:
        print(Fore.GREEN+"\n\n This will pass on the CI!\n\n"+Style.RESET_ALL)
    else:
        print(Fore.RED+"\n\nThis will fail on the CI!\n\n"+Style.RESET_ALL)
        sys.exit(1)

if __name__ == "__main__":
    main()
