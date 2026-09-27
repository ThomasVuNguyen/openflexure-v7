use <./microscope_parameters.scad>
use <./main_body_structure.scad>
use <./utilities.scad>
use <./libdict.scad>
use <./z_axis.scad>
use <./wall.scad>
use <./z_axis.scad>
use <./illumination.scad>
use <./compact_nut_seat.scad>


module separate_z_actuator(params, cable_guides = false, cable_housing = false, rectangular = false){
    //This is the z-axis of the main body 
    // The cable_housing variable allows cable guides to be included or omitted
    difference(){
        union(){
            add_hull_base(microscope_base_t());
            // The wings have been removed from this design of the z-axis as they are not required 
            z_axis_casing(params, condenser_mount=true, cable_housing=cable_housing, rectangular=rectangular);
        }

        // This cuts the screw holes and/or nut traps (depending on whether it is for rectangular or triangular) into the z-axis
        z_axis_casing_cutouts(params, rectangular=rectangular);
        if (cable_guides){
            // Cable guide cutouts to allow the cables to be threaded through 
            z_cable_housing_cutout(params, h=99, top=false);
        }
    }

    // Adding the z actuator
    difference(){
        //No lug brackets, they are in the z-casing already. Adding brackets
        //over the top would make them protrude into the access hole for the optics
        //fitting screw.
        complete_z_actuator(params, lug_brackets=false);
        // Removing the extruding cylinders from the actuator
        translate([-50,0,-100]){
            cube(size = 100);
        }
    }
}

// Thickness of the vertical straight top section of the upright z spacerpart
function upright_z_spacer_top_thickness() = 5;
// Overall height of the upright z-spacer 
function upright_z_spacer_height(params, upright_sample_thickness) = (key_lookup("sample_z", params) - illumination_dovetail_z(params)) *2 + upright_sample_thickness;

module upright_z_spacer_labelled(params, upright_sample_thickness){
    difference(){
        upright_z_spacer(params, upright_sample_thickness);
        upright_z_spacer_label(params, upright_sample_thickness);
    }
}

module upright_z_spacer(params, upright_sample_thickness){
    $fn=32;
    difference(){
        // Spacer main body
        upright_z_spacer_body(params, upright_sample_thickness);
        // Screw clearance holes
        translate_z(-tiny()){
            translate(right_illumination_screw_pos(params)){
                cylinder(r = 2, h = 4);
            }
        }
        translate_z(-tiny()){
            translate(left_illumination_screw_pos(params)){
                cylinder(r = 2, h = 4);
            }
        }
        translate_z(-tiny()){
            translate(illumination_back_corner_pos(params)){
                cylinder(r = 2, h = 4);
            }
        }
        // Screw head boring holes
        translate(right_illumination_screw_pos(params)){
            rotate_z(90-25){
                z_axis_boring_holes(boring_radius = 5.1, taper=0.5);
            }
        }
        translate(left_illumination_screw_pos(params)){
            rotate_z(180+25){
                z_axis_boring_holes(boring_radius = 5.1, taper=0.5);
            }
        }
        // Counterbore for back corner, 3mm above the base
        translate_z(3){
            translate(illumination_back_corner_pos(params)){
                cylinder(r = 4, h = upright_z_spacer_height(params, upright_sample_thickness));
            }
        }
        // Inserting the nut traps at the top of the spacer
        // (note nut trap module base sits 9mm below mounting face to give a 1.5mm thick top plate)
        spacer_nut_trap_base = upright_z_spacer_height(params, upright_sample_thickness) - 9 ;
        translate_z(spacer_nut_trap_base){
            upright_z_spacer_top_screw_holes(params);
        }
        // Cut-out for motor
        z_spacer_front_wall_pos = [0, right_illumination_screw_pos(params).y+8, right_illumination_screw_pos(params).z-tiny()];
        translate(z_spacer_front_wall_pos){
            cylinder(r = 12.5, h = upright_z_spacer_height(params, upright_sample_thickness)+10);
        }
    }
}

module upright_z_spacer_body(params, upright_sample_thickness){
    hull(){
        // The translation needed for height of the spacer, including the fact that the spacer top part has thickness
        top_translate_z = upright_z_spacer_height(params, upright_sample_thickness)-upright_z_spacer_top_thickness();
        translate_z(top_translate_z){
            upright_z_spacer_top(params);
        }
        upright_z_spacer_base(params);
    }
}

module upright_z_spacer_top(params){
    top_h = upright_z_spacer_top_thickness();
    hull(){
        // Creating the rectangular top of the spacer
        translate(right_illumination_screw_pos(params)){
            cylinder(r=6,h=top_h);
        }
        translate(left_illumination_screw_pos(params)){
            cylinder(r=6,h=top_h);
        }
        translate(right_back_sq_illum_corner_pos(params)){
            cylinder(r=6,h=top_h);
        }
        translate(left_back_sq_illum_corner_pos(params)){
            cylinder(r=6,h=top_h);
        }
    }
}

module upright_z_spacer_base(params){
    hull(){
        // Creating the triangular bottom of the spacer using the position of the corners as previously defined
        each_illumination_corner(params){
            cylinder(r=5,h=tiny());
        }
    }
}

module upright_z_spacer_top_screw_holes(params){
    extra_bore = 2.5;
    chamfer_offset = 5;
    // Inserting the nut traps and screw holes into the spacer
    translate(right_illumination_screw_pos(params)){
        m3_nut_trap_with_shaft(slot_angle=0,tilt=0,deep_shaft=extra_bore,chamfer_offset=chamfer_offset);
    }
    translate(left_illumination_screw_pos(params)){
        m3_nut_trap_with_shaft(slot_angle=0,tilt=0,deep_shaft=extra_bore,chamfer_offset=chamfer_offset);
    }
    // Rotating the back nut traps to minimise "threading" 
    translate(right_back_sq_illum_corner_pos(params)){
        m3_nut_trap_with_shaft(slot_angle=225,tilt=0,deep_shaft=extra_bore,chamfer_offset=chamfer_offset);
    }
    translate(left_back_sq_illum_corner_pos(params)){
        m3_nut_trap_with_shaft(slot_angle=135,tilt=0,deep_shaft=extra_bore,chamfer_offset=chamfer_offset);
    }
}

module upright_z_spacer_label(params, upright_sample_thickness){
    // The flat face is slightly tilted because the base shape is made of
    // r=5mm circles, but the top shape is made from r=6mm circles
    indent = 0.5;
    h = upright_z_spacer_height(params, upright_sample_thickness);
    angle = atan((6-5)/(h - upright_z_spacer_top_thickness()));
    // side text
    translate(illumination_back_corner_pos(params)+[0, -5.5+indent, h/2]){
        rotate([90+angle, 0, 0]){
            linear_extrude(1){
                text(str(upright_sample_thickness,"mm"),size=4,font="sans",halign="center",valign="center");
            }
        }
    }
    // Top text
    top_pos = illumination_back_corner_pos(params) + [0, 4, h-indent];
    translate(top_pos){
        linear_extrude(1){
            translate_y(0.5){
                text("Sample height",size=4,font="sans",halign="center",valign="bottom",$fn=32);
            }
            translate([-6, -0.5, 0]){
                text(str(upright_sample_thickness),size=4,font="sans",halign="right",valign="top");
            }
            translate([6, -0.5, 0]){
                text("mm",size=4,font="sans",halign="left",valign="top");
            }
        }
    }
}

// The upright spacer is built in place. 
// This module is to place the spacer on z=0 for creating STLs
module upright_z_spacer_stl(params, upright_sample_thickness){
    translate_z(-illumination_dovetail_z(params)){
        upright_z_spacer_labelled(default_params(), upright_sample_thickness);
    }
}
