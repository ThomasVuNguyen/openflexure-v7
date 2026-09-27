import lxml.etree as ET
from copy import deepcopy
import zipfile
import sys
import uuid
import os
import shutil

#for some reason the 3mfs produced cause a segfault in openscad
#use https://github.com/lemgandi/3mf2stl to convert to stls instead
#leave empty to try using 3mfs
stl_conversion_location = "<3mf2stl_path>"

input_file = sys.argv[1]
temp_folder = "/tmp/"+str(uuid.uuid4())

out_folder = input_file.replace(".3mf", "_colors")


os.mkdir(temp_folder)
os.mkdir(out_folder)

with zipfile.ZipFile(input_file, "r") as mf_file:
    mf_file.extractall(temp_folder + "/original")

tree = ET.parse(temp_folder + '/original/3D/3dmodel.model')

root = tree.getroot()
namespace = root.tag.split("}")[0].replace("{","")

#first get the list of colors from materials
#this seems to be how the blender 3mf export works
#the basematerial tag has implicit index for the materials
#and they are referenced by pindex on objects
material_tags = root.findall(".//{"+namespace+"}base")
color_map = {}
i=0
for tag in material_tags:
    if not tag.attrib["displaycolor"] in color_map:
        color_map[tag.attrib["displaycolor"]] = []
    color_map[tag.attrib["displaycolor"]].append(i)
    i+=1

openscad_txt = ""
#for each color, we create a new xml file
for color, indices in color_map.items():
    color_xml = deepcopy(tree)

    keep_objects = []
    for triangle_element in color_xml.findall(f".//{{{namespace}}}triangle"):
        if "p1" not in triangle_element.attrib:
            #check default for this object (could be faster by iterating inside objects)
            if int(triangle_element.getparent().getparent().getparent().attrib["pindex"]) not in indices:
                triangle_element.getparent().remove(triangle_element)
        elif not int(triangle_element.attrib["p1"]) in indices:
            triangle_element.getparent().remove(triangle_element)

    color_str = color.replace("#","")
    os.mkdir(temp_folder+f"/{color_str}")
    os.mkdir(temp_folder+f"/{color_str}/3D")
    os.mkdir(temp_folder+f"/{color_str}/_rels")

    color_xml.write(temp_folder+f"/{color_str}/3D/3dmodel.model")
    shutil.copyfile(temp_folder+f"/original/[Content_Types].xml", temp_folder+f"/{color_str}/[Content_Types].xml")
    shutil.copyfile(temp_folder+f"/original/_rels/.rels", temp_folder+f"/{color_str}/_rels/.rels")
    shutil.make_archive(temp_folder+f"/{color_str}.3mf", "zip", temp_folder+f"/{color_str}")
    inc_file = out_folder+f"/{color_str}.3mf"
    shutil.copyfile(temp_folder+f"/{color_str}.3mf.zip", inc_file)

    if stl_conversion_location:
        os.system(f"{stl_conversion_location} -i {inc_file} -o {inc_file.replace('.3mf', '.stl')}")
        inc_file = inc_file.replace(".3mf", ".stl")

    openscad_txt += 'color("' + color + '") import("./' + inc_file + '");' + "\n"

print(openscad_txt)
with open(input_file.replace(".3mf", ".scad"), "w") as scadfile:
    scadfile.write(openscad_txt)

shutil.rmtree(temp_folder)