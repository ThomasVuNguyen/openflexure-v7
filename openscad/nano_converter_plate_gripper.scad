
use <../openscad/libs/utilities.scad>

rotate_y(90){
    nano_converter_plate_gripper();
}

module nano_converter_plate_gripper(){

    // defining temporary module for cylinder that
    // will print better when turned sideways
    module cyl_rot(d, h, center=false){
        $fn=8;
        rotate_z(22.5){
            cylinder(d=d, h=h, center=center);
        }
    }
    // and another for a hemisphere sphere
    module semi_sph_rot(d){
        $fn=8;
        rotate_z(22.5){
            difference(){
                sphere(d=d);
                cylinder(d=2*d,h=2*d);
            }
        }
    }
    bridge_h = 3;
    bridge_t = 2;
    h_diff = 1.5;
    centre2centre_d = 29;
    cyl_d = 9;
    difference(){
        union(){
            translate_z(h_diff){
                cyl_rot(d=cyl_d, h=bridge_h-h_diff+tiny());
            }
            sequential_hull(){
                translate([0, -centre2centre_d, cyl_d/2]){
                    semi_sph_rot(d=cyl_d);
                }
                translate([0, -centre2centre_d, bridge_h]){
                    cyl_rot(d=cyl_d, h=bridge_t);
                }
                translate_z(bridge_h){
                    cyl_rot(d=cyl_d, h=bridge_t);
                }
            }
        }

        translate_z(1.5+h_diff){
            no2_selftap_counterbore();
        }
    }
}