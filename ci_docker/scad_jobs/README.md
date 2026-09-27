# Docker image for the SCAD jobs.

This is a prebuild docker image for running the OpenFlexure Microscope CI jobs that need OpenSCAD installed.

It should only need rebuilding if:

* We want to update the OS (Ubuntu 22.04)
* We want to change the OpenSCAD version, or any other packages installed
* We change the python packages in `requirements.txt`

## How to rebuild

Make sure you are in this directory and then run:

    docker build -t registry.gitlab.com/openflexure/openflexure-microscope/scad-job -f Dockerfile ../..

## How to push rebuilt image

Create a GitLab Token with countainer registry write access (`write_registry`), and copy it to the clipboard

Run:

    TOKEN=<token>
    echo "$TOKEN" | docker login registry.gitlab.com -u <username> --password-stdin

You should now be logged into docker and able to run:

    docker push registry.gitlab.com/openflexure/openflexure-microscope/scad-job

