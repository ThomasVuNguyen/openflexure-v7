
use <../libs/compact_nut_seat.scad>
use <../libs/utilities.scad>
use <../libs/lib_actuator_assembly_tools.scad>

N_TRAPS = 1;

nut_trap_test_object(N_TRAPS);

/**
* Simple test object to test the nut trap prints correctly
* Also use to test tightening torque on multiple traps
* For n_traps > 6, OpenSCAD preview does not work, use render
*/
module nut_trap_test_object(n_traps=1){
    trap_h = 10;
    extra_bore = 3;
    spacing = 12;
    length = 35 + spacing * (n_traps-1);
    difference(){
        union(){
            holding_block(dims=[length, 14, 8]);
            for (i = [1:n_traps]){
                position_x = (i - ((n_traps+1)/2)) * spacing;
                translate_x(position_x){
                    cylinder(d=11, h=trap_h, $fn=32);
                }
            }
        }
        for (i = [1:n_traps]){
            position_x = (i - ((n_traps+1)/2)) * spacing;
            translate_x(position_x){
                m3_nut_trap_with_shaft(slot_angle=0,tilt=0,deep_shaft=extra_bore,chamfer_offset=4);
            }
        }
    }
}
