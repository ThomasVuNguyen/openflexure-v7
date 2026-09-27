/******************************************************************
*                                                                 *
* OpenFlexure Microscope: USB camera push-fit mount               *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines one useful function, usbcam_push_fit().  It's *
* designed to be subtracted from a solid block, with the bottom   *
* of the block at z=0.  It grips the plastic camera housing with  *
* a "trylinder" gripper, holding it in securely.  It might be     *
* that you need a cover or something to secure the camera fully.  *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <../utilities.scad>
use <../libdict.scad>
use <./m12.scad>


$fn=32;

//Same as the M12 camera
function 6led_camera_dict() = m12_camera_dict();


module 6led_camera_mount(){ //this is the same as the M12 mount
    m12_camera_mount();
}


module 6led_bottom_mounting_posts(optics_config, outers=true, cutouts=true, bottom_slice=false){

    if (bottom_slice){
        //if we want the bottom slice intersect with the bottom of the whole
        //post found by recalling the function
        intersection(){
            cylinder(h=tiny(), r=99);
            6led_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts);
        }
    }
    else{
        r1=3;
        r2=2;
        h=key_lookup("mounting_post_height", optics_config);
        at_6led_hole_pattern(){
            difference(){
                if(outers){
                    cylinder(r1=r1, r2=r2, h=h, $fn=12);
                }
                if(cutouts){
                    translate_z(-2){
                        rotate(75){
                            trylinder_selftap(2, h=h+3);
                        }
                    }
                }
            }
        }
    }
}

module at_6led_hole_pattern(){
    //holes are (28-2.25*2)=23.5mm apart in Y and (33-4.45*2)=24.1mm apart in X
    x_sep = 24.1;
    y_sep = 23.5;

    rotate(45){
        reflect_x(){
            reflect_y(){
                translate([x_sep/2, y_sep/2, 0]){
                    children();
                }
            }
        }
    }
}