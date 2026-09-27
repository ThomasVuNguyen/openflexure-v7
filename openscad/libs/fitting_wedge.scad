

use <./utilities.scad>

module fitting_wedge(h, nose_width, nose_shift=0.2, y_depth=5, center=false){
    // A trapezoidal wedge that clamps can be clamped into a v-shape.
    // To enable clamping a nut trap must be suntracted from this shape
    // nose_shift moves the tip of the wedge in the -y direction
    // increasing the gap at the tip.
    // This wedge can be subtracted to make the v-shape mount. In this
    // case use a nose_shift < 0.

    nose_x = -nose_width/2-nose_shift;
    nose_y = nose_shift;
    nose_z = center ? -h/2 : 0;
    nose_position = [nose_x, nose_y, nose_z];
    // the back of the wedge is filleted
    fillet_rad = 2;
    mirror([0,1,0]){
        hull(){
            translate(nose_position){
                cube([nose_width+2*nose_shift, tiny(), h]);
            }
            reflect_x(){
                //translate cylinders to be hulled by the y_depth in x and y
                // to make 45 degree walls
                translate([y_depth + nose_width/2, y_depth, 0]){
                    // correct for size of cylinders.
                    translate([-1, 1, 0]*fillet_rad/sqrt(2)){
                        cylinder(r=fillet_rad, h=h, $fn=16, center=center);
                    }
                }
            }
        }
    }
}

module fitting_wedge_cutout(z_pos, y_stop=false, face_stops=false, nose_shift=0.2, max_screw=11, nose_width=undef, y_depth_max=10){
    // Subtract this from a fitting wedge, to cut out a hole for the nut
    // so that it can be anchored to a mount
    // y_stop if set true will also cut flush the faces of the mount in case something is
    // protruding.
    // face_stops if set true will cut flush the 45 degree faces in case something is
    // protruding. nose_width must  be set. if the y_dapth is greater than 10 y_depth_max
    // must be set to greater than the ydepth of the wedge

    module fitting_wedge_nut(shaft=false, nut_angle=0){
        // For convenience, this is the nut for the fitting wedge
        shaft_length = shaft ? max_screw-4 : 0;
        m3_nut_hole_y(h=2.6, extra_height=0.1, shaft_length=shaft_length, nut_angle=nut_angle);
    }

    translate([0, -3.7, z_pos]){
        fitting_wedge_nut(shaft=true, nut_angle=30);
        sequential_hull(){
            translate_z(-0.5){ // allow a little extra depth for the nut in the slot 
                fitting_wedge_nut(nut_angle=30);
            }
            translate_z(7){
                fitting_wedge_nut(nut_angle=30);
            }
            translate([0,10,7]){
                repeat([0,0,10],2){
                    fitting_wedge_nut(nut_angle=30);
                }
            }
        }
    }
    if(y_stop){
        translate([-10, -nose_shift, -99]){
            cube([20,20,199]);
        }
    }
    if(face_stops){
        reflect_x(){
            translate_y(nose_width/2){
                rotate_z(45){
                    cut_width = y_depth_max*2^.5;
                    translate([-cut_width, 0, -99]){
                        cube([2*cut_width,20,199]);
                    }
                }
            }
        }
    }
}