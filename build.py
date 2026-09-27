#!/usr/bin/env python3

'''
This is the main build script for the OpenFlexure Microscope. Run
`./build.py -h` to see options.
'''

import argparse
import os
import sys
import shutil
import subprocess
try:
    from ninja import BIN_DIR
except ModuleNotFoundError:
    print("ERROR: `ninja` not found. Please install dependencies with `pip install -r requirements.txt`.")
    sys.exit(-1)
from build_system.microscope_build_writer import MicroscopeBuildWriter
from build_system.util import version_string, commit_string

BUILD_DIR = "docs/models"

#Some constants used in generating lists of parts

CAMERAS = ["picamera_2", "m12", "logitech_c270"]

# These are the optics configuration of objective and tube lens pairs.
# Currently we only support the F50D13 option in the offical build.
# "rms_f40d16" not built as standard now as we do not regularly check it
# but is still in OpenSCAD incase needed.
RMS_OPTICS = ["rms_f50d13"]
INF_RMS_OPTICS = ["rms_infinity_f50d13"]

# These are (camera, lens) tuples
# The when building the lens is assumed to be the lens of the camera!
PLATFORM_OPTICS_MODULE_OPTIONS = [("picamera_2", "pilens")]

def write_ninja_file(build_dir):
    """
    Register all files to be built. Some files options are generated in other
    functions. Once this function is complete a ninja file will have been
    written with all STLs that need generating.
    """

    with MicroscopeBuildWriter(build_dir, "build.ninja") as writer:
        version_str = version_string(args.force_clean)
        commit_str = commit_string(args.force_clean)
        print(f'Compiling microscope version "{version_str}", at commit "{commit_str}"')

        # The main body
        writer.openscad(
            "main_body.stl", 
            "main_body.scad", 
            {"VERSION_STRING": version_str, "HASH": commit_str})
        writer.openscad(
            "main_body_manual.stl",
            "main_body_manual.scad",
            {"VERSION_STRING": version_str, "HASH": commit_str}
        )

        # Bases and electronics adapters
        generate_stand_with_pi(writer)
        writer.openscad("microscope_stand_no_pi.stl", "microscope_stand_no_pi.scad")
        generate_nano_converter_plate(writer)
        writer.openscad("nano_converter_plate_gripper.stl", "nano_converter_plate_gripper.scad")
        writer.openscad("simple_post_stand.stl","simple_post_stand.scad")

        # Standard components
        writer.openscad("feet.stl", "feet.scad")
        writer.openscad("sample_clips.stl", "sample_clips.scad")
        generate_cable_tidies(writer)
        generate_gears(writer)

        # Optics modules and associated components
        generate_rms_optics_modules(writer)
        generate_platform_optics_modules(writer)
        writer.openscad("picamera_2_cover.stl", "picamera_2_cover.scad")

        # Standard illumination components
        writer.openscad("condenser.stl", "condenser.scad")
        writer.openscad("condenser_lid.stl", "condenser_lid.scad")
        writer.openscad("condenser_board_spacer.stl", "condenser_board_spacer.scad")
        writer.openscad("condenser_aperture.stl", "condenser_aperture.scad")
        writer.openscad("illumination_dovetail.stl", "illumination_dovetail.scad")
        writer.openscad("illumination_thumbscrew.stl", "illumination_thumbscrew.scad")

        # Assembly tools
        writer.openscad("actuator_assembly_tools.stl", "actuator_assembly_tools.scad")
        writer.openscad("lens_tool.stl", "lens_tool.scad")
        writer.openscad("picamera_2_gripper.stl", "accessories/picamera_2_gripper.scad")
        writer.openscad("picamera_2_lens_removal_tool.stl", "accessories/picamera_2_lens_removal_tool.scad")
        writer.openscad("gear_tools.stl", "gear_tools.scad")
        writer.openscad("accessories/gear_tools_ratios.stl", "gear_tools_ratios.scad")

        # Test pieces
        writer.openscad("nut_trap_test.stl", "test_pieces/nut_trap_test.scad")
        writer.openscad("leg_test.stl", "test_pieces/leg_test.scad")
        writer.openscad("rms_thread.stl", "test_pieces/rms_thread.scad")

        # Special illumination components
        writer.openscad("condenser_led_holder.stl", "condenser_led_holder.scad")
        writer.openscad("fl_cube.stl", "fl_cube.scad")
        writer.openscad("reflection_illuminator.stl", "reflection_illuminator.scad")
        writer.openscad("led_array_holder.stl", "led_array_holder.scad")

        # Upright microscope components
        writer.openscad("separate_z_actuator.stl", "separate_z_actuator.scad")
        writer.openscad("separate_z_actuator_manual.stl", "separate_z_actuator_manual.scad")
        writer.openscad("upright_condenser.stl", "upright_condenser.scad")
        writer.openscad("upright_condenser_platform.stl", "upright_condenser_platform.scad")
        writer.openscad("upright_feet.stl", "upright_feet.scad")
        writer.openscad("foot_cap.stl", "foot_cap.scad")
        writer.openscad("upright_z_actuator_mount.stl", "upright_z_actuator_mount.scad")
        writer.openscad("accessories/upright_z_actuator_mount_5mm_sample.stl",
                        "accessories/upright_z_actuator_mount_5mm_sample.scad")
        writer.openscad("accessories/upright_z_actuator_mount_10mm_sample.stl",
                        "accessories/upright_z_actuator_mount_10mm_sample.scad")
        # upright_large_gears are built by generate_gears()

        # Misc components
        writer.openscad("thumbwheels.stl", "thumbwheels.scad")
        writer.openscad("slide_riser.stl", "slide_riser.scad")
        writer.openscad(
            "accessories/actuator_tension_band.stl",
            "accessories/actuator_tension_band.scad"
        )
        writer.openscad(
            "accessories/actuator_drilling_jig.stl",
            "accessories/actuator_drilling_jig.scad"
        )
        writer.openscad(
            "accessories/slide_box_16.stl",
            "accessories/slide_box.scad",
            {"N_SLIDES": 16}
        )
        writer.openscad(
            "accessories/slide_box_24.stl",
            "accessories/slide_box.scad",
            {"N_SLIDES": 24}
        )
        writer.openscad(
            "accessories/1_inch_disc_holder.stl",
            "accessories/1_inch_disc_holder.scad")
        writer.openscad(
            "accessories/bottom_of_main_body.svg",
            "accessories/bottom_of_main_body.scad")
        writer.openscad(
            "accessories/footprint_pocket.svg",
            "accessories/footprint_pocket.scad")
        writer.openscad(
            "accessories/footprint.svg",
            "accessories/footprint.scad")

        # extra platform optics **TODO make this build automatically with the
        # generate_platform_optics_modules below
        writer.openscad("camera_platform_c270.stl", "camera_platform_c270.scad")
        writer.openscad("lens_spacer_c270.stl", "lens_spacer_c270.scad")
        writer.openscad("c270_camera_backshell.stl", "c270_backshell.scad")
        writer.openscad("camera_platform_arducam_b0196.stl", "camera_platform_b0196.scad")
        writer.openscad("lens_spacer_arducam_b0196.stl", "lens_spacer_b0196.scad")

def generate_rms_optics_modules(writer):
    """
    Add all rms optics modules to the ninja build
    """
    for camera in CAMERAS:
        for optics in RMS_OPTICS + INF_RMS_OPTICS:
            for beamsplitter in [True, False]:
                bs_text = "_beamsplitter" if beamsplitter else ""
                output = f"optics_{camera}_{optics}{bs_text}.stl"

                parameters = {"OPTICS": optics,
                              "CAMERA": camera,
                              "BEAMSPLITTER": beamsplitter}

                writer.openscad(output, "rms_optics_module.scad", parameters)

def generate_platform_optics_modules(writer):
    """
    Add both the lens spacers and the camera platforms to the ninja build
    """
    # Note! As there is only one platform optics module option
    # There are no input parameters to OpenSCAD This will need to
    # be fixed as other options are added.
    for camera, optics in PLATFORM_OPTICS_MODULE_OPTIONS:
        writer.openscad(f"camera_platform_{camera}_{optics}.stl", "camera_platform.scad")
        writer.openscad(f"lens_spacer_{camera}_{optics}.stl", "lens_spacer.scad")

def generate_stand_with_pi(writer):
    """
    Add two heights of stand with pi to the ninja build
    """

    writer.openscad("microscope_stand.stl", "microscope_stand.scad", {"TALL_BUCKET_BASE": False})
    writer.openscad(
        "microscope_stand_tall.stl",
        "microscope_stand.scad",
        {"TALL_BUCKET_BASE": True}
    )

    # Also generate the tray for the pi itself
    for pi in [3,4]:
        for sanga in ["v0.3", "stack_8.5mm", "stack_11mm"]:
            output = f"electronics_drawer-pi{pi}_sanga_{sanga}.stl"

            parameters = {"PI_VERSION": pi,
                          "SANGA_VERSION": sanga}

            writer.openscad(output, "electronics_drawer.scad", parameters)

def generate_nano_converter_plate(writer):
    """
    Add nano converter plates to go over Pi3 or Pi4 to the ninja build
    """
    for pi in [3,4]:
        output = f"nano_converter_plate-pi{pi}.stl"

        parameters = {"PI_VERSION": pi}

        writer.openscad(output, "nano_converter_plate.scad", parameters)

def generate_cable_tidies(writer):
    """
    Add cable tidies for inverted and upright to the ninja build
    """
    for upright in [True, False]:
        version = "upright_" if upright else ""
        output = f"{version}cable_tidies.stl"

        parameters = {"UPRIGHT": upright}

        writer.openscad(output, "cable_tidies.scad", parameters)

def generate_gears(writer):
    for ratio in [16/20, 18/18, 2]:
        if (ratio == 2):
            output_small = "small_gears.stl"
            output_large = "large_gears.stl"
            output_upright = "upright_large_gears.stl"
        else:
            output_small = f"accessories/small_gears_ratio_{ratio:.2f}.stl"
            output_large = f"accessories/large_gears_ratio_{ratio:.2f}.stl"
            output_upright = f"accessories/upright_large_gears_ratio_{ratio:.2f}.stl"
           
        writer.openscad(output_small, "small_gears.scad", {"RATIO": ratio})
        writer.openscad(output_large, "large_gears.scad", {"RATIO": ratio})
        writer.openscad(output_upright, "upright_large_gears.scad", {"RATIO": ratio})

def copy_extra_stls(build_dir, extras_dir):
    """
    Copy extra STLs to output directory
    """

    for root, dirs, files in os.walk(extras_dir):
        hidden_dirs = [subdir for subdir in dirs if subdir.startswith('.')]
        for hidden_dir in hidden_dirs:
            dirs.remove(hidden_dir)
        for name in files:
            if name.endswith('.stl'):
                stl_file = os.path.join(root, name)
                rel_path = os.path.relpath(stl_file, extras_dir)
                dest_dir = 'community-contributed-stls'
                desitination = os.path.join(build_dir, dest_dir, rel_path)
                os.makedirs(os.path.dirname(desitination), exist_ok=True)
                shutil.copyfile(stl_file, desitination)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Run the OpenSCAD build for the Openflexure Microscope."
    )
    parser.add_argument(
        "--include-extra-files",
        help="Copy over STL files from openflexure-microscope-extra/ into the builds/ folder.",
        action="store_true",
    )
    parser.add_argument(
        "--force-clean",
        help="Ensures that the repo is clean before compiling",
        action="store_true",
    )

    # we get the flags above and will pass the rest to ninja
    args, ninja_args = parser.parse_known_args()

    write_ninja_file(BUILD_DIR)
    # Include extra STL files
    if args.include_extra_files:
        copy_extra_stls(BUILD_DIR, extras_dir = 'openflexure-microscope-extra')
    # Run the "ninja.build" file we just created, to generate STLs
    try:
        subprocess.run([os.path.join(BIN_DIR, "ninja")] + ninja_args, check=True)
    except subprocess.CalledProcessError as e:
        print("\tERROR: Ninja build failed", file=sys.stderr)
        sys.exit(-1)
