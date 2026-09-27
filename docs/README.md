# OpenFlexure Microscope Documentation
The documentation is best viewed [on openflexure.org][built_docs].  If you have problems or want to suggest improvements, please [raise an issue] or even better edit the markdown file in this folder and send us a merge request.

The assembly instructions are contained in this folder, in BuildUp-markdown files. BuildUp is a version of markdown that contains metadata about part use. This allows [GitBuilding] to automatically generate the bill of materials. The markdown files themselves will make some sense if you view them directly, but certain things like the bill of materials will have not been counted yet. You're better off using the processed versions of the [latest release][built_docs] on openflexure.org, or the [version built from the latest merge to the `master` branch][master_built_docs].


## Improving the documentation
If you would like to improve the documentation, the easiest way is to use the "edit" or "web IDE" features on GitLab.  Good instructions are super important, so it's really helpful to have suggestions and improvements from people who have built the microscope.  You can fork the repository and work on it locally if you prefer.

## Previewing the assembly instructions: quick-start
Building the documentation is the last step in the pipeline of building the OpenFlexure Microscope, and it depends on the images and STL files generated in the previous steps.  If you want to preview just the instructions, without setting your computer up to do the other builds, it's possible to do this:
* Open a terminal, and change to this folder, e.g. `cd openflexure-microscope/docs`
* Create a new Python virtual environment (using Python 3, which is now usually the default): `python -m venv .venv --prompt "OFM Instructions"
* Activate this virtual environment: 
  - Most OSs: `source .venv/bin/activate`
  - Windows: `.venv/Scripts/activate`
* Install [GitBuilding]: `pip install gitbuilding`
* Go to the [CI-pipelines] page, and find the most recent pipeline on the branch you are interested in (if you're working on a merge request, there is a "pipelines" tab for that merge request, which makes this easier).  Download the artifacts (download drop-down is at the rightmost end of the pipeline's line in the table) for "build:build" and "build:render".  Copy `docs/models` and `docs/renders` into the `docs` folder.
* You should now be able to build the static website with `gitbuilding build-html` or use the interactive editor/server with `gitbuilding serve`

## Viewing and editing the instructions locally

To build and edit these instructions on your local machine you should install [GitBuilding]. However, you may find that many of the images and STL files that the documentation links to are missing.

This repository uses [Git LFS] to store the photos, you will need to install this before cloning the repository (see instructions in out main [README](../README.md)).

Also most of the documentation images are directly generated from OpenSCAD. You can run the render script locally. Or download the render [artifacts from GitLab][CI-jobs].

Similarly the STL file are directly generated from OpenSCAD so you can run our build script locally or download the build [artifacts from GitLab][CI-pipelines].


[CI-pipelines]: https://gitlab.com/openflexure/openflexure-microscope/-/pipelines/
[built_docs]: https://build.openflexure.org/openflexure-microscope/latest
[master_built_docs]: https://build.openflexure.org/openflexure-microscope/master
[Git LFS]: https://git-lfs.github.com/
[GitBuilding]: https://gitbuilding.io
[raise an issue]: https://gitlab.com/openflexure/openflexure-microscope/issues/new
