use <../libs/rms_thread.scad>
use <../libs/utilities.scad>

// An internal RMS thread, to check it fits objectives reliably.
module rms_thread_test(d_offset=0.5){
    nominal_d = rms_thread_nominal_d();
    difference(){
        union(){
            cylinder(d=nominal_d + 2 + d_offset, h=6.5);
            translate_y(-4){
                cube([nominal_d/2 + 25, 8, 0.5]);
            }
        }

        translate_z(1){
            rms_thread_cutter(h=6, d_offset=d_offset);
        }

        translate([nominal_d/2 + 2, -3, 0.25]){
            linear_extrude(2){
                text(str(d_offset), size=6);
            }
        }
    }
}

module rms_thread_tests(offsets=[0.75, 0.5, 0.25]){
    nominal_d = rms_thread_nominal_d();
    dy = nominal_d + 5;
    N = len(offsets);
    for(i=[0:N-1]){
        translate_y(i*dy){
            rms_thread_test(d_offset=offsets[i]);
        }
    }
}

rms_thread_tests([0.7, 0.6, 0.5]);