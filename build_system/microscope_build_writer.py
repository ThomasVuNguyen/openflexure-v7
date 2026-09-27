'''
In this submodule we create a class that writes a "build.ninja" file for building
the microscope STLs.
'''

import os
from ninja import Writer
from .util import parameters_to_string, get_openscad_exe

class NinjaWriter():
    '''
    A simple wrapper around `ninja.Writer` that allowes you to use `with`,
    e.g. `with NinjaWriter() as w:`
    '''
    def __init__(self, build_filename="build.ninja"):
        self._build_filename = build_filename
        self._build_file = None
        self._ninja = None

    def __enter__(self):
        # Create the ninja build file
        self._build_file = open(self._build_filename, "w", encoding='utf-8')
        self._ninja = Writer(self._build_file, width=120)
        return self

    def __exit__(self, *_):
        # Close the Ninja build file
        self._build_file.close()

    def rule(self, *args, **kwargs):
        """
        See ninja.Writer.rule
        """
        self._ninja.rule(*args, **kwargs)

    def build(self, *args, **kwargs):
        """
        See ninja.Writer.rule
        """
        self._ninja.build(*args, **kwargs)


class MicroscopeBuildWriter(NinjaWriter):
    """
    A custom ninja writer for builing the microscope. This handles
    building openscad files
    """
    def __init__(
            self,
            build_dir,
            build_filename
        ):
        super().__init__(build_filename=build_filename)
        self._build_dir = build_dir

    def __enter__(self, *_):
        super().__enter__()
        self._create_rules()
        return self

    def _create_rules(self):
        executable = get_openscad_exe()
        python_path = os.path.dirname(os.path.dirname(__file__))
        self.rule(
            "openscad",
            command=f"{executable} --hardwarnings $parameters $in -o $out -d $out.d",
            depfile="$out.d",
        )
        self.rule(
            "fix_csg",
            command=f"PYTHONPATH={python_path} python -m build_system.fix_csg $in $out",
            depfile="$out.d",
        )
        self.rule(
            "cached_csg_compile",
            command=(
                f"PYTHONPATH={python_path} python -m build_system.cached_csg_compiler $in $out "
                "--hash_file docs/models/dependency_hashes.yaml"
            ),
            depfile="$out.d"
        )

    def openscad(self, output, input_file, parameters=None):
        """
        Invokes ninja task generation using the 'openscad' rule. If
        --generate-stl-options-json is enabled it registers the stl and its
        parameters at this point.

        Absolute paths are used in the Ninja file, to work around a bug in OpenSCAD's CSG export.

        Arguments:
            output {str} -- file path of the output stl file
            input_file {str} -- file path of the input scad file
            parameters {dict} -- parameters passed to openscad using the `-D` switch
        """

        if parameters is None:
            parameters = {}

        if output.endswith((".stl", ".svg")):
            output_csg = output[:-4] + ".csg"
            fixed_csg = output[:-4] + ".fixed.csg"
        else:
            raise ValueError("OpenSCAD rules should output STL files ending with .stl")

        self.build(
            os.path.abspath(os.path.join(self._build_dir, output_csg)),
            rule="openscad",
            inputs=os.path.abspath(os.path.join("openscad/", input_file)),
            variables={"parameters": parameters_to_string(parameters)},
        )
        self.build(
            os.path.abspath(os.path.join(self._build_dir, fixed_csg)),
            rule="fix_csg",
            inputs=os.path.abspath(os.path.join(self._build_dir, output_csg)),
        )
        self.build(
            os.path.abspath(os.path.join(self._build_dir, output)),
            rule="cached_csg_compile",
            inputs=os.path.abspath(os.path.join(self._build_dir, fixed_csg)),
        )
