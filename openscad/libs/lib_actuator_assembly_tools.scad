use <./utilities.scad>
use <./libdict.scad>
use <./compact_nut_seat.scad>

$fn=16;
/**
* Height of the band insertion tool holder
*/
function holder_height() = 20;


/**
* The height to get the band over the actuator. This is the
* actuator height plus the diameter of the band cord.
*/
function height_over_actuator(params) = let(
    actuator_h = key_lookup("actuator_h", params)
) actuator_h +2;


/**
* A block with rounded corners and a dimple to make it nice to hold when turning
*/
module holding_block(dims=[40, 14, 10]){
    corner_r = 3;
    translate_z(dims.z/2){
        difference(){
            //cube with rounded sides
            hull(){
                x_shift = (dims.x/2-corner_r);
                y_shift = (dims.y/2-corner_r);
                for (x_tr = [-1, 1]*x_shift, y_tr = [-1, 1]*y_shift){
                    translate([x_tr, y_tr]){
                        cylinder(r=corner_r, h=dims.z, center=true, $fn=12);
                    }
                }
            }
            reflect_x(){
                translate_x(dims.x/2+15-.5){
                    cylinder(h=dims.z+1, r=15, center=true, $fn=36);
                }
            }
        }
    }
}


module tool_handle_end_cross_section(){
    translate_x(-actuator_nut_slot_size().x/2){
        cube([actuator_nut_slot_size().x, tiny(), actuator_nut_slot_size().z]);
    }
}

/**
* This is the back of the nut tool handle. It has a rounded sloped shape
*/
module sloped_back_of_handle(w, h){
    radius = 1.5;
    translate([0, radius, radius]){
        rotate_x(-30){
            hull(){
                reflect_x(){
                    translate_x(w/2 - radius){
                        sphere(r=radius);
                        translate_z(h-2*radius){
                            sphere(r=radius);
                        }
                    }
                }
            }
        }
    }
}

module nut_tool_handle(length){
    //width of the handle
    w = actuator_nut_size()*1.1+4;

    difference(){
        sequential_hull(){
            sloped_back_of_handle(w, 8);
            translate([-w/2, 13, 0]){
                cube([w,tiny(),actuator_nut_slot_size().z]);
            }
            translate([-w/2, 16, 0]){
                cube([w,tiny(),actuator_nut_slot_size().z]);
            }
            translate_y(length){
                tool_handle_end_cross_section();
            }
        }
    }
}

module nut_tool_end(){
    // width and height of tool tip (needs to fit through the slot of size
    // actuator_nut_slot_size())
    w = actuator_nut_slot_size().x-0.6;
    h = actuator_nut_slot_size().z-0.7;
    l = 5+actuator_housing_xy_size().y/2+3;

    difference(){
        sequential_hull(){
            tool_handle_end_cross_section();
            translate([-w/2, 5, 0]){
                cube([w, tiny(), h]);
            }
            translate([-w/2, l, 0]){
                cube([w, tiny(), h]);
            }
        }

        //cut out for nut
        translate([0,l,-tiny()]){
            rotate(30){
                cylinder(r=actuator_nut_size()*1.15, h=999, $fn=6);
            }
        }
        //extra cylindrical cut out in the nut vertex
        translate([0,l-actuator_nut_size()*1.15+0.4,-tiny()]){
            cylinder(r=1,h=999,$fn=12);
        }
    }

}

module nut_tool(){

    handle_l = actuator_housing_xy_size().x/2+9; //length of handle part

    translate_y(-(handle_l-tiny())){
        nut_tool_handle(handle_l);
    }
    nut_tool_end();

}

function band_tool_arm_length(params) = let(
    foot_height = key_lookup("foot_height", params)
) height_over_actuator(params)+foot_height+holder_height();

module prong_frame(params){
    //Move the prongs out and tilt them slightly
    sparse_matrix_transform(xz=0.3, xt=1.9, yt=band_tool_arm_length(params)){
        children();
    }
}



/**
* The position of the bottom of the slot in the end of the band tool given
* in the frame of the prong.
*/
function blade_anchor_pos() = [0,-12,0];
function band_tool_end_support_t() = 0.5;
function band_tool_blade_w() = 1.5;

/**
* Creates points for the blades that support the band in the band tool
*/
module blade_point(pos, d1=band_tool_blade_w(), d2=band_tool_blade_w(), h=tiny()){
    union(){
        translate(blade_anchor_pos() + [0,0,pos.z]){
            cylinder(d=d1, h=h);
        }
        translate(pos){
            cylinder(d=d2, h=h);
        }
    }
}

/**
* Create the end of the band tool. This is the two blades and the support between them
*/
module band_tool_end(params, h){
    // the two "blades" that support the band either side of the hook actuator
    reflect_x(){
        prong_frame(params){
            sequential_hull(){
                blade_point([0,band_tool_blade_w(),0], h=band_tool_end_support_t());
                blade_point([0,0,h-1]);
                blade_point([0.3,0.5,h-tiny()],d2=2.1);
            }
        }
    }
    // the flat support that passes between the hook and the outside of the column
    hull(){
        reflect_x(){
            //bottom of the tip
            prong_frame(params){
                translate_y(band_tool_blade_w()){
                    cylinder(d=band_tool_blade_w(), h=band_tool_end_support_t());
                }
                translate(blade_anchor_pos()){
                    cylinder(d=band_tool_blade_w(), h=band_tool_end_support_t());
                }
            }
        }
    }
}

/**
* Create just the arm of the band tool. This does not yet have the end
*/
module band_tool_arm(params, h){
    hull(){
        reflect_x(){
            prong_frame(params){
                translate(blade_anchor_pos()){
                    translate([0,10,0]){
                        cylinder(d=band_tool_blade_w(),h=h);
                    }
                    translate([0,0,0]){
                        cylinder(d=band_tool_blade_w(),h=h-1.5);
                    }
                }
            }
        }
        scale([0.8,0.8,1]) {
            tool_handle_end_cross_section();
        }
    }
    translate_z(1){
        cube([1,40,3]);
    }
}

/**
* Create the cut_out in the end of the band tool arm so that it supports
* blades and neatly slopes up to the handle
*/
module band_tool_end_cut_out(params, h){
    sloped_wall_pos = [band_tool_blade_w()-tiny(), 10, band_tool_end_support_t()-tiny()];
    hull(){
        reflect_x(){
            prong_frame(params){
                translate(blade_anchor_pos() + [-2.25,3,h]){
                    sphere(r=band_tool_blade_w());
                }

                translate(blade_anchor_pos() + sloped_wall_pos){
                    cube([band_tool_blade_w()/2,999,999]);
                }
            }
        }
    }
}

/**
* Create one full arm of the band tool including the end
*/
module band_tool_arm_with_end(params, h){
    band_tool_end(params, h);
    // connect the  end of the tool to the handle
    difference(){
        band_tool_arm(params, h);
        band_tool_end_cut_out(params, h);
    }

}

function band_tool_arm_sep(h=4) = 2*column_base_radius() + 2*h + 4;

function band_tool_end_thickness() = 4;

/*
Create the band tool for inserting the viton o-ring.

:param params: The microscope paramters dictionary
:param vertical: false for printing position, true for position in tool
:param grow: Scale each arm by 1.1 for using as a cutout, only used if vertical=true
    flex. Only used if vertical=true
*/
module band_tool_arms(params, vertical=false, grow=false){
    // height of the prong-end of the band insertion tool in print orientation
    h = band_tool_end_thickness();
    scale_factor = grow ? 1.1 : 1;
    if (vertical){
        reflect_y(){
            translate_y(band_tool_arm_sep()/2){
                rotate_x(90){
                    scale(scale_factor){
                        band_tool_arm_with_end(params, h);
                    }
                }
            }
        }
    }
    else{
        // We make two tools, spaced out by 2mm
        reflect_y(){
            translate_y(1){
                band_tool_arm_with_end(params, h);
            }
        }
    }
}


/* The band tool holder is the base, into which the arms fit.
 * 
 * Its top is at z=holder_height(), and the bottom of the arms
 * is at z=0. This means the bottom of the tool is at about z=-4.5.
 * It should be printed upside down.
 */
module band_tool_holder_body(params){
    intersection(){
        // The basic shape is formed by the band tool, enlarged by holder_offset
        minkowski(){
            translate_z(-3.8){
                hull(){
                    band_tool_arms(params, vertical=true);
                }
            }
            scale ([0.7,0.7,1]){
                sphere(r = 1.7);
            }
        }
        // We cut it off above holder_height() so the arms protrude upwards
        translate ([-99/2,-99/2,-99]){
            // We use a "big" cube but not so huge the render camera is inside it, to
            // avoid OpenSCAD rendering glitches.
            cube([99,99,99 + holder_height()], center = false);
        }
    }
}

module band_tool_holder(params){
    difference(){
        band_tool_holder_body(params);
        band_tool_arms(params, vertical=true, grow=true);
    }
}