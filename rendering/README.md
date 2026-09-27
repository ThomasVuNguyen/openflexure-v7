# Microscope renders

This folder contains OpenSCAD and Python scripts to render images used for the assembly instructions.  The same renders are also useful for development, as it allows you to see the assembled microscope.  For performance reasons, we use some cached STL files, in particular of hardware (nuts, bolts, etc.) and some particularly complicated microscope components.

## Generating all the renders

`render.py` at the top level of this repository is responsible for creating all the renders, and this is the script that's run in our automated build process.  It has a number of dependencies on command-line tools, which are important for creating all of the images in the documentation but are not necessary if you just want to view the renders in OpenSCAD for development.  For that reason, we've not tested the render script on Windows.  Command-line utilities that are required are:

* `unzip` for extracting zip archives
* `convert` from ImageMagik for image operations
* `inkscape` for rendering SVG files, used to add annotations to some renders
* `openscad` (probably obvious, but worth mentioning here because it is assumed to be on your `PATH`)

# Using renders for development

It's really helpful to check the renders of the microscope as you work on a new or modified part.  The easiest way to do this is first to run `render.py` to generate all the renders, then open the relevant SCAD file in OpenSCAD for an interactive view.  If you're on Windows the build script won't run, so you may find it easier to follow the steps manually:

* Unzip `rendering/librender/hardware.zip` into `rendering/librender` (this contains files generated with NopSCADLib for various hardware).
* Export an STL file of `rendering/librender/rendered_main_body.scad` to `rendering/librender/rendered_main_body.stl`

The "automatic reload and preview" option in OpenSCAD allows you to use an external editor and see an updated preview each time you save, and works for most of the renders.