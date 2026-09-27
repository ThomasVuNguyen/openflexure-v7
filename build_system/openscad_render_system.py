"""
A simple fast-render system for openscad which generated .scad files on the fly and uses
the openscad animation feature to speed up rendering similar frames.

The render system struggles somewhat in Docker due to what appears to be a shared memory
issue. A summary of the rendering strategy and the docker issue is given below:

* OpenSCAD rendering uses OpenGL to create the final render, much of the time consuming
  geometry information is cached when OpenSCAD is open
* When OpenSCAD closes the cached information is lost
* Creating a series of images in OpenSCAD as an animation speeds things up as it can
  used cached geometries for future renders.
* This works fine in testing, but  can fail in Docker during long animations. It seems
  that OpenGL tries to access shared memory in a way that is forbidden by docker, this
  causes OpenSCAD to crash. The underlying cause and how to fix it has eluded us
* However, OpenSCAD exports each frame to a PNG as it is running. This means that if it
  crashes during frame 6 of an 11 render animation the first 5 renders are exported
  correctly.
* This render system detects these failures and re-run the remaining frames.
"""

import subprocess
import shutil
import shlex
import re
import os
import uuid
import sys
from dataclasses import dataclass
from tempfile import gettempdir
from .util import parameters_to_string, get_openscad_exe


@dataclass
class Camera:
    """Data class to handle the OpenSCAD camera parameters"""

    position: list = (0, 0, 0)
    angle: list = (0, 0, 0)
    distance: float = 240

    def as_string(self):
        """
        Combines all the camera paramters into a single string for the openscad cli
        """
        combined = list(self.position) + list(self.angle) + [self.distance]
        return ",".join([str(i) for i in combined])


class ScadRender():
    """
    Simple class to hold the data that defines an openscad render
    """
    def __init__(self, png_file, input_file, scad, imgsize, camera):
        self.png_file = png_file
        self.input_file = input_file
        self.scad = scad
        self.imgsize = tuple(imgsize)
        self.camera = camera

def out_file(hash_name, i):
    """
    Return the output filename givenn the hash of the render job and the frame
    number
    """
    return os.path.join(gettempdir(), f'frame{hash_name}-{i:05}.png')


class RenderSystem():
    """
    Class to handle openscad rendering. All renders and post processing are registered
    with a RenderSystem object. Once all steps are registered run RenderSystem.render()
    This will create the fewest number of OpenSCAD animations (one per each image size)
    allowing fast rendering based on caching.
    """
    def __init__(self):
        self._zip_assets = []
        self._required_stls = []
        self._renders = []
        self._imagemagick_sequences = []
        self._inkscape_annotations = []

    def register_zip_assets(self, zip_file):
        """
        Register a zip file that will be unpacked when RenderSystem.render() is run
        """
        self._zip_assets.append(zip_file)

    def register_render_stl(self, scad_filename, parameters=None):
        """
        Register an stl to be created before when RenderSystem.render() is run
        """
        if parameters is None:
            parameters = {}
        self._required_stls.append({"scad_filename": scad_filename, "parameters":parameters})

    def register_scad_render(self, render):
        """
        Register an openscad render (ScadRender object) to be run when when
        RenderSystem.render() is run.
        """
        self._renders.append(render)

    def register_imagemagick_sequence(self, outfile, input_files):
        """
        Register an image sequence (an output file and a list of input files).
        Each image in the sequence will be appended left to right with imagemagick once
        all openscad renders have been performed
        """
        self._imagemagick_sequences.append((outfile, input_files))

    def register_inkscape_annotation(self, outfile, svg_file):
        """
        Register an inkscape annotation (an output file and an input SVG file).
        The SVG files should have linked PNG files. Once OpenSCAD has produced
        all PNG files, inkscape will be run to add annotations.
        """
        self._inkscape_annotations.append((outfile, svg_file))

    def render(self):
        """
        Run all registered render steps in the following order:
        1. Unpack zip assets
        2. Render pngs with Openscad
        3. Create sequences with imagemagick
        4. Annotate with inkscape
        """
        for zipfile in self._zip_assets:
            subprocess.run(
                ["unzip", "-o", "-d", os.path.dirname(zipfile), zipfile],
                check=True,
            )
        for stl_dict in self._required_stls:
            create_render_stl(stl_dict['scad_filename'], stl_dict['parameters'])
        self._run_openscad()
        for outfile, input_files in self._imagemagick_sequences:
            subprocess.run(
                ['convert'] + input_files + ["+append", outfile],
                check=True,
                capture_output=True
            )
        for outfile, svg_file in self._inkscape_annotations:
            #Note that inkscape does not return sensible error codes. Delete file and check if
            # new file is created
            if os.path.exists(outfile):
                os.remove(outfile)
            command = ["inkscape", f"--export-filename={outfile}", svg_file]
            ret = subprocess.run(command, check=True, capture_output=True)
            if not os.path.exists(outfile):
                std_err = ret.stderr.decode('UTF-8')
                print('\tERROR: Inkscape did not create expected png\n', std_err, file=sys.stderr)
                sys.exit(-1)

    def _run_openscad(self):
        """
        Run openscad for all renders
        """
        tmpdir = gettempdir()
        tmpscad = os.path.join(tmpdir, 'scadfile.scad')
        #note that openscad will append 00000, 00001, etc to the name just before the extension
        sizes = {render.imgsize for render in self._renders}
        for size in sizes:
            renders = [render for render in self._renders if render.imgsize==size]
            while len(renders) > 0:
                scad = _create_scad_for_renders(renders)
                with open(tmpscad, 'w', encoding='utf-8') as scadfile:
                    scadfile.write(scad)

                rerender = run_openscad_animation(tmpscad, renders, size)

                if len(rerender)==len(renders):
                    print("\tERROR: No renders produced for this job. Renders failed!", file=sys.stderr)
                    sys.exit(-1)
                if len(rerender)>0:
                    # Empty lines are not returned in gitlab CI.
                    # Using starts to make this line obvious
                    print(f"\n*\n*\nRe-rendering {len(rerender)} of {len(renders)}\n*\n*\n")
                renders = rerender

def run_openscad_animation(filename, renders, size):
    """
    Run an openscad file which produces an animation. Renders gives a list of the desired name
    for each frame in order.
    """
    executable = get_openscad_exe()
    hash_name = str(uuid.uuid4())
    output_template = os.path.join(gettempdir(), f'frame{hash_name}-.png')
    n_renders = len(renders)
    imgsize_str = ",".join([str(i) for i in size])
    imgsize_arg = f'--imgsize={imgsize_str}'
    #Hardwarnings not in use. See check_openscad_warnings() for more details
    scad_args = ['--animate', str(n_renders), imgsize_arg, '-o', output_template]
    print(f"\nStarting OpenSCAD for images of size {imgsize_str}...\n\n")
    try:
        ret = subprocess.run(
            [executable, filename] + scad_args,
            check=True,
            capture_output=True
        )
        std_err = ret.stderr.decode('UTF-8')
        print(std_err)
    except subprocess.CalledProcessError as error:
        #If there is an error not all images were rendered
        std_err = error.stderr.decode('UTF-8')
        print("*\n*\nSTDERR for failed run:\n")
        print(std_err)
        print("*\n*\nSTDERR end\n")
        check_openscad_warnings(std_err)
        if "X Error of failed request" in std_err:
            print("\n*\n*\nPartial fail due to Docker OpenGL issue. "
                    "Missing renders will be regenerated\n*\n*\n")
        else:
            print("\tERROR: OpenSCAD failed for unknown reason\n", file=sys.stderr)
            sys.exit(-1)

    check_openscad_warnings(std_err)
    return copy_renders(renders, hash_name)

def create_render_stl(filename, scad_parameters):
    """
    Create STLs needed for the rendering from a list of filenames
    """
    parameters = parameters_to_string(scad_parameters)
    # As we use OpenSCAD via subprocess run, not ninja we need to split up
    # the commands into a list of each argument
    parameters = shlex.split(parameters)
    executable = get_openscad_exe()
    stl_name = filename[:-3]+'tl'
    scad_args = ['--hardwarnings'] + parameters + [filename, '-o', stl_name]
    print([executable] + scad_args)
    try:
        ret = subprocess.run([executable] + scad_args, check=True, capture_output=True)
        print(ret.stdout.decode("UTF-8"))
    except subprocess.CalledProcessError as e:
        print("\tERROR: OpenSCAD Error Message:\n", e.stderr, file=sys.stderr)
        sys.exit(-1)

def check_openscad_warnings(std_err):
    """
    Check openscad warnings and throw error if unexpected warning is thrown.

    We cannot use hardwarnings as we change the camera angle during renders. This always
    throws an annoyong warning. See:
    # https://github.com/openscad/openscad/issues/3646
    # https://github.com/openscad/openscad/pull/3660/
    """
    warns = re.findall(r'^WARNING:.*?$', std_err, flags=re.MULTILINE)
    for warn in warns:
        if warn != r'WARNING: Viewall and autocenter disabled in favor of $vp*':
            print("\tERROR: OpenSCAD code generates unexpected warnings:\n", warn, file=sys.stderr)
            sys.exit(-1)

def copy_renders(renders, hash_name):
    """
    Copy the output files from the temp directory to their desired location.
    Return a list of any missing renders so that they can be rerendered
    """
    rerender = []
    for i, render in enumerate(renders):
        frame = out_file(hash_name, i)
        if os.path.exists(frame) and os.path.getsize(frame) > 10:
            copydir = os.path.dirname(render.png_file)
            os.makedirs(copydir, exist_ok=True)
            shutil.copy(frame, render.png_file)
        else:
            rerender.append(render)
    return rerender


def _create_scad_for_renders(renders):
    n_frames = len(renders)
    scad = ''
    inputs = {render.input_file for render in renders}
    for input_file in inputs:
        inputpath = os.path.join(os.getcwd(), input_file)
        scad += f'use <{inputpath}>\n'

    cameras = [render.camera for render in renders]
    pos_str = 'positions = ['
    angle_str = 'angles = ['
    dist_str = 'distances = ['
    for i, camera in enumerate(cameras):
        if i>0:
            pos_str += ',\n             '
            angle_str += ',\n          '
            dist_str += ', '
        pos_str += str(list(camera.position))
        angle_str += str(list(camera.angle))
        dist_str += str(camera.distance)
    pos_str += '];\n'
    angle_str += '];\n'
    dist_str += '];\n'

    scad += pos_str + angle_str + dist_str
    scad += f'frame = round($t*{n_frames});\n'
    scad += '$vpt = positions[frame];\n'
    scad += '$vpr = angles[frame];\n'
    scad += '$vpd = distances[frame];\n'

    scadlines = [render.scad for render in renders]
    render_str = ''
    for i, scadline in enumerate(scadlines):
        if i>0:
            render_str += '}\nelse '
        render_str += f'if (frame=={i})' + '{\n'
        render_str += '    '+scadline+ '\n'
    render_str += '}\n'

    scad += render_str
    return scad
