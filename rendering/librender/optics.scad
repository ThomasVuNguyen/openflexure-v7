

use <../../openscad/libs/threads.scad>
use <../../openscad/libs/utilities.scad>
use <render_utils.scad>

module tube_lens(){
    //Should be f=50 but exaggerating curvature
    lens(d=12.7, f=30);
}

module condenser_lens(){
    flanged_lens(d=11,f=9,cut=4, fl_d=13, fl_h=1);
}

module lens(d=16, f=40, cut=4.5, n=1.5){
    $fn=60;
    color("PaleTurquoise", .60){
        render(6){
            base_lens(d, f, cut, n);
        }
    }
}

module flanged_lens(d=16, f=40, cut=4.5, fl_d=18, fl_h=1, n=1.5){
    // d is the diamater of the non-flanged section
    // cut is the height of the non-flanged section.
    $fn=60;
    color("PaleTurquoise", .60){
        render(6){
            union(){
                translate_z(fl_h-tiny()) {
                    base_lens(d, f, cut+tiny(), n=n);
                }
                cylinder(h=fl_h, d=fl_d);
            }
        }
    }
}

module base_lens(d=16, f=40, cut=4.5, n=1.5){
    // n is the refractive index
    radius = f*(n-1);
    intersection(){
        cylinder(d=d, h=999);
        translate_z(-radius+cut){
            sphere(r=radius);
        }
    }
}

module led(){
    $fn=60;
    color("white", .75){
        render(6){
            union(){
                cylinder(d=6, h=0.7);
                cylinder(d=5, h=5);
                translate_z(5){
                    sphere(r=5/2);
                }
            }
        }
    }
}

module objective_body(){
    $fn=60;
    stage1_z = 16;
    stage2_z = stage1_z+15.5;
    stage3_z = stage2_z+8;
    stage4_z = stage3_z+2;
    difference(){
        sequential_hull(){
            cylinder(d=24.5,h=tiny());
            translate_z(stage1_z){
                cylinder(d=24.5,h=tiny());
            }
            translate_z(stage1_z){
                cylinder(d=22.5,h=tiny());
            }
            translate_z(stage2_z){
                cylinder(d=22.5,h=tiny());
            }
            translate_z(stage3_z){
                cylinder(d=17,h=tiny());
            }
            translate_z(stage3_z){
                cylinder(d=9,h=tiny());
            }
            translate_z(stage4_z){
                cylinder(d=4,h=tiny());
            }
        }
        translate_z(35){
            cylinder(d=3, h=10);
        }
    }
}

module objective_thread(){
    $fn=60;
    //coppied in from optics.scad!
    radius=25.4*0.8/2-0.25;
    pitch=0.7056;
    translate_z(-4){
        difference(){
            cylinder(r=radius, h=4+tiny());
            cylinder(r=radius-1, h=99, center=true);
        }
        outer_thread(radius=radius,
                    pitch=pitch,
                    thread_base_width = 0.60,
                    thread_length=2.5);
    }
}
module objective_base(){
    $fn=60;
    translate_z(-4.5){
        difference(){
            cylinder(r=9.5, h=4.5+tiny());
            cylinder(r=4, h=99, center=true);
        }
    }
}

module rendered_objective(){

    coloured_render("silver"){
        objective_body();
    }
    coloured_render("goldenrod"){
        objective_thread();
    }
    coloured_render("#404040"){
        objective_base();
        translate_z(38.6){
            sphere(r=3);
        }
    }
    coloured_render("deepskyblue"){
        translate_z(13){
            cylinder(d=24.53, h=1, $fn=60);
        }
    }
}
