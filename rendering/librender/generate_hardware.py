#!/usr/bin/env python3
'''
This script is released under the GPL
Copyright Julian Stirling 2020

It is a quick script to use NopSCADlib to generate some STLs of hardware.
To get the thread on the No2 screw we use my branch:
https://github.com/julianstirling/NopSCADlib/tree/no2_screw_hack
'''

import subprocess


hardware = [("m3_hex_x25", "screw(M3_hex_screw, 25);"),
            ("m4_button_x6", "screw(M4_dome_screw, 6);"),
            ("m3_cap_x10", "screw(M3_cap_screw, 10);"),
            ("m3_cap_x8", "screw(M3_cap_screw, 8);"),
            ("m3_cap_x6", "screw(M3_cap_screw, 6);"),
            ("m2_5_cap_x6", "screw(M2p5_cap_screw, 6);"),
            ("m2_cap_x6", "screw(M2_cap_screw, 6);"),
            ("no2_x6_5_selftap", "screw(No2_screw, 6.5);"),
            ("m3_nut", "nut(M3_nut);"),
            ("m3_washer", "washer(M3_washer);")]

for item, command in hardware:
    scad = "include <NopSCADlib/core.scad>\n"
    scad+= "$show_threads = true;\n"
    scad+= command
    with open('temp.scad', 'w') as file_obj:
        file_obj.write(scad)
    subprocess.run(["openscad", "-o", item+".stl", 'temp.scad'], check=True)
