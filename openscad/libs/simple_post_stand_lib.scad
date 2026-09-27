// LibFile: utilities.scad
//   The functions to build the post stand that is used for mounting the manual microscope
//   It is just two posts the height of the feet for the back microscope lugs, connected
//   by a curved wall.

use <./utilities.scad>
use <./microscope_parameters.scad>
use <./compact_nut_seat.scad>
use <./main_body_transforms.scad>
use <./main_body_structure.scad>
use <./libdict.scad>

// Function: simple_post_stand_post_height()
// Usage: simple_post_stand_post_height(params)
// Descriprtion:
//    Sets the post height to ensure the microscope sits level/
function simple_post_stand_post_height(params) = key_lookup("foot_height",params);


// Module: simple_post_stand()
// Usage: simple_post_stand(params, wall_height=10, fixing_lugs=true);
// Description: 
//   Builds posts to fit under main body mointing points, to use instead of a complete base.
//   Cable tie loops are included on the legs under the stage.
// Arguments:
//   params = microscope parameters dictionary
//   ---
//   wall_height = the height of a wall that runs between the "back" legs, around stage,
//       to stop tipping.
//   fixing_lugs = Boolean to add fixing lugs for attaching the stand to a base/table. Default=true
module simple_post_stand(params, wall_height=10, fixing_lugs=true){
    //The posts are for the back lugs of the microscope so we set type to "back"
    hole_pos = base_mounting_holes(params,type="back");

    // a post at each mounting foot position
    for (n = [0:len(hole_pos)-1]){
        hole = hole_pos[n];
        angle = lug_angles(params)[n];
        microscope_mounting_post(params, hole_pos=hole, lug_angle=angle, fixing_lugs=fixing_lugs);
    }

    // wall around stage base to prevent toppling, joining the two "back" posts
    curved_mount_back_wall(params, wall_height=wall_height);
}

module microscope_mounting_post(params, hole_pos, lug_angle, fixing_lugs=false){
    post_height = simple_post_stand_post_height(params);
    base_d=20;
    top_d=10;
    difference(){ // difference to cut off the leg parts from xy lugs
        translate(hole_pos){
            cylinder(d1=base_d, d2=top_d, h=post_height+2, $fn=32);
            if (hole_pos.y<0) { // cable ties and screw mounts on back posts only
                tie_offset = -0.5 + (top_d + base_d)/4;
                cable_tie_point_x = (hole_pos.x)>0? -tie_offset : tie_offset ;
                translate([cable_tie_point_x,0,-0.5+post_height/2]){
                    rotate([90,0,0]){
                        tube(ro=8.5/2, ri=6/2, h=3, $fn=32);
                    }
                }
                if (fixing_lugs) {
                    screw_offset = (base_d/2)+4;
                    screw_translate = (hole_pos.x)>0? -screw_offset : screw_offset ;
                    screw_angle = 35;
                    screw_rotate = (hole_pos.x)>0? screw_angle : -screw_angle ;
                    screw_mounting_plate(screw_rotate=screw_rotate, screw_translate=screw_translate);
                }
            }
        }
        translate(hole_pos){
            translate_z(post_height){
                m3_lug([0,0,0], lug_angle, holes=false);
            }
            translate_z(post_height-9){
                m3_nut_trap_with_shaft(lug_angle+180);
            }
        }
        if (hole_pos.y>0) { // cut out on front posts only
            reflect_x(){
                y_actuator_frame(params){
                    screw_seat_outline(h=999,adjustment=+tiny(),center=true);
                }
            }
        }
    }
}

module screw_mounting_plate(screw_rotate, screw_translate){
    rotate_z(screw_rotate){
        difference(){
            hull(){
                translate_x(screw_translate){
                    cylinder(r=4, h=1.5, $fn=32);
                }
                cylinder(r=4, h=1.5, $fn=32);
            }
            translate_x(screw_translate){
                cylinder(r=4/2, h=1.5*2.5, center=true, $fn=32);
            }
        }
    }
}

module curved_mount_back_wall(params, wall_height){
    post_height = simple_post_stand_post_height(params);
    back_hole_pos = base_mounting_holes(params, type="back");
    difference(){
        wall_radius = sqrt((back_hole_pos[1].x)^2+(back_hole_pos[1].y)^2);
        wall_d = wall_radius*2 + 3;
        echo(wall_d);
        cylinder(d=wall_d, h=wall_height, $fn=64);
        translate_z(-tiny()){
            cylinder(d1=wall_d-10, d2=wall_d-1.5, h=wall_height+2*tiny(), $fn=64);
        }
        translate([-99/2,-5,-99/2]){
            cube(99);
        }
        // remember the nut clearances through the wall as well
        for (n = [0:len(back_hole_pos)-1]){
            back_hole = back_hole_pos[n];
            angle = lug_angles(params)[n];
            translate(back_hole){
                translate_z(post_height){
                    m3_lug([0,0,0], angle, holes=false);
                }
                translate_z(post_height-9){
                    m3_nut_trap_with_shaft(angle+180);
                }
            }
        }
    }
}
