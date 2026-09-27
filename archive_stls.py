#! /usr/bin/env python3

'''
Short script for making all-stls zipfile. This may want to be moved
into the build-script at a later date.
'''

import zipfile
import os

def main():
    """
    Archive all the stls
    """
    model_dir = os.path.join("docs","models")
    zipfilename = os.path.join("docs","all-stls.zip")
    with zipfile.ZipFile(zipfilename, 'w', zipfile.ZIP_DEFLATED) as zipfile_obj:
        for root, _, files in os.walk(model_dir):
            for filename in files:
                rel_root = os.path.relpath(root, model_dir)
                full_path = os.path.join(root, filename)
                rel_path = os.path.join(rel_root, filename)
                if rel_path.endswith(".stl"):
                    zipfile_obj.write(full_path, rel_path)


if __name__ == "__main__":
    main()
