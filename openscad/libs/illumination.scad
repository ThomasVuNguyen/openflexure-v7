/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Illumination                            *
*                                                                 *
* The illumination module includes the condenser lens mounts and  *
* the dovetail that it attaches to.                               *
*                                                                 *
* (c) Richard Bowman, April 2018                                  *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


// Note that no geometry is output in this file. The condenser and the illumination
// dovetail are created in condenser.scad and illumination_dovetail.scad

use <./utilities.scad>
use <./logo.scad>
use <./microscope_parameters.scad>
use <./locking_dovetail.scad>
use <./z_axis.scad>
use <./libdict.scad>
use <./lighttrap.scad>

function illumination_dovetail_w() = 30; // width of the dovetail
function illumination_dovetail_y() = 35; // position of the mating surface
function illumination_dovetail_z(params) = leg_height(params)-2;
function illumination_dovetail_blockdepth() = 12; // depth of the block containing the dovetail

// Set the dovetail parameters dictionary based on the above settings:
function illumination_dt_params() = dovetail_params(
    overall_width = illumination_dovetail_w(),
    block_depth = illumination_dovetail_blockdepth(),
    overall_height = 99
);

// Note: Front is the side towards the motors, Back is the side towards the stage
function illumination_back_corner_y(params) = (key_lookup("leg_r", params)+ leg_outer_w(params))/sqrt(2) + 4;
function right_illumination_screw_pos(params) = [20, z_nut_y(params), illumination_dovetail_z(params)];
function left_illumination_screw_pos(params) = vector_mirror_x(right_illumination_screw_pos(params));
function illumination_back_corner_pos(params) = [0, illumination_back_corner_y(params), illumination_dovetail_z(params)];
// Defining the positions of the back corners of the rectangle for the top of the spacer
// The triangular top of the spacer fits onto the triangular face of the z-axis in the main body.
// The rectangular top of the spacer is atached to the rectangular face of the separate z-actuator, a rectangular face is used here for stability.
function right_back_sq_illum_corner_pos(params) = [20, illumination_back_corner_y(params), illumination_dovetail_z(params)];
function left_back_sq_illum_corner_pos(params) = vector_mirror_x(right_back_sq_illum_corner_pos(params));

function right_illumination_screw_rotation() = -40;
function left_illumination_screw_rotation() = -right_illumination_screw_rotation();

module each_front_illumination_screw(params){
    // A transform to repeat objects at each screw hole
    screws = [right_illumination_screw_pos(params), left_illumination_screw_pos(params)];
    for(pos=screws){
        translate(pos){
            children();
        }
    }
}

module each_illumination_corner(params, rectangular=false){
    // A transform to repeat objects at each corner of the illumination mount for a triangular top
    tri_corners = [right_illumination_screw_pos(params),
                   left_illumination_screw_pos(params),
                   illumination_back_corner_pos(params)];
    rect_corners = [right_illumination_screw_pos(params),
                    left_illumination_screw_pos(params),
                    right_back_sq_illum_corner_pos(params),
                    left_back_sq_illum_corner_pos(params)];
    corners = rectangular ? rect_corners : tri_corners;
    for(pos=corners){
        translate(pos){
            children();
        }
    }
}

/* THE ILLUMINATION DOVETAIL */
//Note that this is not built from here. it is built in illumination_dovetail.scad

function illumination_dovetail_lug_height() = 3;

module illumination_dovetail_branding(params, h, bottom_z){
    // The open flexure logo for the back of the illumination fovetail

    //lug height
    lug_h = illumination_dovetail_lug_height();
    //height of the slobed back
    slope_h = h-lug_h ;
    //top and bottom of y position of the sloped back
    bot_y = right_illumination_screw_pos(params).y+5;
    top_y = illumination_dovetail_y()+illumination_dovetail_blockdepth();
    back_angle = atan((top_y-bot_y)/slope_h);
    logo_z = bottom_z+lug_h +slope_h/2;
    logo_y = (top_y+bot_y)/2+.5;

    translate([-11,logo_y,logo_z]){
        rotate_x(90-back_angle){
            openflexure_emblem(scale_factor=.1);
        }
    }
}

module illumination_dovetail_structure(params, dt_z, dt_h){
    //this is the outer structure that forms the illumination mount.
    dt_y = illumination_dovetail_y();

    hull(){
        translate([0, dt_y, dt_z]){
            mirror([0,1,0]){
                dovetail_block(illumination_dt_params(), height=dt_h);
            }
        }

        //trilobular structure with "corners" at the 2 screws and a back corner position
        hull(){
            each_front_illumination_screw(params){
                cyl_slot(r=4, h=3+tiny(), dy=3);
            }
            translate(illumination_back_corner_pos(params)){
                scale([1,0.5,1]){
                    cylinder(r=4, h=tiny());
                }
            }
        }
    }
}

// The position in X,Y of the cable channel
function illumination_cable_channel_xypos() = let(
    x_tr = -.6*illumination_dovetail_w()/2,
    dt_y = illumination_dovetail_y(),
    dt_depth = key_lookup("depth", illumination_dt_params())
) [x_tr, dt_y+dt_depth+2, 0];

module illumination_dovetail(params, h=50){
    // The dovetail on which we mount the condenser for the illumination
    // This is built in place in the microscope coordinates.

    // z position where we mount it
    bottom_z = illumination_dovetail_z(params);
    dt_y = illumination_dovetail_y();
    // Where the dovetail itself starts (relative to the bottom of the structure)
    start_z = 14;
    // z position of the dovetail, in microscope referecne frame
    dt_z = bottom_z + start_z;
    //height of the dovetail
    dt_h = h - start_z;
    dt_params = illumination_dt_params();
    lug_h = illumination_dovetail_lug_height();

    difference(){
        illumination_dovetail_structure(params, dt_z, dt_h);
        // slots for the mounting screws (to allow adjustment of position)
        each_front_illumination_screw(params){
            // wider than normal M3 clearance hole to ease adjustment of illumination
            m3_clear_loose = 3/2*1.33;
            cyl_slot(r=m3_clear_loose, h=999, dy=3, center=true, $fn=12);
            translate_z(lug_h){
                cyl_slot(r=6, h=999, dy=3, $fn=24);
            }
        }
        // alpha is the rotation angle for the slices that make up the bottom of the
        // channel. The number is picked to give a flat bridge that prints well.
        alpha=-11.5;
        // channel for the illumination wiring.
        translate(illumination_cable_channel_xypos()){
            translate_z(bottom_z){
                sequential_hull(){
                    // Octagonal base layers used to create better shape for bridging
                    // as the channel meets the sloped face.
                    translate([-3, 0, -tiny()]){
                        rotate(alpha){
                            cylinder(h=tiny(), d=7.5, $fn=8);
                        }
                    }
                    translate_z(start_z){
                        rotate(alpha){
                            cylinder(h=tiny(), d=7, $fn=8);
                        }
                    }
                    translate_z(start_z+2){
                        cylinder(h=tiny(), d=6.5, $fn=16);
                    }
                    translate_z(99){
                        cylinder(h=tiny(), d=6.5, $fn=16);
                    }
                }
            }
        }
        // cutout to make the dovetail
        translate([0,dt_y,dt_z]){
            mirror([0,1,0]){
                dovetail_f_cutout(dt_params, height=99);
            }
        }
        // clearance for the motor
        translate_y(-2){
            z_motor_clearance(params);
        }
    }
    illumination_dovetail_branding(params, h, bottom_z);
}

/*
* This is the difference between the lens radius and the aperture radius
* used in both condenser_lens_gripper and condenser_cutout
*/
function condenser_aperture_difference() = 1.1;
function condenser_lens_assembly_pedestal_height() = 5.5;
module condenser_lens_gripper(lens_r, lens_t, base_r){
    // the lens holder on the end or the condenser
    pedestal_h = condenser_lens_assembly_pedestal_height();
    h = pedestal_h+lens_t+1.5;
    aperture_r = lens_r-condenser_aperture_difference();

    difference() {
        union() {
            trylinder_gripper(inner_r=lens_r,
                              grip_h=pedestal_h + lens_t/3,
                              h=h,
                              base_r=base_r,
                              flare=0.5);
            // pedestal to raise the lens up within the gripper
            cylinder(r=aperture_r+0.8, h=pedestal_h);
        }
        // hole through pedestal for the beam passing through the lens
        translate_z(-tiny()){
            cylinder(r=aperture_r, h=h);
        }
    }
}

function illumination_mounting_hole_sep() = 10;

function condenser_lid_mounting_hole_pos(base_r) = [base_r-2, base_r+1, 0];

function apeture_tray_t() = 1.5;
function aperture_tray_width() = 7.5;
function aperture_tray_depth() = aperture_tray_width() + 10;
function aperture_tray_shift() = [0, -4, 0];

module condenser_cutout(lens_r, lens_assembly_z){
    // This is the cutout for the beam to pass through the condenser.
    // It contains a light trap and mouning for the diffuser

    apeture_tray_z=1;
    light_trap_start_z = apeture_tray_z+apeture_tray_t()+tiny();

    lighttrap_h = lens_assembly_z+3*tiny()-light_trap_start_z;
    aperture_r = lens_r-condenser_aperture_difference();
    light_trap_width = aperture_tray_width() + .5;

    //Light trap to reduce stray reflectins

    translate_z(light_trap_start_z-tiny()){
        r1=2;
        f1 = light_trap_width-2*r1;
        lighttrap_sqylinder(r1=r1, f1=f1, r2=aperture_r,f2=0, h=lighttrap_h+4*tiny(), $fn=16);
    }
    translate_z(apeture_tray_z+apeture_tray_t()/2){
        translate(aperture_tray_shift()){
            cube([aperture_tray_width(), aperture_tray_depth(), apeture_tray_t()], center=true);
        }
    }
    cube([5,5,light_trap_start_z+1], center=true);

    reflect_x(){
        translate_x(illumination_mounting_hole_sep()/2){
            translate_z(-tiny()){
                rotate_z(30){
                    no2_selftap_hole(h=7, center=false);
                }
            }
        }
    }
}

module condenser_aperture(){
    $fn=60;
    nominal_size = [aperture_tray_width(), aperture_tray_depth(), apeture_tray_t()];
    actual_size = nominal_size - [1, 1, 1]*0.5;
    //Creat drilling hole for standard 118 degree drill
    angle = 118/2;
    cyl_h = actual_size.z+tiny();
    bot_rad = 0.1;
    top_rad = bot_rad + cyl_h*tan(angle);
    difference(){
        cube(actual_size, center=true);
        translate(-aperture_tray_shift()){
            cylinder(r1=bot_rad, r2=top_rad, h=cyl_h, center=true);
        }
    }
}

function condenser_dovetail_params() = let(
    block_depth = 16,
    height = 16,
    dt_params = dovetail_params(
        overall_width=illumination_dovetail_w(),
        overall_height=height,
        block_depth = block_depth,
        taper_block = true,
        // As the condenser is modelled and printed upside down,
        //  if we don't flip the nut trap by nut_slot_slope = "down"
        //  the nut would slide out of the trap when the screw is
        //  removed. 
        nut_slot_slope = "down"
    )
) dt_params;

module condenser_body(base_r, lens_assembly_z, include_mounting=true, basic_condenser = false){
    dt_params = condenser_dovetail_params();
    dt_height = key_lookup("overall_height", dt_params);
    // the dovetail clip
    if (include_mounting){
        translate_y(illumination_dovetail_y()){
            dovetail_clamp_m(dt_params);
        }
    }
    // main cylinder of the condenser
    cylinder(r=base_r+.2, h=lens_assembly_z+tiny());
    if (!basic_condenser){
        //this hull is the outer shape of the body of the condenser
        sequential_hull(){
            cylinder(r=base_r+.2, h=dt_height);
            translate_y(base_r){
                cylinder(r=base_r+.2, h=dt_height);
            }
            if (include_mounting){
                translate_y(illumination_dovetail_y()){
                    linear_extrude(dt_height){
                        back_of_block_2d(dt_params);
                    }
                }
            }
        }
    }
}

// lens_d and lens_t were only ever set to 13 and 1 respectively, so these are now
// constants - they may be re-parameterised in the future.
// lens_assembly_z is used at its default value in the STL and renders - it is only
// changed in the upright condenser.
function condenser_lens_assembly_z()=22;
function condenser_lens_z()=condenser_lens_assembly_z()+condenser_lens_assembly_pedestal_height();
function condenser_lens_thickness()=1;
function condenser_lens_diameter()=13;
function condenser_base_r(lens_d)=lens_d/2+2;

// Module: condenser()
//   This makes the condenser arm, including the dovetail clamp, condenser
//   lens holder, and mounting for the illumination PCB.
module condenser(lens_assembly_z=condenser_lens_assembly_z(), include_mounting=true, basic_condenser = false){
    lens_d=condenser_lens_diameter();
    lens_t=condenser_lens_thickness();
    base_r = condenser_base_r(lens_d);

    difference(){
        union(){
            condenser_body(base_r, lens_assembly_z+tiny(), include_mounting, basic_condenser);
            //add the lens gripper
            translate_z(lens_assembly_z){
                condenser_lens_gripper(lens_d/2, lens_t, base_r);
            }
        }
        condenser_cutout(lens_d/2, lens_assembly_z);
        reflect_x(){
            translate(condenser_lid_mounting_hole_pos(base_r) - [0, 0, 0.5]){
                no2_selftap_hole(h=7);
            }
        }
     }
}



module illumination_board_cutout(h, board_bore_depth){
    union(){
        translate_z(h-board_bore_depth){
            cylinder(h=h,d=16);
        }
        translate([-3, -3, h-board_bore_depth-4]){
            cube([6, 25, h]);
        }
        translate([-2, 1, h-7]){
            cube([4, 99, h]);
        }
        translate_z(-2.5){
            reflect_x(){
                translate_x(illumination_mounting_hole_sep()/2){
                    no2_selftap_hole(h=h);
                }
            }
        }
    }
}

// A lid to cover the LED and board on top of the condenser
// NB this creates a shape where the top of the lid is
// z=0, and the rest is at z>0
// i.e. it is upside down.
function condenser_lid_h()=13;
module condenser_lid(lens_d=condenser_lens_diameter()){
    //allow space for 2 screw heads and for board thickness, and for the LED
    board_bore_depth = 8.0;
    //Total height must be deep enough for the self tap screw
    h = condenser_lid_h();
    base_r = condenser_base_r(lens_d);

    module cropped_body(y_cut_pos){
        difference(){
            condenser_body(base_r, tiny());
            translate_y(y_cut_pos+100){
                cube([1, 1, 1]*200, center=true);
            }
        }
    }

    difference(){
        minkowski(){
            offset_thick_section(h=h-1.5, offset=-2, shift=true){
                cropped_body(illumination_dovetail_y()-3);
            }
            sphere(r=3.5,$fn=16);
        }

        translate_z(h){
            offset_thick_section(h=h, offset=.5, shift=true){
                cropped_body(illumination_dovetail_y());
            }
        }
        illumination_board_cutout(h, board_bore_depth);
        reflect_x(){
            translate(condenser_lid_mounting_hole_pos(base_r) + [0, 0, h-2]){
                no2_selftap_counterbore(flip_z=true);
            }
        }
    }
}

function condenser_board_spacer_thickness()=1.5;

module condenser_board_spacer(thickness=condenser_board_spacer_thickness()){
    $fn=32;
    diameter = 14.5;
    hole_sep = illumination_mounting_hole_sep();
    ring_width = diameter-hole_sep;
    difference(){
        union(){
            difference(){
                cylinder(h=thickness, d=diameter);
                cylinder(h=3*thickness, d=diameter-ring_width, center=true);
                translate_y(diameter){
                    cube([2, 2, 2]*diameter, center=true);
                }
            }
            reflect_x(){
                translate_x(hole_sep/2){
                    cylinder(h=thickness, d=ring_width);
                }
            }
        }
        reflect_x(){
            translate_x(hole_sep/2){
                no2_selftap_clearancehole(center=true);
            }
        }
    }
}

// A disc with clearance for the board mounting holes
// This should be cut from a sheet of polycarbonate
// It's easy enough to do by hand but we should
// generate a DXF so it can be laser cut, I think
function diffuser_thickness()=0.5;
module diffuser(thickness=diffuser_thickness()){
    $fn=32;
    diameter = 14.5;
    hole_sep = illumination_mounting_hole_sep();
    difference(){
        cylinder(h=thickness, d=diameter);
        reflect_x(){
            translate_x(hole_sep/2){
                no2_selftap_clearancehole(center=true);
            }
        }
    }
}

module condenser_led_holder(led_r=4.5/2){
    difference(){
        cylinder(h=4, d=15);
        translate_z(-2*tiny()){
            cylinder(d=led_r*2+0.5, h=5, $fn=32);
        }
        translate_z(1){
            reflect_x(){
                translate_x(illumination_mounting_hole_sep()/2){
                    no2_selftap_counterbore(tight=true);
                }
            }
        }
    }
}