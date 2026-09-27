use <microscope_parameters.scad>
use <main_body_transforms.scad>
use <utilities.scad>
use <wall.scad>
use <z_axis.scad>
use <main_body_structure.scad>

module at_each_motor_screw(){
    for(x_tr = [-.5, .5]*motor_screw_separation()){
        translate([x_tr,12,0]){
            children();
        }
    }
}


module cable_tidy_body_back(h, curve_both=false, upright=false){
    //This is the back edge of the cable tidy.
    // it will be hulled with the font where the lugs are to make
    // the final structure. The +x direction always has a radius of
    // 8. To have a radius on both sizes (for the z_motor) use
    // `curve_both=true`. For the x-motor this shape must be mirrored.
    x_out = upright ? 8 : 11;
    y_out = upright ? 0 : 11;
    translate([x_out,-y_out,0]){
        cylinder(d=8, h=h);
    }
    if (curve_both){
        translate([-x_out,-y_out,0]){
        cylinder(d=8, h=h);
    }
    }
    else{
        translate([-16,-14.5,0]){
            cylinder(d=1, h=h);
        }
    }
}


module cable_tidy_body(h, curve_both=false, upright=false){
    hull(){
        at_each_motor_screw(){
            cylinder(d=10, h=h);
        }
        cable_tidy_body_back(h, curve_both=curve_both, upright=upright);
    }
}

// Cut-outs inside the cable tidy
// NB h here is the top of the tallest cut-out, so
// should be less than the overall height.
// The cable cut-out will be either h or h-0.75 tall.
module cable_tidy_body_cutouts(h, front=false){
    if (!front){
        translate([-23,12-4,1.5]){
            cube([46,100,100]);    // The motor lugs
        }
    }
    translate([0,12,-1]){
        cylinder(d=29, h=21);  // The motor body
    }
    translate([-10,-6,-1]){
        cube([20,100,21]);     // The connector
    }
    // Void for the cable
    if (front){  // front means we are rendering the Z cable tidy
        // the wires where they exit the connector
        translate([-10,-12,1]){
            cube([20,6.1,h-1]);
        }
        // connect this to the slot (NB lower height, to make
        // bridging work)
        hull(){
            translate([-10,-12,1]){
                cube([20,6.1,h-1.75]);
            }
            rotate_z(-10){
                translate([-20,-7,1]){
                    cube([11,5.1,h-1.75]);
                }
            }
        }
        // slot that goes all the way to the bottom to allow cable
        // to pass through.
        rotate_z(-10){
            translate([-19,-7,-1]){
                cube([11,5.1,h+1-0.75]);
            }
        }
    }
    else{  // side cable tidies
        // the wires where they exit the connector
        // NB this needs to touch the edge of the 
        // cut-out for the connector on one side,
        // in order to make bridging work
        // (that's the +2 in width and -2 in x)
        translate([-8-2,-12,1]){
            cube([16+2,6.1,h-1]);
        }
        // connection to the vertical shaft in the body
        // NB this is intentionally slightly lower, so that
        // the part will print correctly - it needs to bridge
        // here first.
        translate([-20,-12,1]){
            cube([20,6.1,h-1.75]);
        }
        // angled slot going through the bottom, so the cable
        // can be inserted
        rotate_z(-148){
            translate([0,-5.1,-1]){
                cube([25,5.1,h+1-0.75]);
            }
        }
    }

    motor_screw_counterbore(h, hulled=true);
}

module upright_cable_tidy_body_cutouts(h){
    motor_screw_counterbore(h, hulled=false);
    // cable entry for the upright z-motor
    translate([-motor_screw_separation()/2-10,10,0]){
        cube([8,15,7],center=true);
    }
}

module motor_screw_counterbore(h, hulled=false){
    module head_cut_out(){
        translate_z(1.5){
            cylinder(r=5.1, h=2*h);
        }
    }
    at_each_motor_screw(){
        cylinder(d=3.5, h=3*h, center=true, $fn=12);
        if (!hulled){
            head_cut_out();
        }
    }
    if (hulled){
        hull(){
            at_each_motor_screw(){
                head_cut_out();
            }
        }
    }
}

// Linear extrusion, with the top edges chamfered with a radius
// of roc
module linear_extrude_with_rounded_top(h, roc=1.5){
    // The bottom is simple enough: extrude up to the curved part
    linear_extrude(h - roc){
        children();
    }
    // The curved top is achieved by insetting the 2D shape, then
    // convolving it with a sphere
    minkowski(){
        sphere(r=roc, $fn=16);
        translate_z(h - roc){
            linear_extrude(tiny()){
                offset(-roc){
                    children();
                }
            }
        }
    }
}

// Project along Z, then extrude with a chamfered top edge
module thick_projection_with_rounded_top(h, roc=1.5){
    linear_extrude_with_rounded_top(h=h, roc=roc){
        projection(){
            children();
        }
    }
}

module side_cable_tidy(params, h=6){
    difference(){
        thick_projection_with_rounded_top(h=h){
            union(){
                y_actuator_frame(params){
                    cable_tidy_body(h);
                }
                side_housing(params, h=h,cavity_h=0, attach=false);
            }
        }
        y_actuator_frame(params){
            cable_tidy_body_cutouts(h-1, front=false);
        }
        side_housing_cutout(params, h=h-1.75, screw_hole_type="counterbore");
    }
}

// Module: front_cable_tidy(params, h=6)
// Description: 
//   The cable tidy at the front of the microscope (i.e. for the Z motor)
//   NB this renders in-place and will need to be transformed to put it
//   in printable position, using 
//   z_cable_tidy_frame_undo(params, z_extra=motor_bracket_h())
module front_cable_tidy(params, h=6){
    difference(){
        z_cable_tidy_frame(params, z_extra=motor_bracket_h()){
            // thick_projection needs the bottom to be flat and the
            // sides to be vertical, so we must work in the 
            // cable tidy's frame of reference
            thick_projection_with_rounded_top(h=h){
                // In order to get the Z cable housing transformed
                // correctly, we need to apply the inverse transform,
                // so this is the cable housing as seen from the cable
                // tidy's frame of reference.
                z_cable_tidy_frame_undo(params, z_extra=motor_bracket_h()){
                    hull(){
                        z_cable_housing_top(params, h);
                        z_cable_tidy_frame(params, z_extra=motor_bracket_h()){
                            cable_tidy_body_back(h, curve_both=true);
                        }
                    }
                }
            }
            // Tabs for the attaching the screws
            cable_tidy_body(h=1.5, curve_both=true);
        }
        z_cable_tidy_frame(params, z_extra=motor_bracket_h()){
            cable_tidy_body_cutouts(h-1, front=true);
        }
        intersection(){
            // The top of this part must be parallel with the print bed, or it 
            // won't slice properly.  z_cable_housing_cutout on its own is at a
            // slight angle, hence the intersection.
            z_cable_housing_cutout(params, 99, top=true);
            z_cable_tidy_frame(params, z_extra=motor_bracket_h()){
                cube([99, 99, (h - 1.75)*2], center=true);
            }
        }
	xy_legs_and_actuators(params);
    }
}

// The upright version is sufficiently different in construction that it is a separate module
module front_cable_tidy_upright(params, h=6){
    difference(){
        z_cable_tidy_frame(params, z_extra=motor_bracket_h()){
            // thick_projection needs the bottom to be flat and the
            // sides to be vertical, so we must work in the 
            // cable tidy's frame of reference
            thick_projection_with_rounded_top(h=h){
                difference(){
                    union(){
                        // In order to get the Z cable housing transformed
                        // correctly, we need to apply the inverse transform,
                        // so this is the cable housing as seen from the cable
                        // tidy's frame of reference.
                        z_cable_tidy_frame_undo(params, z_extra=motor_bracket_h()){
                            z_cable_housing_top(params, h);
                        }
                        translate([0,12,0]){
                            cylinder(d=29, h=h);  // Where the motor body would be
                        }
                    }
                    translate_y(-30-3){
                        cylinder(d=60, h=3*h, center=true);
                    }
                }
            }
            // motor lug pieces
            at_each_motor_screw(){
                cylinder(d=10, h=2);
            }
        }
        z_cable_tidy_frame(params, z_extra=motor_bracket_h()){
            upright_cable_tidy_body_cutouts(h-1);
        }
        intersection(){
            // The top of this part must be parallel with the print bed, or it 
            // won't slice properly.  z_cable_housing_cutout on its own is at a
            // slight angle, hence the intersection.
            z_cable_housing_cutout(params, 99, top=true);
            z_cable_tidy_frame(params, z_extra=motor_bracket_h()){
                cube([99, 99, (h - 1.75)*2], center=true);
            }
        }
	xy_legs_and_actuators(params);
    }
}

module cable_tidies(params, upright){

    z_cable_tidy_frame_undo(params, z_extra=motor_bracket_h()){
        translate([0,40,-18]){
            if (upright){
                front_cable_tidy_upright(params);
            }
            else{
                front_cable_tidy(params);
            }
        }
    }
    reflect_x(){
        translate([20,-20,0]){
            side_cable_tidy(params);
        }
    }
}



