/*

An illustration for the OpenFlexure Microscope; how to put the nut in

(c) 2016 Richard Bowman - released under CERN Open Hardware License

*/

use <../openscad/libs/compact_nut_seat.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/lib_actuator_assembly_tools.scad>
use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/libfeet.scad>
use <../openscad/libs/gears.scad>
use <../openscad/libs/main_body_structure.scad>
use <../openscad/libs/libdict.scad>
use <librender/hardware.scad>
use <librender/render_settings.scad>
use <librender/assembly_parameters.scad>
use <librender/render_utils.scad>
use <actuator_assembly.scad>

FRAME = 1;
MANUAL = false;

render_band_insertion(band_insertion_frame_parameters(FRAME), manual=MANUAL);

module cut_actuator_housing(params, cut=true){
    difference(){
        xy_screw_seat(params, label="X");

        // cutout actuator hole
        difference(){
            translate([-3,-10,0]){
                cube([6,10,5]);
            }
            actuator_end_cutout();
        }
        // only render half
        if (cut) {
            rotate_y(-90){
                cylinder(r=99,h=99,$fn=4);
            }
        }
    }
}

module render_band_insertion(frame_dict, manual=false){
    function no_lug_params() = let(
        params = default_params()
    ) replace_value("include_motor_lugs", false, params);    
    params = !manual ? default_params() : no_lug_params();

    foot_tr = key_lookup("foot_tr", frame_dict);
    band_tr = key_lookup("band_tr", frame_dict);
    tool_tr = key_lookup("tool_tr", frame_dict);
    tool_apart = key_lookup("tool_apart", frame_dict);
    casing_cut = key_lookup("casing_cut", frame_dict);
    casing_alpha = key_lookup("casing_alpha", frame_dict);
    foot_alpha = key_lookup("foot_alpha", frame_dict);
    tool_kink = key_lookup("tool_kink", frame_dict);
    band_stretch = key_lookup("band_stretch", frame_dict);
    nut_tool = key_lookup("nut_tool", frame_dict);
    actuator_h = key_lookup("actuator_h", params);

    coloured_render(body_colour(), 1.0){
        actuator_column(actuator_h, 0, join_to_casing=false);
    }

    if (!manual){
        place_part(motor_screw_pos() + [0, 0, y_motor_z_pos(params)-7]){
            m3_nut();
        }
        if (!casing_cut){
            place_part(motor_screw_pos() + [-motor_screw_separation(), 0, y_motor_z_pos(params)-7]){
                m3_nut();
            }
        }
    }

    band_h = actuator_h + band_stretch;
    translate(band_tr){
        viton_band_in_situ_vertical(h=band_h, tool_kink=tool_kink);
    }

    color(tools_colour(), 1){
        translate([0,0,-40]+tool_tr){
            rotate_z(90){
                band_tool_arms_render(params, apart=tool_apart);
            }
        }
    }
    color(tools_colour(), 1){
        translate([0,0,-43]+tool_tr){
            rotate_z(90){
                band_tool_holder(params);
            }
        }
    }
    color(extras_colour(), foot_alpha){
        translate(foot_tr){
            render(6){
                outer_foot(params, lie_flat=false, letter="X");
            }
        }
    }
    translate_z(xy_lead_assembly_height()){
        lead_screw_assembly(manual=manual);
    }
    translate_z(xy_nut_height()){
        rotate_z(30){
            m3_nut(brass=true, center=true);
        }
    }

    if (nut_tool) {
        color(tools_colour()){
            render(6){
                rotate_z(180){
                    translate([0, -15, xy_nut_height()-4]){
                        nut_tool();
                    }
                }
            }
        }
    }

    // See though object last
    color(body_colour(), casing_alpha){
        render(6){
            cut_actuator_housing(params, cut=casing_cut);
        }
    }
}


/* The arms of the band tool for rendering with option flex the prongs apart.

To simulate flexing if apart is true this repeates the translations and rotations
used in band_tool_arms(vertical=true), but a rotation slightly below 90
it also corrects so that the effective rotation is about an axis on the plane at the top
of the holder.

:param params: The microscope parameters dictionary.
:param apart: Set to true for the prongs to be sprung apart.
*/
module band_tool_arms_render(params, apart=false){
    if (!apart){
        band_tool_arms(params, vertical=true);
    }
    else{
        h=band_tool_end_thickness();
        angle = 88;
        // effective centre of rotation shift
        shift = holder_height()-2;
        reflect_y(){
            translate_y(band_tool_arm_sep()/2 - shift*cos(angle)){
                rotate_x(angle){
                    band_tool_arm_with_end(params, h);
                }
            }
        }
    }
}

function band_insertion_frame_parameters(frame_number) = let(
    band_elongate = -9,
    frame1 = [["foot_tr", [0,0,-40-band_elongate]],
              ["band_tr", [0,0,-40-band_elongate]],
              ["tool_tr", [0,0,-40]],
              ["tool_apart", false],
              ["casing_cut", false],
              ["casing_alpha", 1],
              ["foot_alpha", 1],
              ["tool_kink", true],
              ["band_stretch", band_elongate],
              ["nut_tool", true]],

    frame2 = [["foot_tr", [0,0,0]],
              ["band_tr", [0,0,0]],
              ["tool_tr", [0,0,0+band_elongate]],
              ["tool_apart", false],
              ["casing_cut", false],
              ["casing_alpha", 1],
              ["foot_alpha", 1],
              ["tool_kink", true],
              ["band_stretch", band_elongate],
              ["nut_tool", true]],

    frame3 = [["foot_tr", [0,0,0]],
              ["band_tr", [0,0,0]],
              ["tool_tr", [0,0,0+band_elongate]],
              ["tool_apart", false],
              ["casing_cut", true],
              ["casing_alpha", .5],
              ["foot_alpha", .5],
              ["tool_kink", true],
              ["band_stretch", band_elongate],
              ["nut_tool", true]],

    frame4 = [["foot_tr", [0,0,0]],
              ["band_tr", [0,0,0]],
              ["tool_tr", [0,0,0]],
              ["tool_apart", true],
              ["casing_cut", true],
              ["casing_alpha", .5],
              ["foot_alpha", .5],
              ["tool_kink", true],
              ["band_stretch", 0],
              ["nut_tool", true]],

    frame5 = [["foot_tr", [0,0,0]],
              ["band_tr", [0,0,0]],
              ["tool_tr", [0,0,-40]],
              ["tool_apart", false],
              ["casing_cut", true],
              ["casing_alpha", .5],
              ["foot_alpha", .5],
              ["tool_kink", false],
              ["band_stretch", 0],
              ["nut_tool", true]],

    frame6 = [["foot_tr", [0,0,0]],
              ["band_tr", [0,0,0]],
              ["tool_tr", [0,0,-40]],
              ["tool_apart", false],
              ["casing_cut", false],
              ["casing_alpha", 1],
              ["foot_alpha", 1],
              ["tool_kink", false],
              ["band_stretch", 0],
              ["nut_tool", false]],

    frames = [frame1, frame2, frame3, frame4, frame5, frame6]
) frames[frame_number-1];
