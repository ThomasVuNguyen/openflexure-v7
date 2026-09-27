/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Logitech C270 screw-on-from-bottm mount *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines a camera mount (together with functions that  *
* return the mount height and sensor position) for the Logitech   *
* C270 webcam.                                                    *
*                                                                 *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <../utilities.scad>
use <../libdict.scad>

$fn=48;

function c270_camera_dict() = [["mount_height", 4.5],
                               ["sensor_height", 0.2]];//Height of the sensor above the PCB

function c270_camera_bottom_z() = -key_lookup("mount_height", c270_camera_dict());

// spacing of the lens mount holes at the sensor
function c270_camera_hole_spacing() = 8.25;
// position of camera board hole near the sensor
function c270_near_third_hole_pos() = [5,-9.5,0];
// position of camera board hole at the cable end
function c270_far_third_hole_pos() = [-6,42.3,0];


module c270_cutout(beam_r=4.3, beam_h=4.5, cover=true){
    //cut-out to fit Logitech C270 webcam
    //optical axis at (0,0)
    //top of PCB at (0,0,0)

    mirror([0,0,1]){ //parts cut out of the mount are z<0
        //beam clearance
        hull(){
            cube([8,8,6],center=true);
            translate_z(-beam_h){
                cylinder(r=beam_r,h=2*tiny(),center=true);
            }
        }
        // with a cover below the camera, make the cut-out a bit longer
        cut_pos = (cover)? 27 : 25;

        difference(){
            union(){
                // component clearance, cable end
                translate([0, cut_pos, 15-3.5]){
                    rotate_y(180){
                        round_top_cube([19.5, 37, 15],1.5,center=true);
                    }
                }
                // component clearance, sensor end
                hull(){
                    translate([0, 5, 4]){
                        cube([19.5, 18, 15],center=true);
                    }
                    translate([0, -4, 4]){
                        cube([9, 9.5*2, 15],center=true);
                    }
                }
            }
            union(){
                // add cube at third mounting hole, cable end
                translate(c270_far_third_hole_pos()-[0,0,10]){
                    cylinder(d=5, h=10);
                }
                // add a pillar at the 'near third hole' place
                translate(c270_near_third_hole_pos()){
                    translate_z(-50){
                        cylinder(r=3, h=99, center = false);
                    }
                }
                // add mount around the camera sensor,
                // the same shape as the supplied lens mount
                cube([14,14,99], center = true);
                cube([21,5,99], center = true);
            }
        }
    }
}

function c270_dims() = [21, 58];
function c270_y_offset() = -13; // position of the edge of the main body of lens spacer
//extra room for cable
function c270_mount_y_excess() = 8;

function c270_backshell_screw_positions(flip_x=false) = let(
    h = c270_dims().y,
    w = c270_dims().x,
    y_offset = c270_y_offset(),
    y_excess = c270_mount_y_excess(),
    y_pos = h+y_offset+y_excess-4,
    sign = flip_x ? 1 : -1
) [[sign*(-w/2+4), y_pos, 3], [sign*(w/2-4), y_pos, 3]];

module c270_camera_mount(screwhole=true){
    // A mount for the Logitech C270 webcam
    // This should finish at z=0+tiny(), with a surface that can be
    // hull-ed onto the lens assembly.

    // camera dims
    h = c270_dims().y;
    w = c270_dims().x;
    //wider_ section around lens
    h_w = 26;
    w_w = 23.5;

    y_offset = c270_y_offset();
    // extra room for cable if the mount has a cover below
    // when the screwholes are present from below
    y_excess = (screwhole)? 0 : c270_mount_y_excess();

    mount_height = key_lookup("mount_height", c270_camera_dict());
    rotate(-45){
        difference(){
            union(){
                // Cube over sensor for hulling to the lens mount, slightly raised
                // because the spheres making the round top are cut off in the STL representation
                translate([-w_w/2, y_offset-2, -mount_height]){
                    round_top_cube([w_w, h_w+4, mount_height+2*tiny()], 2, $fn=16);
                }
                // Cube over the rest of the board, slightly lower down so that it
                // is not used for the lens mount.
                translate([-w/2, y_offset+y_excess, -mount_height]){
                    round_top_cube([w, h, mount_height-2*tiny()], 2, $fn=16);
                }
            }
            translate_z(-mount_height){
                // if there are screwholes from below, there is no cover below
                c270_cutout(cover=!screwhole);
                c270_self_tap_screwholes(screwhole=screwhole);
            }
            c270_backshell_self_tap_screwholes();
        }
    }
}

module c270_self_tap_screwholes(screwhole){
    mount_height = key_lookup("mount_height", c270_camera_dict());
    if(screwhole){
        // Self tap mounting holes for camera
        reflect_x(){
            translate_x(c270_camera_hole_spacing()){
                no1_selftap_hole(h=6);
                // chamfer in base to overcome overextrusion
                translate_z(-0.5){
                    cylinder(r1=2,h=2,r2=0,$fn=12);
                }
            }
        }
    }
    // third mounting hole, cable end
    translate(c270_far_third_hole_pos()){
        // hole depth does not extend through the top of the mount
        no1_selftap_hole(h=mount_height-0.6);
        // chamfer in base to overcome overextrusion
        translate_z(-0.5){
            cylinder(r1=2,h=2,r2=0,$fn=12);
        }
    }
}

module c270_backshell_self_tap_screwholes(){
    mount_height = key_lookup("mount_height", c270_camera_dict());
    for (i = [0, 1]){
        translate(c270_backshell_screw_positions()[i]){
            translate_z(-mount_height-5.5){
                no2_selftap_hole(h=6);
            }
        }
    }
}

module c270_backshell(){
    // This whole element is rotated 180 degrees about x when in place
    // y here becomes -y
    // z here becomes -z 

    height = 6;
    h = c270_dims().y;
    w = c270_dims().x;

    y_offset = c270_y_offset(); // y offset is -ve

    //extra room for cable
    y_excess = c270_mount_y_excess();

    difference(){
        //The main block
        end_from_centre = 3; // distance from axis of end of the cover
        cover_length = h + y_offset + y_excess - end_from_centre;
        difference(){
            translate([-w/2, 0, 0]){
                round_top_cube([w, cover_length+end_from_centre, height], 2, $fn=16);
            }
            cube([2*w, 2*end_from_centre, 99], center=true);
        }

        // cut out space for PCB
        translate([-(w+1)/2, y_offset, -tiny()]){
            cube([w+1, h, 1+tiny()]);
        }

        difference(){
            //Hollow out main block
            union(){
                translate([-(w-3)/2, -tiny(), -1.5]){
                    cube([w-3, h+y_offset+y_excess-2, height]);
                }
                // A tiny bit more space for cable
                translate([-w/2+.7, y_offset+h-12, -1.5]){
                    cube([10, 10, height]);
                }
            }
            // Subtract (from the hollowing-out subtraction) stand offs
            // for the backshell.
            for (i = [0, 1]){
                translate(c270_backshell_screw_positions(flip_x=true)[i]){
                    cylinder(d=7, h=2*height, center=true);
                }
            }
        }
        for (i = [0, 1]){
            translate(c270_backshell_screw_positions(flip_x=true)[i]){
                mirror([0,0,1]){
                    no2_selftap_counterbore(flip_z=true, tight=true);
                }
            }
        }

        //wire cutout
        cube([5, 50, h], center=true);
    }
}

/* A module currently not used. If split in half it can clamp
around the block at the end of C270 cable & e-clip
*/
module c270_cable_exit(){
    translate_y(-5/2){
        cube([14, 5, 6.5], center=true);
    }
    rotate_y(90){
        cylinder(d=6.5, h=14, center=true);
    }
    translate_x(3){
        cube([1, 10, 10], center=true);
    }
    cube([25, 4, 4], center=true);
}

module c270_counterbore(){
    translate_z(c270_camera_bottom_z()-1){
        at_c270_hole_pattern(){
            cylinder(r=1.1, h=9, $fn=12);
        }
    }
    translate_z(c270_camera_bottom_z()+1){
        at_c270_hole_pattern(){
            cylinder(r=2.1, h=9, $fn=12);
        }
    }
}

module c270_camera_bottom_mounting_posts(optics_config, outers=true, cutouts=true, bottom_slice=false){
    if (bottom_slice){
        //if we want the bottom slice intersect with the bottom of the whole
        //post found by recalling the function
        intersection(){
            cylinder(h=tiny(), r=99);
            c270_camera_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts);
        }
    }
    else{
        // posts to mount to Logitech C270 camera from below
        r1=3;
        r2=2.5;
        h = key_lookup("mounting_post_height", optics_config);
        at_c270_hole_pattern(){
            difference(){
                if(outers){
                    cylinder(r1=r1, r2=r2, h=h, $fn=12);
                }
                if(cutouts){
                    translate_z(h-6+tiny()){
                        // The C270 board holes are smaller than #2 screws
                        no1_selftap_hole(h=6);
                    }
                }
            }
        }
    }
}

module at_c270_hole_pattern(){
    // posts to mount to Logitech C270 camera from below

    screw_x = c270_camera_hole_spacing();
    // Third hole position at the far end of the board [-6,42.3,0] is too far away and makes 
    // the camera platform too big for mounting from above.
    //c270_third_hole_pos = [5,-9.5,0];
    rotate_z(-45){
        reflect_x(){
            translate([screw_x, 0, 0]){
                children();
            }
        }
        translate(c270_near_third_hole_pos()){
            children();
        }
    }
}
