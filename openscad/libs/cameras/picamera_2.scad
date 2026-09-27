/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Raspberry Pi Camera v2 push-fit mount   *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file provides two parts for the microscope; the bit that   *
* fits onto the camera (picam2_camera_mount) and a cover that     *
* protects the PCB (picam_cover).  The former is part of the      *
* optics module in optics.scad, and the latter is printed         *
* directly.                                                       *
*                                                                 *
* The fit is set by one main function, picam2_push_fit().  It's   *
* designed to be subtracted from a solid block, with the bottom   *
* of the block at z=0.  It grips the plastic camera housing with  *
* four slightly flexible fingers, which ensures the camera pops   *
* in easily but is held relatively firmly.  Two screw holes are   *
* also provided that should self-tap with M2 or similar screws.   *
* I recommend you use these for extra security if the camera is   *
* likely to be handled a lot.                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <../utilities.scad>
use <../libdict.scad>

function picamera_2_camera_dict() = [["mount_height", 4.5],
                                     ["sensor_height", 2]];//Height of the sensor above the PCB

function picamera_2_bottom_z() = -key_lookup("mount_height", picamera_2_camera_dict());

function picamera_2_hole_spacing() = 21;

module picam2_flex_and_components(camera_width=8.5+1){
    // A 2D perimeter inside which the flex and components of the camera sit.
    // NB this should fit both v1 and v2 of the module
    // camera_width is the width of the camera module's casing, nominally 8 or 8.5mm but
    // deliberately printed a bit generous to ensure it fits easily without
    // damaging the flex.

    //flex (also clears v1 connector)
    translate([-camera_width/2,camera_width/2-1]){
        square([camera_width,13.4-camera_width/2+1]);
    }
    //connector
    translate([-camera_width/2-2.5,6.7]){
        square([camera_width+2.5, 5.4]);
    }
}

module picam1_led(){
    // v1 of the camera module has an LED on board that we should make a cut-out for
    translate([5,10]){
        square([3.5,2]);
    }
    translate([6,8]){
        square([3.5,2]);
    }
}

module picam2_cutout( beam_length=15){
    // This module is designed to be subtracted from the bottom of a shape.
    // The z=0 plane should be the print bed.
    // It includes cut-outs for the components on the PCB and also a push-fit hole
    // for the camera module.  This uses flexible "fingers" to grip the camera firmly
    // but gently.  Just push to insert, and wiggle to remove.  You may find popping
    // off the brown ribbon cable and removing the PCB first helps when extracting
    // the camera module again.

    mount_height = key_lookup("mount_height", picamera_2_camera_dict());
    //width camera box (NOTE: this is deliberately loose fitting)
    camera_width = 8.5 + 1.0;
    //height of camera box (including foam support)
    camera_height=2.9;

    //size of camera aperture
    hole_r = 4.3;
    union(){
        sequential_hull(){
            //cut-out for camera (/wider at bottom)
            translate_z(-tiny()){
                cube([camera_width+0.5,camera_width+0.5,tiny()],center=true);
            }
            translate_z(0.5){
                cube([camera_width,camera_width,tiny()],center=true);
            }
            translate_z(camera_height/2){
                cube([camera_width,camera_width,camera_height],center=true);
            }
            cylinder(r=hole_r, h=2*mount_height, center=true);
        }

        //clearance for the ribbon cable at top of camera
        flex_h=2.5; // the height of the flex

        extra_h = mount_height-flex_h-0.75; // extra height above the flex for the sloping "roof"
        hull(){
            translate_z(-tiny()){
                linear_extrude(flex_h){
                    picam2_flex_and_components(camera_width);
                }
            }
            translate_z(-tiny()){
                linear_extrude(flex_h+extra_h){
                    offset(-extra_h){
                        picam2_flex_and_components(camera_width);
                    }
                }
            }
        }

        //clearance for the LED/resistor on v1 of the camera
        hull(){
            translate_z(-tiny()){
                linear_extrude(flex_h){
                    picam1_led();
                }
            }
            translate_z(-tiny()){
                linear_extrude(flex_h+extra_h){
                    offset(-extra_h){
                        picam1_led();
                    }
                }
            }
        }

        //beam clearance
        cylinder(r=hole_r, h=beam_length);

    }
}

module picam2_board(h=tiny()){
    // a rounded rectangle with the dimensions of the picamera board v2
    // centred on the origin
    b = 24;
    w = 25;
    roc = 2;
    linear_extrude(h){
        hull(){
            reflect([1,0]){
                reflect([0,1]){
                    translate([w/2-roc, b/2-roc]){
                        circle(r=roc,$fn=12);
                    }
                }
            }
        }
    }
}

module picamera_2_camera_mount(screwhole=true, counterbore=false){
    // A mount for the pi camera v2
    // This should finish at z=0+tiny(), with a surface that can be
    // hull-ed onto the lens assembly.
    b = 24;
    w = 25;
    difference(){
        rotate(45){
            translate_y(2.4){
                sequential_hull(){
                    translate_z(picamera_2_bottom_z()){
                        picam2_board(h=tiny());
                    }
                    translate_z(-1){
                        picam2_board(h=tiny());
                    }
                    cube([w-(-1.5-picamera_2_bottom_z())*2,b,tiny()],center=true);
                }
            }
        }
        rotate(45){
            translate_z(picamera_2_bottom_z()){
                picam2_cutout();
            }
        }
        if(counterbore){
            picamera_2_counterbore();
        }
        if(screwhole){
            picamera_2_screwholes();
        }
    }
}

module picamera_2_screwholes(){
    //chamfered screw holes for mounting
    screw_x = picamera_2_hole_spacing()/2;
    rotate_z(45){
        translate_z(picamera_2_bottom_z()){
            reflect_x(){
                translate_x(screw_x){
                    rotate_z(60){
                        translate_z(-tiny()){
                            no2_selftap_hole(h=10);
                        }
                    }
                }
            }
        }
    }
}

module picamera_2_counterbore(){
    translate_z(picamera_2_bottom_z()-1){
        at_picamera_2_hole_pattern(){
            cylinder(r=1.25, h=99, $fn=12);
        }
    }
    translate_z(picamera_2_bottom_z()+1){
        at_picamera_2_hole_pattern(){
            cylinder(r=2.8, h=99, $fn=12);
        }
    }
}

module picamera_2_bottom_mounting_posts(optics_config, outers=true, cutouts=true, bottom_slice=false){
    // posts to mount to pi camera from below
    
    if (bottom_slice){
        //if we want the bottom slice intersect with the bottom of the whole
        //post found by recalling the function
        intersection(){
            cylinder(h=tiny(), r=99);
            picamera_2_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts);
        }
    }
    else{
        h=key_lookup("mounting_post_height", optics_config);
        r1=3;
        r2=2;
        at_picamera_2_hole_pattern(){
            difference(){
                if(outers){
                    cylinder(r1=r1, r2=r2, h=h, $fn=12);
                }
                if(cutouts){
                    translate_z(h-6+tiny()){
                        no2_selftap_hole(h=6);
                    }
                }
            }
        }
    }
}

module at_picamera_2_hole_pattern(){
    // posts to mount to pi camera from below
    screw_x = picamera_2_hole_spacing()/2;
    rotate(45){
        reflect_x(){
            for(y=[0,12.5]){
                translate([screw_x, y, 0]){
                    children();
                }
            }
        }
    }
}

/////////// Cover for camera board //////////////
module picamera_2_cover(){
    // A cover for the camera PCB, slips over the bottom of the camera
    // mount.  This version should be compatible with v1 and v2 of the board
    h = 3;
    outer_size = [25, 21, h];
    //wall thickness
    t = 1;
    //position of the outer edge in y
    edge_y = 14.4;
    screw_x = picamera_2_hole_spacing()/2;
    box_tr = [-outer_size.x/2, edge_y-outer_size.y, 0];
    //cutout for connector is loose in x and huge in x/z
    connector_cutout = [21, 50, 50];
    //cutout should start 18mm from the back edge of the housing
    connector_y = edge_y - 18;
    difference(){
        union(){
            //bottom and sides
            difference(){
                translate(box_tr){
                    cube(outer_size);
                }
                // cut out centre to form walls on 3 sides
                translate(box_tr + [t, -t, 0.75]){
                    cube(outer_size - [2*t, 0, 0]);
                }
                // cut out for connector
                translate_y(connector_y-connector_cutout.y/2){
                    cube(connector_cutout, center=true);
                }
            }

            //Bulge for counterbore. (Slightly elongated cylinder)
            reflect_x(){
                translate_x(screw_x){
                    hull(){
                        cylinder(r=3.2, h=h, $fn=16);
                        translate_x(0.5){
                            cylinder(r=3.2, h=h, $fn=16);
                        }
                    }
                }
            }
        }
        //counterbore the mounting screws
        reflect_x(){
            translate([screw_x, 0, h-2]){
                intersection(){
                    cylinder(r=2.4, h=999, $fn=16, center=true);
                    hole_from_bottom(r=1.3, h=999, base_w=999, layers=2);
                }
            }
        }
    }
}


module generous_camera_bits(){
    //The other stuff on the PCB (mostly the ribbon cable)
    camera = [8.5,8.5,2.3]; //size of camera box
    camera_width = camera.x+1; //side length of camera box at bottom (slightly larger)
    union(){
        //ribbon cable at top of camera
        sequential_hull(){
            cube([camera_width-1,tiny(),4],center=true);
            translate_y(9.4-(4.4/1)/2){
                cube([camera_width-1,1,4],center=true);
            }
        }
        //flex connector
        translate([-1.25,9.4,0]){
            cube([camera_width-1+2.5, 4.4+1, 4],center=true);
        }
    }
}

module picamera_2_gripper(){
    // this little bit of plastic grips the plastic camera housing
    // and allows you to safely unscrew the lens
    // it protects the (surprisingly delicate) flex that connects the camera to the PCB.

    //size of the picam PCB (+0.5mm so it fits)
    pcb_dims = [25.4+0.5,24+0.5,2];
    //size of the pastic housing
    camera_housing = [9,9,2.5];
    //shift of the camera housing from the centre
    camera_housing_y_shift = 2.5;

    //size of the tool
    outer = pcb_dims+[4,-5,camera_housing.z];
    difference(){
        translate([0,-1,outer.z/2]){
            cube(outer, center=true);
        }

        //central hole for the camera housing
        translate_y(camera_housing_y_shift){
            cube(camera_housing + [0,0,999],center=true);
        }

        //cut-outs for the other bits (cable etc.)
        translate([0, camera_housing_y_shift, camera_housing.z]){
            rotate_x(180){
                generous_camera_bits();
            }
        }

        //indent for PCB
        translate_z(outer.z){
            cube(pcb_dims + [0,0,pcb_dims.z],center=true);
        }
    }
}

module picamera_2_lens_removal_tool(){
    //a tool to unscrew the lens from the pi camera
    inner_r = 4.7/2;
    union(){
        difference(){
            cylinder(r=7,h=2);
            cylinder(r=5,h=999,center=true);
        }
        for(a=[0,90,180,270]){
            rotate(a){
                translate_x(inner_r){
                    cube([1.5,5,2]);
                }
            }
        }
    }
}