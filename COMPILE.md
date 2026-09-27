# OpenFlexure Microscope: Compiling from source

The microscope is modelled using OpenSCAD.  This means there's a collection of scripts that, when run, generate STL files that you can then print.  These are archived on [openflexure.org]  The best way to get hold of the latest STL files is to generate them yourself.  To do this, you will need [OpenSCAD](http://www.openscad.org/) (available for Windows, Mac and Linux).  The simplest way to build all the necessary STL files is to use the build script in this repository, which uses Python and Ninja.

To set up the build system:
  * Change directory to the root folder of this repository
  * [Optional] create a virtual environment so we don't clutter your system Python installation: ``python3 -m virtualenv .venv`` and activate that environment with ``source .venv/bin/activate``
  * Run ``pip3 install -r requirements.txt`` to install Ninja
You can then build the project by running ``python ./build.py`.

This will generate a Ninja build file and run it to compile the files and put them in the ``builds/`` directory.  You can also build the output files one at a time with ``python ./build.py builds/feet.stl`` where ``feet.stl`` is replaced with the output filename of the file you want to build.  NB some of the OpenSCAD files are built several times with different options, so you should specify the *output* STL filename rather than the OpenSCAD file to avoid ambiguity.

## OpenSCAD command line
You'll need to make sure OpenSCAD is in your executable path so the build script can [run it from the command line](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment).  This is probably the case on Linux, but on Windows I just ran ``PATH="$PATH:/c/Program Files/OpenSCAD/"`` before running the build script.  A nicer solution is to use "Windows Subsystem Linux" and this is what all the developers of the microscope currently do, when they are working on Windows.

[openflexure.org]: https://openflexure.org/projects/microscope/
