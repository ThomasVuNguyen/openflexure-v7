/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Riser to mount sample slightly higher   *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/


use <./libs/utilities.scad>
use <./libs/main_body_structure.scad>
use <sample_clips.scad>
use <./libs/main_body_transforms.scad>
use <./libs/microscope_parameters.scad>

$fn=24;

function slide_dims() = [75.8,25.8,1.0];

module slide_riser_base(params, h, thickness, y_space){
    difference(){

        xy_stage(params, h=thickness,on_buildplate=true);

        //angled cut-out for slide
        hull(){
            translate_z(h){
                translate([0,-slide_dims().z,tiny()/2]){
                    cube([slide_dims().x,slide_dims().y,tiny()], center=true);
                }
                translate([0,999-slide_dims().z,999+tiny()/2]){
                    cube([slide_dims().x,slide_dims().y,tiny()], center=true);
                }
            }
        }
        //extra cutout on clip side
        translate([-999/2,0,h]){
            cube([999,slide_dims().y/2+y_space,999]);
        }

        //cut-out for middle of slide (immersion oil, etc.)
        translate([-999/2,-slide_dims().y/2+2, h-2]){
            cube([999,slide_dims().y-4,999]);
        }
    }
}


module slide_riser(params, h=.6, thickness=4){
    y_space = 1.5;
    clip_l = 30;
    clip_w = 7;
    clip_r = 12;
    // Distance clip overlaps with slide position.
    // This is reduced by the tilted cutout:
    clip_overlap = 5;
    clip_y = clip_overlap+y_space;
    clip_angle_h = 1+h+slide_dims().z;
    handle_end = 75;
    difference(){
        union(){
            difference(){
                union(){
                    slide_riser_base(params, h,thickness, y_space);
                    // This is the bar that froms the stationary handle.
                    // It is very long and will be cut down later.
                    translate([-999+30,slide_dims().y/2+y_space,0]){
                        cube([999,9,12]);
                    }
                }

                //space for clip to push through
                translate([-slide_dims().y/2+2,0, -1]){
                    cube([slide_dims().y-4,999,clip_w+3]);
                }

                //counter bored mounting holesmounting holes
                each_leg(params){
                    translate_y(-stage_hole_inset()){
                        cylinder(r=3/2*1.15,h=999,center=true);
                        translate_z(thickness+tiny()){
                            cylinder(r=3*1.15,h=999);
                        }
                    }
                }
            }
            //Clip and handle
            translate([-clip_l+4,slide_dims().y/2+y_space,0]){
                difference(){
                    translate_z(clip_w/2){
                        rotate_x(-90){
                            rotate_z(-90){
                                sample_clip([0,clip_l,-clip_y], w=clip_w, radius_of_curvature=clip_r);
                            }
                        }
                    }
                    translate_y(-clip_y+clip_angle_h){
                        rotate_x(45){
                            translate([clip_l,-5,0]){
                                cube([10,10,10], center=true);
                            }
                        }
                    }
                }
                translate([-999+7,slide_dims().y/2+y_space+clip_r-2,0]){
                    cube([999,9,7]);
                }
            }
        }
        // cut off end of the super long handles
        translate_x(-999/2-handle_end){
            cube([999,999,999],center=true);
        }
    }
}

module slide_riser_stl(){
    params = default_params();
    h=.6;
    slide_riser(params, h);
}

slide_riser_stl();