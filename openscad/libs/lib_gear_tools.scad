use <utilities.scad>
use <gears.scad>
use <lib_actuator_assembly_tools.scad>

module nut_spinner(){
    h = 16;
    difference()
    {
        union(){
            hull(){
                cylinder(r=5, h=h, $fn=6);
                reflect_x(){
                    translate([6,0,10]){
                        rotate_x(90){
                            cylinder(r=6, h=3, $fn=16, center=true);
                        }
                    }
                }
            }
            cylinder(r1=6, r2=3, h=8, $fn=16);
        }
        translate_z(13){
            m3_nut_hole(h=99, shaft=true, tight=true);
        }
    }
}


module gear_holder(ratio=2){
    dims = [40, 14, 10];
    gear_r = large_gear_pitch_radius(ratio);
    difference(){
        holding_block(dims);
        translate_z(dims.z/2){
            loose_large_gear_profile(height=10, ratio=ratio);
        }
        // Cut out sides for low ratios, to avoid small pillars
        if (ratio < 1.4){
            cut_r = 2*gear_r;
            reflect_y(){
                translate_y(cut_r+5){
                    cylinder(r=cut_r, h=3*dims.z, center=true);
                }
            }
        }
    }
}

module labelled_gear_holder(ratio=2){
    r_text = str(ratio,":1");
    difference(){
        gear_holder(ratio=ratio);
        translate_z(4.5){
            linear_extrude(10){
                text(r_text, valign="center", halign="center", size=4);
            }
        }
    }
}
