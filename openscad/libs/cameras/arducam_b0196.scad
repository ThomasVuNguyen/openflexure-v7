/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Arducam B0196 screw-on-from-bottm mount *
*         Sony IMX219 sensor, USB 'UVC' compliant                 *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines a camera mount (together with functions that  *
* return the mount height and sensor position) for the Arducam    *
* B0196 webcam.                                                   *
*                                                                 *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <../utilities.scad>
use <../libdict.scad>
use <./picamera_2.scad> // to use the sensor cutout, as it is the same sensor

$fn=48;

function arducam_b0196_camera_dict() = [["mount_height", 4.5],
                                        ["sensor_height", 2]];//Height of the sensor above the PCB

function arducam_b0196_camera_bottom_z() = -key_lookup("mount_height", arducam_b0196_camera_dict());

function arducam_b0196_corner_hole_spacing() = 28/2;
function arducam_b0196_sensor_hole_spacing() = 18/2;
function arducam_offset_y() = 2; // the sensor is offset towards the ribbom cable

module b0196(beam_h=9){
    //cut-out to fit Arducam B0196 webcam
    //optical axis at (0,0)
    //top of PCB at (0,0,0)

    // This module is designed to be subtracted from the bottom of a shape.
    // The z=0 plane should be the print bed.
    // It includes cut-outs for the components on the PCB and also a push-fit hole
    // for the camera module.  
    // mirror([0,0,1]){ //parts cut out of the mount are z<0

    mount_height = key_lookup("mount_height", arducam_b0196_camera_dict());
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

        //beam clearance
        cylinder(r=hole_r, h=beam_h);

        close_hole_xy = arducam_b0196_sensor_hole_spacing();
        //Component clearance
        translate_z(2/2-tiny()){
            difference(){
                union(){
                    // main block for clearance over 1.5mm components
                    translate_y(-arducam_offset_y()){
                        cube([31,31,2],center = true);
                    }
                    // stepped region to cope with bridging
                    translate([-4.5/2+31/2,-arducam_offset_y(),0]){
                        cube([4.5,31,4],center = true);
                    }
                    translate([+4.5/2-31/2,-arducam_offset_y(),0]){
                        cube([4.5,31,4],center = true);
                    }
                }
                union(){
                    // part surrounding camera
                    cube([15,15,3], center = true);
                    translate([-6.8,3.5,0]){
                        cube([3,22,3],center = true);
                    }
                    translate([+8,-5,0]){
                        cube([16,5,5],center = true);
                    }
                    // pillars at mounting points
                    translate_y(-arducam_offset_y()){
                         reflect_x(){
                                translate([close_hole_xy,0,0]){
                                    cylinder(d=5, h=99,center = true);
                                }
                            }
                        }
                    // bar at top and part at bottom
                    translate([0,(7.0/2)-38/2-arducam_offset_y(),0]){
                        cube([34,7.0,5],center = true);
                    }
                    translate([0,-(7.0/2)+38/2-arducam_offset_y(),0]){
                        difference(){
                            cube([34,7.0,5],center = true);
                            cube([(38-16),9.0,6],center = true);
                        }
                    }
                }
            }
        }
    }
}

//b0196();
arducam_b0196_camera_mount();
//picam2_cutout();

module arducam_rounded_block(b=33, w=33, h=6, roc = 2){
    // a rounded block with the dimensions of the inner board of the Arducam B0196
    // slot cutouts on the corners above 1mm+tiny
    // centred on the origin
    linear_extrude(h){
        hull(){
            reflect([1,0]){
                reflect([0,1]){
                    translate([w/2-roc, b/2-roc]){
                        circle(r=roc,$fn=20);
                    }
                }
            }
        }
    }
}

module arducam_b0196_camera_mount(screwhole=true){
    // A mount for the Arducam B0196 USB camera
    // This should finish at z=0+tiny(), with a surface that can be
    // hull-ed onto the lens assembly.
    w = 33;
    b = 33;

    mounting_hole_xy = arducam_b0196_corner_hole_spacing();

    mount_height = key_lookup("mount_height", arducam_b0196_camera_dict());
    rotate(-45){
        difference(){
            translate([0*-w/2, 0*-b/2 -arducam_offset_y(), -mount_height]){
                arducam_rounded_block(w=w, b=b, h=mount_height, roc=3.5);
            }
            translate_z(-mount_height){
                b0196();
                // mounting holes at the four corners
                if(screwhole){
                    translate_y(-arducam_offset_y()){
                        reflect_x(){
                            reflect_y(){
                                translate([mounting_hole_xy, mounting_hole_xy,0]){
                                    no2_selftap_hole(h=6);
                                    // chamfer in base to overcome overextrusion
                                    translate_z(-0.5){
                                        cylinder(r1=2,h=2,r2=0,$fn=12);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// Counterbore mounting holes for the lens spacer to screw on from above
module b0196_counterbore(){
    // clearance holes
    translate_z(arducam_b0196_camera_bottom_z()-1){
        at_b0196_hole_pattern(){
            cylinder(r=1.25, h=9, $fn=12);
        }
    }
    // counterbore holes, nomminally diameter 4.5, print at 4 to fit screw heads
    translate_z(arducam_b0196_camera_bottom_z()+1.5){
        at_b0196_hole_pattern(){
            cylinder(r=2.25, h=9, $fn=12);
        }
    }
    // Enlarged countebore for screwdriver, nominally diameter 5.5
    translate_z(arducam_b0196_camera_bottom_z()+4){
        at_b0196_hole_pattern(){
            cylinder(r=2.75, h=9, $fn=12);
        }
    }
}

module b0196_camera_bottom_mounting_posts(optics_config, outers=true, cutouts=true, bottom_slice=false){
    if (bottom_slice){
        //if we want the bottom slice intersect with the bottom of the whole
        //post found by recalling the function
        intersection(){
            cylinder(h=tiny(), r=99);
            b0196_camera_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts);
        }
    }
    else{
        // posts to mount to arduino B0196 camera from below
        r1=3;
        r2=2.5;
        h = key_lookup("mounting_post_height", optics_config);
        at_b0196_hole_pattern(){
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

module at_b0196_hole_pattern(){

    screw_xy = arducam_b0196_corner_hole_spacing();
    close_screw_xy = arducam_b0196_sensor_hole_spacing();
    mount_holes = [[screw_xy,screw_xy,0],
                    [-screw_xy,-screw_xy,0],
                    [close_screw_xy,0,0],
                    [-close_screw_xy,0,0]];
    rotate(-45){
        translate_y(-arducam_offset_y()){
            for(pos=mount_holes){
                translate(pos){
                    children();
                }
            }
        }
    }
}
