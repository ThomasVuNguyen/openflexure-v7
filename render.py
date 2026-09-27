#!/usr/bin/env python3

"""
This is the main script to create the renderings used in the documentation.
"""

# Function docstrings are fairly redundant in this file
# pylint: disable=missing-function-docstring

import argparse
from build_system.openscad_render_system import RenderSystem, ScadRender, Camera
from build_system.util import version_string, commit_string

def register_rms_optics_assembly(rendersystem):
    input_file = "rendering/rms_optics_assembly.scad"
    cameras = []
    imgsizes = []
    scad_lines = []
    output_files = []

    for frame in [1, 2, 3]:
        cameras.append(Camera(position=[29, 0, 59], angle=[69, 0, 90], distance=290))
        imgsizes.append([1000, 2000])
        output_files.append(f"rendering/annotations/optics_assembly_tube_lens{frame}.png")
        scad_lines.append(f"render_rms_assembly({frame});")

    camera_png_files = []
    for frame in [1, 2]:
        cameras.append(Camera(position=[7, -14, -21], angle=[247, 0, 211], distance=250))
        imgsizes.append([1200, 2000])
        output_files.append(f"docs/renders/optics_assembly_camera{frame}.png")
        camera_png_files.append(output_files[-1])
        scad_lines.append(f"render_rms_assembly({frame+3});")

    objective_png_files = []
    for frame in [1, 2]:
        cameras.append(Camera(position=[2, 2, 25], angle=[55, 0, 90], distance=290))
        imgsizes.append([1200, 2000])
        output_files.append(f"docs/renders/optics_assembly_objective{frame}.png")
        objective_png_files.append(output_files[-1])
        scad_lines.append(f"render_rms_assembly({frame+5});")

    screw_png_files = []
    for frame in [1, 2, 3]:
        cameras.append(Camera(position=[-6.5, 14, 38], angle=[60, 0, 243], distance=290))
        imgsizes.append([1000, 2000])
        output_files.append(f"docs/renders/optics_assembly_screw{frame}.png")
        screw_png_files.append(output_files[-1])
        scad_lines.append(f"render_rms_assembly({frame+7});")

    ribbon_png_files = []
    for frame in [1, 2, 3]:
        cameras.append(Camera(position=[12.5, -1, 15], angle=[230, 0, 24], distance=325))
        imgsizes.append([1200, 2000])
        output_files.append(f"docs/renders/optics_assembly_ribbon{frame}.png")
        ribbon_png_files.append(output_files[-1])
        scad_lines.append(f"render_rms_assembly({frame+10});")

    for i, output_file in enumerate(output_files):
        render = ScadRender(output_file, input_file, scad_lines[i], imgsizes[i], cameras[i])
        rendersystem.register_scad_render(render)

    rendersystem.register_imagemagick_sequence(
        "docs/renders/optics_assembly_camera.png",
        camera_png_files
    )
    rendersystem.register_imagemagick_sequence(
        "docs/renders/optics_assembly_objective.png",
        objective_png_files
    )
    rendersystem.register_imagemagick_sequence(
        "docs/renders/optics_assembly_screw.png",
        screw_png_files
    )
    rendersystem.register_imagemagick_sequence(
        "docs/renders/optics_assembly_ribbon.png",
        ribbon_png_files
    )
    rendersystem.register_inkscape_annotation(
        "docs/renders/optics_assembly_tube_lens.png",
        "rendering/annotations/annotate_optics_assembly_tube_lens.svg"
    )

def register_low_cost_optics_assembly(rendersystem):
    input_file = "rendering/low_cost_optics_assembly.scad"
    for camera_type in ["pi_camera", "c270"]:
        lens_type = "c270_lens" if camera_type=="c270" else "pi_lens"
        cameras = []
        imgsizes = []
        scad_lines = []
        output_files = []

        for frame in [1, 2, 3]:
            cameras.append(Camera(position=[29, 0, 59], angle=[69, 0, 90], distance=290))
            imgsizes.append([1000, 2000])
            output_files.append(f'rendering/annotations/low_cost_optics_assembly_tube_lens_{lens_type}{frame}.png')
            scad_lines.append(f'render_low_cost_assembly({frame}, camera_type = "{camera_type}");')

        camera_png_files = []
        # frame 4,5
        for frame in [1, 2]:
            cameras.append(Camera(position=[1, -8.5, 32], angle=[64, 0, 200], distance=300))
            imgsizes.append([1200, 2000])
            output_files.append(f'docs/renders/low_cost_optics_assembly_camera_{lens_type}{frame}.png')
            camera_png_files.append(output_files[-1])
            scad_lines.append(f'render_low_cost_assembly({frame+3}, camera_type = "{camera_type}");')

        screw_png_files = []
        # frame 6,7,8
        for frame in [1, 2, 3]:
            cameras.append(Camera(position=[-11, 19, 33], angle=[71, 0, 106], distance=192))
            imgsizes.append([1000, 2000])
            output_files.append(f'docs/renders/low_cost_optics_assembly_screw_{lens_type}{frame}.png')
            screw_png_files.append(output_files[-1])
            scad_lines.append(f'render_low_cost_assembly({frame+5}, camera_type = "{camera_type}");')

        ribbon_png_files = []
        # frame 9,10,11
        if camera_type == "pi_camera":
            for frame in [1, 2, 3]:
                cameras.append(Camera(position=[-7, -7, 40.5], angle=[54, 0, 90], distance=237))
                imgsizes.append([1200, 2000])
                output_files.append(f'docs/renders/low_cost_optics_assembly_ribbon_{lens_type}{frame}.png')
                ribbon_png_files.append(output_files[-1])
                scad_lines.append(f'render_low_cost_assembly({frame+8}, camera_type = "{camera_type}");')

        c270_screw_png_files = []
        # frame 12,13
        if camera_type == "c270":
            for frame in [1, 2]:
                cameras.append(Camera(position=[-10, -12, 50], angle=[245, 0, 240], distance=180))
                imgsizes.append([2400, 2000])
                output_files.append(f'docs/renders/low_cost_optics_assembly_c270_extra_screw{frame}.png')
                c270_screw_png_files.append(output_files[-1])
                scad_lines.append(f'render_low_cost_assembly({frame+11}, camera_type = "{camera_type}");')

        c270_backshell_png_files = []
        # frame 14,15,16
        if camera_type == "c270":
            for frame in [1, 2, 3]:
                cameras.append(Camera(position=[-20, -10, 36], angle=[256,0,240], distance=240))
                imgsizes.append([2400, 2000])
                output_files.append(f'docs/renders/low_cost_optics_assembly_c270_backshell{frame}.png')
                c270_backshell_png_files.append(output_files[-1])
                scad_lines.append(f'render_low_cost_assembly({frame+13}, camera_type = "{camera_type}");')

        for i, output_file in enumerate(output_files):
            render = ScadRender(output_file, input_file, scad_lines[i], imgsizes[i], cameras[i])
            rendersystem.register_scad_render(render)

        rendersystem.register_inkscape_annotation(
            f'docs/renders/low_cost_optics_assembly_{lens_type}.png',
            f'rendering/annotations/annotate_optics_assembly_{lens_type}.svg'
        )
        rendersystem.register_imagemagick_sequence(
            f'docs/renders/low_cost_optics_assembly_camera_{lens_type}.png',
            camera_png_files
        )
        rendersystem.register_imagemagick_sequence(
            f'docs/renders/low_cost_optics_assembly_screw_{lens_type}.png',
            screw_png_files
        )
        if camera_type == "pi_camera":
            rendersystem.register_imagemagick_sequence(
                "docs/renders/low_cost_optics_assembly_ribbon_pi_lens.png",
                ribbon_png_files
            )

def register_extra_low_cost_optics_assembly(rendersystem):
    input_file = "rendering/low_cost_optics_assembly.scad"
    for camera_type in ["pi_camera", "c270"]:
        lens_type = "c270_lens" if camera_type=="c270" else "pi_lens"
        camera = Camera(position=[29, 0, 59], angle=[69, 0, 90], distance=290)
        imgsize = [1000, 2000]

        for frame in [1, 2, 3]:
            png_directory = "rendering/annotations" if frame==2 else "docs/renders"
            output_file = f'{png_directory}/low_cost_optics_assembly_lens_spacer_{lens_type}{frame}.png'
            scad = f'render_low_cost_assembly({frame}, camera_type = "{camera_type}");'
            render = ScadRender(output_file, input_file, scad, imgsize, camera)
            rendersystem.register_scad_render(render)

        rendersystem.register_inkscape_annotation(
            f'docs/renders/low_cost_optics_assembly_lens_spacer_{lens_type}2.png',
            f'rendering/annotations/annotate_optics_assembly_{lens_type}_small.svg'
        )


def register_condenser_assembly(rendersystem):
    input_file = "rendering/condenser_assembly.scad"
    camera = Camera(position=[29, 0, 59], angle=[69, 0, 90], distance=290)
    imgsize = [1000, 2000]

    for frame in [1, 2, 3]:
        scad = f"assemble_condenser({frame});"
        output_file = f"rendering/annotations/optics_assembly_condenser_lens{frame}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)
    rendersystem.register_inkscape_annotation(
        "docs/renders/optics_assembly_condenser_lens.png",
        "rendering/annotations/annotate_optics_assembly_condenser_lens.svg"
    )

    camera = Camera(position=[0, 8, 15.5], angle=[62, 0, 130], distance=237)
    imgsize = [2400, 2000]
    for frame in [4, 5, 6]:
        scad = f"assemble_condenser({frame});"
        output_file = f"docs/renders/assemble_condenser_thumbscrew{frame-3}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

    camera = Camera(position=[0, 8, 30], angle=[62, 0, 130], distance=137)
    imgsize = [2400, 2000]
    for frame in [7, 8, 9, 10]:
        scad = f"assemble_condenser({frame});"
        output_file = f"docs/renders/mount_led_board{frame-6}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)
    for frame in [11, 12]:
        scad = f"assemble_condenser({frame});"
        output_file = f"docs/renders/mount_led_cable{frame-10}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)
    camera = Camera(position=[0, 8, 30], angle=[62, 0, 130], distance=237)
    for frame in [13, 14, 15, 16]:
        scad = f"assemble_condenser({frame});"
        output_file = f"docs/renders/mount_condenser_lid{frame-12}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_upright_condenser_assembly(rendersystem):
    input_file = "rendering/upright_condenser_assembly.scad"
    camera = Camera(position=[29, 0, 59], angle=[69, 0, 90], distance=290)
    imgsize = [1000, 2000]

    for frame in [1, 2, 3]:
        scad = f"upright_assemble_condenser({frame});"
        output_file = f"rendering/annotations/upright_optics_assembly_condenser_lens{frame}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)
    rendersystem.register_inkscape_annotation(
        "docs/renders/upright_optics_assembly_condenser_lens.png",
        "rendering/annotations/upright_annotate_optics_assembly_condenser_lens.svg"
    )

    ## No thumbscrew for upright. Frames [4,5,6] not used so
    ## frame numbers match in upright and inverted condenser instructions

    camera = Camera(position=[0, 8, 30], angle=[62, 0, 130], distance=137)
    imgsize = [2400, 2000]
    for frame in [7, 8, 9, 10]:
        scad = f"upright_assemble_condenser({frame});"
        output_file = f"docs/renders/upright_mount_led_board{frame-6}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)
    for frame in [11, 12]:
        scad = f"upright_assemble_condenser({frame});"
        output_file = f"docs/renders/upright_mount_led_cable{frame-10}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)
    camera = Camera(position=[0, 8, 30], angle=[62, 0, 130], distance=237)
    for frame in [13, 14, 15, 16]:
        scad = f"upright_assemble_condenser({frame});"
        output_file = f"docs/renders/upright_mount_condenser_lid{frame-12}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)


def register_workaround_5mm_led(rendersystem):
    input_file = "rendering/workaround_5mm_led.scad"
    camera = Camera(position=[0, 0, 0], angle=[42, 0, 313], distance=137)
    imgsize = [2400, 2000]
    for frame in [1, 2, 3, 4, 5]:
        scad = f"workaround_5mm_led({frame});"
        output_file = f"docs/renders/workaround_5mm_led{frame}.png"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)


def register_optics_assembled(rendersystem):
    input_file = "rendering/optics_assembly.scad"
    camera = Camera(position=[30, 5, 60], angle=[90, 0, 110], distance=440)
    output_file = "docs/renders/optics_assembled.png"
    imgsize = [1200, 2400]
    scad = "cutaway_optics();"
    render = ScadRender(output_file, input_file, scad, imgsize, camera)
    rendersystem.register_scad_render(render)


def register_band(rendersystem):
    input_file = "rendering/band_insertion_cutaway.scad"
    camera = Camera(position=[-13, 13, -30], angle=[115, 0, 216], distance=340)
    imgsize = [2000, 2400]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for frame in [1, 2, 3, 4, 5, 6]:
            output_file = f"docs/renders/band_instruction{body}{frame}.png"
            scad = f"render_band_insertion(band_insertion_frame_parameters({frame}),{manual});"
            render = ScadRender(output_file, input_file, scad, imgsize, camera)
            rendersystem.register_scad_render(render)

def register_band_tool_assembly(rendersystem):
    input_file = "rendering/band_tool_assembly.scad"
    camera = Camera(position=[-6, 6, 46], angle=[75, 0, 235], distance=250)
    imgsize = [1200, 2400]
    png_files = []

    for frame in [1, 2]:
        output_file = f"docs/renders/band_tool_assembly{frame}.png"
        scad = f"render_band_tool_assembly({frame});"
        png_files.append(output_file)
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)


def register_brim_and_ties(rendersystem):
    input_file = "rendering/brim_and_ties.scad"
    cameras = [
        Camera(position=[9.7, 33, 6], angle=[45.2, 0, 315.2], distance=361),
        Camera(position=[-4, 21, 29], angle=[206, 0, 177], distance=450),
        Camera(position=[-2, 48, -12], angle=[60, 0, 4], distance=320),
    ]
    imgsize = [2400, 2400]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for i, camera in enumerate(cameras):
            output_file = f"docs/renders/brim_and_ties{body}{i+1}.png"
            scad = f"render_brim_and_ties({i+1}, {manual});"
            render = ScadRender(output_file, input_file, scad, imgsize, camera)
            rendersystem.register_scad_render(render)

def register_brim_and_ties_separate_z_actuator(rendersystem):
    input_file = "rendering/brim_and_ties_separate_z_actuator.scad"
    cameras = [
        Camera(position=[-4, 37, 34], angle=[57, 0, 315], distance=264),
        Camera(position=[0, 42, 17], angle=[206, 0, 180], distance=264),
    ]
    imgsize = [2400, 2400]
    for i, camera in enumerate(cameras):
        output_file = f"docs/renders/brim_and_ties_separate_z{i+1}.png"
        scad = f"render_brim_and_ties_separate_z_actuator({i+1});"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_prepare_separate_z_actuator(rendersystem):
    input_file = "rendering/prepare_separate_z_actuator.scad"
    cameras = [
        Camera(position=[10, 2, -15], angle=[48, 0, 190], distance=240),
        Camera(position=[10, 2, -15], angle=[48, 0, 190], distance=240),
        Camera(position=[10, 2, -15], angle=[48, 0, 190], distance=240),
    ]
    imgsize = [2400, 2400]
    for i, camera in enumerate(cameras):
        output_file = f"docs/renders/prepare_z_axis{i+1}.png"
        scad = f"render_prepare_separate_z_actuator({i+1});"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_prepare_upright_z_mount(rendersystem):
    input_file = "rendering/prepare_upright_z_mount.scad"
    cameras = [
        Camera(position=[2, 55, 85], angle=[65, 0, 160], distance=175),
        Camera(position=[2, 55, 85], angle=[65, 0, 160], distance=175),
        Camera(position=[2, 55, 85], angle=[65, 0, 160], distance=175),
        Camera(position=[2, 52, 85], angle=[25, 0, 150], distance=175),
        Camera(position=[2, 52, 85], angle=[25, 0, 150], distance=175),
        Camera(position=[2, 52, 85], angle=[25, 0, 150], distance=175),
        Camera(position=[2, 52, 85], angle=[25, 0, 150], distance=175),
    ]
    imgsize = [2400, 2000]
    for i, camera in enumerate(cameras):
        output_file = f"docs/renders/prepare_z_mount{i+1}.png"
        scad = f"render_prepare_upright_z_mount({i+1});"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_prepare_nut_trap_test(rendersystem):
    input_file = "rendering/prepare_nut_trap_test.scad"
    camera = Camera(position=[0,7.5,12.5], angle=[77,0,185], distance=100)
    imgsize = [2400, 2000]
    for i in [1, 2, 3]:
        output_file = f"docs/renders/prepare_nut_trap_test{i}.png"
        scad = f"render_prepare_nut_trap_test({i});"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_prepare_main_body(rendersystem):
    input_file = "rendering/prepare_main_body.scad"
    cameras = [
        Camera(position=[-8, 7, 63], angle=[50, 0, 234], distance=263),
        Camera(position=[-11, 0, 77], angle=[84, 0, 222], distance=155),
        Camera(position=[-11, 0, 77], angle=[84, 0, 222], distance=155),
        Camera(position=[-8, 7, 63], angle=[50, 0, 234], distance=263),
        Camera(position=[-8, 7, 63], angle=[50, 0, 234], distance=263),
        Camera(position=[-8, 7, 63], angle=[50, 0, 234], distance=263),
        Camera(position=[-2, 57, 64], angle=[76, 0, 176.5], distance=179),
        Camera(position=[-2, 57, 64], angle=[76, 0, 176.5], distance=179),
        Camera(position=[-2, 57, 64], angle=[76, 0, 176.5], distance=179),
        Camera(position=[0, 0, 0], angle=[55, 0, 225], distance=200),
        Camera(position=[0, 0, 0], angle=[55, 0, 225], distance=200),
        Camera(position=[0, 0, 0], angle=[55, 0, 225], distance=200),
        Camera(position=[10, 10, -7], angle=[48, 0, 190], distance=200),
        Camera(position=[10, 10, -7], angle=[48, 0, 190], distance=200),
        Camera(position=[10, 10, -7], angle=[48, 0, 190], distance=200),
    ]
    imgsize = [2400, 2000]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for i, camera in enumerate(cameras):
            output_file = f"docs/renders/prepare_main_body{body}{i+1}.png"
            scad = f"render_prepare_main_body({i+1}, {manual});"
            render = ScadRender(output_file, input_file, scad, imgsize, camera)
            rendersystem.register_scad_render(render)

def register_prepare_stand(rendersystem):
    input_file = "rendering/prepare_stand.scad"
    # remove supports for normal stand only
    imgsize = [2400, 2000]
    camera = Camera(position=[15, 26, 41.5], angle=[47, 0, 111], distance=450)
    output_file = "docs/renders/prepare_stand1.png"
    scad = "render_prepare_stand(1, manual=false);"
    render = ScadRender(output_file, input_file, scad, imgsize, camera)
    rendersystem.register_scad_render(render)
    # embed top nuts for normal or manual stand
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        if manual == "true":
            camera = Camera(position=[-9, 20, 7.5], angle=[34, 0, 235], distance=400)
        else:
            camera = Camera(position=[-9, 20, 37.5], angle=[34, 0, 235], distance=450)
        for frame in [2, 3, 4, 5, 6, 7]:
            output_file = f"docs/renders/prepare_stand{body}{frame}.png"
            scad = f"render_prepare_stand({frame},{manual});"
            render = ScadRender(output_file, input_file, scad, imgsize, camera)
            rendersystem.register_scad_render(render)
    # add electronics drawer nut for normal stand only
    camera = Camera(position=[75, 52, 32], angle=[65, 0, 115], distance=240)
    for frame in [8, 9]:
        output_file = f"docs/renders/prepare_stand{frame}.png"
        scad = f"render_prepare_stand({frame}, manual=false);"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_actuator_assembly(rendersystem):
    input_file = "rendering/actuator_assembly.scad"
    cameras = [
        Camera(position=[2, 5, 14], angle=[33, 0, 242], distance=390),
        Camera(position=[-4.4, 7, 17.5], angle=[142, 319, 10], distance=190),
        Camera(position=[-4.4, 7, 17.5], angle=[142, 319, 10], distance=190),
        Camera(position=[-4.4, 7, 17.5], angle=[142, 319, 10], distance=190),
        Camera(position=[4, 35, 35], angle=[71, 0, 186], distance=330),
        Camera(position=[4, 35, 35], angle=[71, 0, 186], distance=330),
        Camera(position=[4, 35, 35], angle=[71, 0, 186], distance=330),
        Camera(position=[20, 6, 35], angle=[82, 0, 166], distance=500),
        Camera(position=[4, 35, 35], angle=[71, 0, 186], distance=330),
        Camera(position=[4, 35, 35], angle=[71, 0, 186], distance=330),
        Camera(position=[0, 50, 30], angle=[62, 0, 145], distance=260),
    ]
    imgsize = [2400, 2000]
    pngs = [
        "actuator_assembly_parts",
        "actuator_assembly_lead_screw_exploded",
        "actuator_assembly_lead_screw_tight",
        "actuator_assembly_lead_screw_only",
        "actuator_assembly_nut",
        "actuator_assembly_gear",
        "actuator_assembly_gear2",
        "actuator_assembly_oil",
        "actuator_assembly_x",
        "actuators_assembled",
        "separate_z_actuator_assembled",
    ]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for i, camera in enumerate(cameras):
            if (i in (0, 4, 5, 6, 7, 8, 9)) and (manual=="false"):
                bodies = ["", "_upright"]
                for this_body in bodies:
                    optics_version = "upright" if this_body=="_upright" else "rms"
                    output_file = f"docs/renders/{pngs[i]}{this_body}.png"
                    scad = f"render_actuator_assembly({i+1}, manual=false, optics_version=\"{optics_version}\");"
                    render = ScadRender(output_file, input_file, scad, imgsize, camera)
                    rendersystem.register_scad_render(render)
            else:
                output_file = f"docs/renders/{pngs[i]}{body}.png"
                scad = f"render_actuator_assembly({i+1},{manual});"
                render = ScadRender(output_file, input_file, scad, imgsize, camera)
                rendersystem.register_scad_render(render)

def register_picam(rendersystem):
    input_file = "rendering/prepare_picamera.scad"
    cameras = [
        Camera(position=[-6, 3, 11], angle=[46, 0, 90], distance=140),
        Camera(position=[0, 0, 0], angle=[29, 0, 90], distance=140),
        Camera(position=[1, 18, 8], angle=[52, 0, 90], distance=140),
    ]
    imgsize = [2400, 2000]
    for i, camera in enumerate(cameras):
        frame = i + 1
        output_file = f"docs/renders/picam{frame}.png"
        scad = f"render_picamera_frame(picam_frame_parameters({frame}));"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_mount_optics(rendersystem):
    input_file = "rendering/mount_optics.scad"
    imgsize = [2400, 2000]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        camera_1_normal = Camera(position=[9.6, 7, -14.5], angle=[103.5, 0, 290], distance=495)
        camera_c270 = Camera(position=[-33, 33, 18], angle=[62, 0, 59], distance=495)
        camera_1 = camera_1_normal if manual=="false" else camera_c270
        camera_2_normal = Camera(position=[7.75, 37, -3], angle=[135.5, 0, 320], distance=495)
        camera_2 = camera_2_normal if manual=="false" else camera_c270
        cameras = [
            camera_1,
            camera_2,
            camera_2,
            camera_2,
            Camera(position=[-18.5, 42.75, 23.75], angle=[57, 0, 143], distance=495),
            Camera(position=[-18.5, 42.75, 23.75], angle=[57, 0, 143], distance=495),
            Camera(position=[-18.5, 42.75, 23.75], angle=[57, 0, 143], distance=495),
            Camera(position=[-18.5, 42.75, 23.75], angle=[57, 0, 143], distance=495),
        ]
        for optics_version in ["rms", "low_cost", "upright"]:
            # no renders for manual rms or manual upright
            if not (manual == "true" and optics_version in ["rms", "upright"]):
                # manual "low_cost" uses the c270 camera
                optics_version = optics_version if manual=="false" else "c270"
                for i, camera in enumerate(cameras):
                    frame = i + 1
                    output_file = f"docs/renders/mount_optics_{optics_version}{body}{frame}.png"
                    scad = f'render_mount_optics({frame}, "{optics_version}", {manual});'
                    render = ScadRender(output_file, input_file, scad, imgsize, camera)
                    rendersystem.register_scad_render(render)

def register_mount_upright_optics(rendersystem):
    input_file = "rendering/mount_upright_optics.scad"
    cameras = [
        Camera(position=[-42, 76, 130], angle=[55, 0, 58], distance=495),
        Camera(position=[-42, 76, 130], angle=[55, 0, 58], distance=495),
        Camera(position=[-42, 76, 130], angle=[55, 0, 58], distance=495),
        Camera(position=[-42, 76, 130], angle=[55, 0, 58], distance=495),
        Camera(position=[-42, 76, 130], angle=[55, 0, 58], distance=495),
        Camera(position=[-42, 76, 130], angle=[55, 0, 58], distance=495),
        Camera(position=[-42, 76, 130], angle=[55, 0, 58], distance=495),
    ]
    imgsize = [2400, 2000]
    for i, camera in enumerate(cameras):
        frame = i + 1
        output_file = f"docs/renders/mount_upright_optics{frame}.png"
        scad = f'render_mount_upright_optics({frame}, optics_version="upright");'
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_mount_microscope(rendersystem):
    input_file = "rendering/mount_microscope.scad"
    cameras = [
        Camera(position=[24, 43.5, 84], angle=[65.5, 0, 103], distance=550),
        Camera(position=[24, 43.5, 84], angle=[65.5, 0, 103], distance=550),
    ]
    imgsize = [2400, 2000]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for optics_version in ["rms", "low_cost", "upright"]:
            # no renders for manual rms or manual upright
            if not (manual == "true" and optics_version in ["rms", "upright"]):
                # manual "low_cost" uses the c270 camera
                optics_version = optics_version if manual=="false" else "c270"
                for i, camera in enumerate(cameras):
                    frame = i + 1
                    output_file = f"docs/renders/mount_microscope_{optics_version}{body}{frame}.png"
                    scad = f'render_mount_microscope({frame}, "{optics_version}", {manual});'
                    render = ScadRender(output_file, input_file, scad, imgsize, camera)
                    rendersystem.register_scad_render(render)

def register_mount_illumination(rendersystem):
    input_file = "rendering/mount_illumination.scad"
    imgsize = [2400, 2000]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for optics_version in ["rms", "low_cost", "upright"]:
            if manual == "true":
                cameras = [
                    Camera(position=[-6, 49, 118], angle=[68, 0, 133], distance=360),
                    Camera(position=[-6, 49, 118], angle=[68, 0, 133], distance=360),
                    Camera(position=[-2, 56, 105], angle=[60, 0, 24], distance=160),
                    Camera(position=[-2, 56, 105], angle=[60, 0, 24], distance=160),
                    Camera(position=[-6, 49, 118], angle=[60, 0, 308], distance=460),
                    Camera(position=[-6, 49, 138], angle=[82, 0, 308], distance=360),
                    Camera(position=[-6, 49, 138], angle=[82, 0, 308], distance=360),
                    Camera(position=[-6, 49, 138], angle=[82, 0, 308], distance=360)
                ]
            elif optics_version == "upright":
                cameras = [
                    Camera(position=[0, 50, 180], angle=[68, 0, 133], distance=360),
                    Camera(position=[0, 50, 180], angle=[68, 0, 133], distance=360),
                    Camera(position=[0, 50, 180], angle=[60, 0, 133], distance=460),
                    Camera(position=[0, 50, 180], angle=[60, 0, 133], distance=460),
                ]
            else:
                cameras = [
                    Camera(position=[-6, 49, 178], angle=[68, 0, 133], distance=360),
                    Camera(position=[-6, 49, 178], angle=[68, 0, 133], distance=360),
                    Camera(position=[-2, 56, 145], angle=[60, 0, 24], distance=160),
                    Camera(position=[-2, 56, 145], angle=[60, 0, 24], distance=160),
                    Camera(position=[-6, 49, 178], angle=[60, 0, 308], distance=460),
                    Camera(position=[-6, 49, 178], angle=[82, 0, 308], distance=360),
                    Camera(position=[-6, 49, 178], angle=[82, 0, 308], distance=360),
                    Camera(position=[-6, 49, 178], angle=[82, 0, 308], distance=360)
                ]
            # no renders for manual rms or manual upright
            if not (manual == "true" and optics_version in ["rms", "upright"]):
                # manual "low_cost" uses the c270 camera
                optics_version = optics_version if manual=="false" else "c270"
                for i, camera in enumerate(cameras):
                    frame = i + 1
                    output_file = f"docs/renders/mount_illumination_{optics_version}{body}{frame}.png"
                    scad = f'mount_illumination({frame}, "{optics_version}", {manual});'
                    render = ScadRender(output_file, input_file, scad, imgsize, camera)
                    rendersystem.register_scad_render(render)

def register_check_actuator_centre(rendersystem):
    input_file = "rendering/check_actuator_centre.scad"
    imgsize = [2400, 1550] ## this is a size to match the aspect ratio of ActuatorPosition.png
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for optics_version in ["rms", "low_cost", "upright"]:
            camera_h = 60 if manual=="true" else 98
            camera = Camera(position=[-9.5,3.5,camera_h], angle=[89, 0, 125], distance=200)
            if not (manual == "true" and optics_version in ["rms", "upright"]):
                # manual "low_cost" uses the c270 camera
                optics_version = optics_version if manual=="false" else "c270"
                frame = 1
                output_file = f"docs/renders/check_actuator_centre_{optics_version}{body}{frame}.png"
                scad = f'render_check_actuator_centre({frame}, "{optics_version}", {manual});'
                render = ScadRender(output_file, input_file, scad, imgsize, camera)
                rendersystem.register_scad_render(render)


def register_motor_assembly(rendersystem):
    input_file = "rendering/motor_assembly.scad"
    camera = Camera(position=[-6, 0, -10], angle=[247, 0, 320], distance=293)
    imgsize = [1200, 2000]
    for i in [1, 2]:
        output_file = f"docs/renders/motor_assembly{i}.png"
        scad = f"motor_assembly({i});"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)
    ## close up view of frame 2
    camera = Camera(position=[3,1.5,-3], angle=[230,0,120], distance=60)
    imgsize = [1200, 1200]
    output_file = "docs/renders/motor_assembly3.png"
    scad = "motor_assembly(2);"
    render = ScadRender(output_file, input_file, scad, imgsize, camera)
    rendersystem.register_scad_render(render)

def register_mount_motors(rendersystem):
    input_file = "rendering/mount_motors.scad"
    imgsize = [2400, 2000]
    for optics_version in ["rms", "low_cost", "upright"]:
        camera = Camera(position=[22, 35, 98], angle=[53, 0, 115], distance=360)
        for i in [1, 2, 3, 4]:
            if optics_version == "upright" and i > 2:
                camera = Camera(position=[5, 30, 121], angle=[70, 0, 150], distance=360)
            output_file = f"docs/renders/mount_motors_{optics_version}{i}.png"
            scad = f'render_mount_motors({i}, "{optics_version}");'
            render = ScadRender(output_file, input_file, scad, imgsize, camera)
            rendersystem.register_scad_render(render)
        camera = Camera(position=[0, 30, 112], angle=[35, 0, 180], distance=325)
        for i in [5, 6]:
            output_file = f"docs/renders/mount_motors_{optics_version}{i}.png"
            scad = f'render_mount_motors({i}, "{optics_version}");'
            render = ScadRender(output_file, input_file, scad, imgsize, camera)
            rendersystem.register_scad_render(render)


def register_mount_sample_clips(rendersystem):
    input_file = "rendering/mount_sample_clips.scad"
    imgsize = [2400, 2000]

    # Mounting the screws doesn't need to be repeated
    camera = Camera(position=[0, 0, 178], angle=[68, 0, 308], distance=250)
    for i in range(2):
        output_file = f"docs/renders/prep_sample_clips_{i+1}.png"
        scad = f"render_mount_sample_clips({i+1});"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

    # Final 3 images
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        cam_z = 138 if manual == "true" else 178
        cameras = [
            Camera(position=[-10, 33, cam_z], angle=[53, 0, 296], distance=495),
            Camera(position=[-10, 33, cam_z], angle=[53, 0, 296], distance=495),
            Camera(position=[-10, 33, cam_z], angle=[73, 0, 1], distance=360),
        ]
        for optics_version in ["rms", "low_cost", "upright"]:
            # no renders for manual rms or manual upright
            if not (manual == "true" and optics_version in ["rms", "upright"]):
                # manual "low_cost" uses the c270 camera
                optics_version = optics_version if manual=="false" else "c270"
                for i, camera in enumerate(cameras):
                    output_file = f"docs/renders/mount_sample_clips_{optics_version}{body}{i+1}.png"
                    scad = f'render_mount_sample_clips({i+3}, "{optics_version}", {manual});'
                    render = ScadRender(output_file, input_file, scad, imgsize, camera)
                    rendersystem.register_scad_render(render)

def register_prepare_pi_and_sangaboard(rendersystem):
    input_file = "rendering/prepare_pi_and_sangaboard.scad"
    cameras = [
        Camera(position=[18.5, 20, 7], angle=[80, 0, 300], distance=190),
        Camera(position=[18.5, 20, 7], angle=[80, 0, 300], distance=190),
        Camera(position=[30, 18, 9], angle=[35, 0, 340], distance=190),
    ]
    imgsize = [2400, 2000]
    for i, camera in enumerate(cameras):
        output_file = f"docs/renders/prepare_pi_and_sangaboard{i+1}.png"
        scad = f"prepare_pi_and_sangaboard({i+1});"
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_mount_electronics(rendersystem):
    input_file = "rendering/mount_electronics.scad"
    cameras = [
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[35, 110, 36], angle=[70, 0, 270], distance=270),
        Camera(position=[68, 73, 34], angle=[65, 0, 115], distance=490),
        Camera(position=[68, 73, 34], angle=[65, 0, 115], distance=490),
        Camera(position=[68, 73, 34], angle=[65, 0, 115], distance=490),
        Camera(position=[68, 73, 34], angle=[65, 0, 115], distance=490),
    ]
    imgsize = [2000, 2000]
    for i, camera in enumerate(cameras):
        output_file = f"docs/renders/mount_electronics{i+1}.png"
        scad = f'render_mount_electronics({i+1},optics_version="rms");'
        render = ScadRender(output_file, input_file, scad, imgsize, camera)
        rendersystem.register_scad_render(render)

def register_complete_microscope(rendersystem):
    input_file = "rendering/complete_microscope.scad"
    imgsize = [2400, 2000]
    for manual in ["false", "true"]:
        body = "_manual" if manual=="true" else ""
        for optics_version in ["rms", "low_cost", "upright"]:
            # no renders for manual rms or manual upright
            if not (manual == "true" and optics_version in ["rms", "upright"]):
                # manual "low_cost" uses the c270 camera
                optics_version = optics_version if manual=="false" else "c270"
                dist = 700 if optics_version != "upright" else 780
                cameras = [
                    Camera(position=[0, 48, 98], angle=[65, 0, 133], distance=dist),
                    Camera(position=[0, 48, 98], angle=[65, 0, 308], distance=dist),
                    Camera(position=[0, 48, 98], angle=[90, 0, 90], distance=dist),
                    Camera(position=[0, 48, 98], angle=[90, 0, 0], distance=dist),
                ]
                for i, camera in enumerate(cameras):
                    output_file = f"docs/renders/complete_microscope_{optics_version}{body}{i}.png"
                    scad = f'render_complete_microscope("{optics_version}", {manual});'
                    render = ScadRender(output_file, input_file, scad, imgsize, camera)
                    rendersystem.register_scad_render(render)
    camera = Camera(position=[0, 48, 98], angle=[65, 0, 308], distance=700)
    output_file = "docs/renders/complete_microscope_manual_simple_post.png"
    scad = 'render_complete_microscope("c270", manual=true, post=true);'
    render = ScadRender(output_file, input_file, scad, imgsize, camera)
    rendersystem.register_scad_render(render)

def register_rendered_microscope_stl(rendersystem, force_clean):
    input_file = "rendering/librender/rendered_main_body.scad"
    version_str = version_string(force_clean)
    commit_str = commit_string(force_clean)
    print(f'Compiling microscope version "{version_str}", at commit "{commit_str}"')
    parameters = {"VERSION_STRING": version_str, "HASH": commit_str}
    rendersystem.register_render_stl(input_file, parameters)

def register_rendered_microscope_manual_stl(rendersystem, force_clean):
    input_file = "rendering/librender/rendered_main_body_manual.scad"
    version_str = version_string(force_clean)
    commit_str = commit_string(force_clean)
    print(f'Compiling microscope version "{version_str}", at commit "{commit_str}"')
    parameters = {"VERSION_STRING": version_str, "HASH": commit_str}
    rendersystem.register_render_stl(input_file, parameters)

def register_rendered_separate_z_actuator_stl(rendersystem):
    input_file = "rendering/librender/rendered_separate_z_actuator.scad"
    parameters = {}
    rendersystem.register_render_stl(input_file, parameters)

def register_rendered_separate_z_actuator_manual_stl(rendersystem):
    input_file = "rendering/librender/rendered_separate_z_actuator_manual.scad"
    parameters = {}
    rendersystem.register_render_stl(input_file, parameters)

def main():
    parser = argparse.ArgumentParser(
        description="Run OpenSCAD to create the assembly instruction renders."
    )
    parser.add_argument(
        "--force-clean",
        help="Ensures that the repo is clean before rendering",
        action="store_true",
    )
    parser.add_argument(
        "--stl-only",
        help="Only creates the pre-built STLs ready for rendering",
        action="store_true",
    )
    parser.add_argument(
        "--png-only",
        help="Only renders the PNGs, STLs must already have been pre-built",
        action="store_true",
    )
    args  = parser.parse_args()

    if args.png_only and args.stl_only:
        raise RuntimeError("Can't set both png-only and stl-only parameters.")

    run_all = not args.png_only and not args.stl_only

    rendersystem = RenderSystem()
    if run_all or args.stl_only:
        rendersystem.register_zip_assets('rendering/librender/hardware.zip')
        register_rendered_microscope_stl(rendersystem, force_clean=args.force_clean)
        register_rendered_microscope_manual_stl(rendersystem, force_clean=args.force_clean)
        register_rendered_separate_z_actuator_stl(rendersystem)
        register_rendered_separate_z_actuator_manual_stl(rendersystem)
    if run_all or args.png_only:
        #Register all openscad renders (and associated post processing)
        register_rms_optics_assembly(rendersystem)
        register_low_cost_optics_assembly(rendersystem)
        register_extra_low_cost_optics_assembly(rendersystem)
        register_condenser_assembly(rendersystem)
        register_upright_condenser_assembly(rendersystem)
        register_workaround_5mm_led(rendersystem)
        register_optics_assembled(rendersystem)
        register_band(rendersystem)
        register_brim_and_ties(rendersystem)
        register_brim_and_ties_separate_z_actuator(rendersystem)
        register_prepare_separate_z_actuator(rendersystem)
        register_prepare_upright_z_mount(rendersystem)
        register_prepare_nut_trap_test(rendersystem)
        register_prepare_main_body(rendersystem)
        register_prepare_stand(rendersystem)
        register_actuator_assembly(rendersystem)
        register_band_tool_assembly(rendersystem)
        register_picam(rendersystem)
        register_mount_optics(rendersystem)
        register_mount_upright_optics(rendersystem)
        register_mount_microscope(rendersystem)
        register_mount_illumination(rendersystem)
        register_check_actuator_centre(rendersystem)
        register_motor_assembly(rendersystem)
        register_mount_motors(rendersystem)
        register_mount_sample_clips(rendersystem)
        register_prepare_pi_and_sangaboard(rendersystem)
        register_mount_electronics(rendersystem)
        register_complete_microscope(rendersystem)
    rendersystem.render()

if __name__ == "__main__":
    main()
