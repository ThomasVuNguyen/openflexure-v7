OpenFlexure Microscope: OpenSCAD Sources
========================================

This folder contains the source code that generates the STL files that you print to produce the microscope.

The SCAD files in this top directory, the ``accessories/``, and ``test_pieces/`` sub directories are used to produce STL files to be printed. ``accessories/`` also contains the source for creating some 2D SVGs - mainly the foot prints of the microscope. Most of the SCAD code is in the files under ``libs/``. Most of the files used to produce STLs are just thin wrappers around those library files that pass down some parameters. These parameters can either be hard coded to produce a specific part or can be over written via the ``openscad`` command line. See ``build.py`` in the top directory on the details.

As well as the code for creating actual parts there are additional SCAD files in the ``rendering/`` directory beside this one for generating the images for the building instructions. These of course make use of this directory. See the ``README.md`` file there for details.

Some notes on special files and directories of interest:

* ``libs/microscope_parameters.scad`` defines most of the important variables (parameters) used in the design, for example the size of the microscope, whether or not it has motor lugs, etc. etc. - If you want to produce a microscope with particular settings, this is the file you are most likely to need to modify.
* ``libs/utilities.scad`` contains lots of handy functions for standard shapes and transformations.  It's a slightly random assortment, but they are used in most of the other files and save a fair bit of typing.
* ``libs/compact_nut_seat.scad`` defines the actuator column (the bit that holds the screw, nut and elastic band).  This is one of the most useful files for other projects - e.g. the OpenFlexure Block Stage and Delta Stage use it extensively. It also contains code for nut traps used all over the project.
* ``libs/logos/`` contains logos to be put on the main body and other pieces as DXF and SVG files.
* ``libs/gears.scad`` beside the gears for the actuators it also contians the cutout for the gears and the motors
* ``libs/lib_optics.scad`` contains the underlying code for the two styles of optics modules: The module for RMS objectives and ``lens_spacer`` with ``camera_platform`` for cameras using the camera's own lens.
* ``libs/cameras/`` has the details for various cameras that are used in optics modules.
* ``libs/optics_configurations.scad`` holds the details for objectives and camera lenses
* ``accessories/`` does hold some extras but also the assembly tools
