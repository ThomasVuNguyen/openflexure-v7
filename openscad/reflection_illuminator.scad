use <./libs/utilities.scad>
use <./libs/lib_fl_cube.scad>
use <./libs/static_dovetail.scad>

$fn=32;

/**
* The width of illuminator holder
*/
function illuminator_width() = 17;

/**
* Radius of the star LED used for reflection illumination.
*/
function ledstar_r() = 19/2;

/**
* Clearance radius to give the extra space needed to fit the screw head next to the LEDstar
*/
function ledstar_clearance_r() = ledstar_r() + 2.8;

/**
* Thickness of the reflection illuminator slip plate
*/
function slip_plate_thickness() = 2;

/**
* Separation between the sholts in the reflection illuminator slip plate
*/
function slip_plate_slot_separation() = illuminator_width() - 6;

/**
* The thickness of the excitation filter
*/
function excitation_filter_thickness() = 2;

/**
* The amount of holder either side of the exciation filter.
*/
function excitation_filter_offset() = 2;

/**
* The depth of the male dovetail that the filter cube mounts to
*/
function dovetail_depth() = fl_cube_roc() + 1.5;

/**
* The z-position of the mounted filter cube
*/
function filter_cube_z() = ledstar_clearance_r()-fl_cube_w()/2;

/**
* Height of the block the filter cube mounts to. Total structure is taller by
* the thickness of the slip plate.
*/
function fl_cube_mount_h() = fl_cube_w() + filter_cube_z() + 2;

/**
* The outer structure of the lens holder for the reflection illuminator.
*/
module lens_holder_body(w, block_height, pedestal_h, lens_r){

    lens_t = 1;
    //lens gripper to hold the plastic asphere
    translate_z(block_height){
        // gripper
        trylinder_gripper(inner_r=lens_r,
                          grip_h=pedestal_h + lens_t/3,
                          h=pedestal_h+lens_t+1.5,
                          base_r=ledstar_r(),
                          flare=0.5);
        // pedestal to raise the tube lens up within the gripper
        cylinder(r=lens_r-0.5,h=pedestal_h);
    }
    cylinder(r=ledstar_r(), h=block_height+tiny());
    translate_x(-w/2){
        cube([w,ledstar_clearance_r(),block_height]);
    }
    //mounts for screws for LED star
    translate_y(-ledstar_r()){
        cylinder(r=3,h =block_height+tiny());
    }
}

/**
* z_positions of the lens in the lens holder.
*/
function lens_holder_z_pos(led_h, aperture_to_lens, aperture_h) = led_h + aperture_to_lens + aperture_h;

/**
* The optics cutout for the reflection lens holder. This includeds a push fit for
* a 5mm LED, the aperture, and the beam path to the lens.
*/
module lens_holder_optics_cutout(led_h, aperture_to_lens, aperture_h, lens_r){
    led_r = 4.5/2;
    aperture_stop_r = 0.6;
    lens_z = lens_holder_z_pos(led_h, aperture_to_lens, aperture_h);
    //beam path above aperture
        hull(){
            translate_z(led_h+aperture_h-tiny()){
                cylinder(r=tiny(),h=tiny());
            }
            translate_z(led_h+aperture_h+1){
                cylinder(r=4,h=tiny());
            }
            translate_z(lens_z){
                cylinder(r=lens_r-2,h=tiny());
            }
        }

        //aperture
        translate_z(led_h+aperture_h){
            cylinder(r=aperture_stop_r,h=2,center=true);
        }

        //LED holder
        deformable_hole_trylinder(led_r-0.1,led_r+0.6,h=2*led_h+tiny(), center=true);
        translate_z(led_h){
            cylinder(r1=led_r+0.6, r2=aperture_stop_r,h=aperture_h-0.5+tiny());
        }
        cylinder(r=led_r+0.5, h=1.5, center=true);
}

/**
* An m2.5 nut trap for the lens holder
*/
module m2_5_nut_trap(shaft_top=99,shaft_bottom=-99){

    rotate_z(-30){
        translate_z(shaft_bottom){
            cylinder(d = 3, h = shaft_top-shaft_bottom+2.4);
        }
    }
    hull(){
        for (x_tr = [0, 20]){
            translate_x(x_tr){
                cylinder(d = 5.8, h = 2.4, $fn=6);
            }
        }
    }
}


module lens_holder(){

    // A simple one-lens condenser, re-imaging the LED onto the sample.
    //distance from bottom to the top of the LED
    led_h = 2;
    aperture_h = 2;
    //distance from aperture stop to lens
    aperture_to_lens = 6.5;

    lens_z = lens_holder_z_pos(led_h, aperture_to_lens, aperture_h);
    pedestal_h = 3;
    lens_r = 13/2;

    block_height = lens_z-pedestal_h;
    w= illuminator_width();
    difference(){
        lens_holder_body(w, block_height, pedestal_h, lens_r);
        lens_holder_optics_cutout(led_h, aperture_to_lens, aperture_h, lens_r);

        //screws for LED star
        for(i = [0:1]){
            rotate(180*i){
                translate([0, -ledstar_r(), -tiny()]){
                    trylinder_selftap(nominal_d = 3, h = block_height - 1);
                }
            }
        }

        screw_pos = [slip_plate_slot_separation()/2, ledstar_clearance_r()-3, block_height/2];
        reflect_x(){
            translate(screw_pos){
                rotate_x(90){
                    m2_5_nut_trap(shaft_top=1,shaft_bottom=-6);
                }
            }
        }
    }

}


/**
* The block the slip plate mounts to. This forms part of the `illuminator_holder()`
*/
module fl_cube_mount(beam_d=5){

    beam_z = filter_cube_z()+fl_cube_w()/2;
    roc = 0.6;
    // This part clips on to the filter cube, to allow a light source (generally LED) to be coupled in using the beamsplitter.
    $fn=8;
    w = illuminator_width();

    difference(){
        union(){
            translate_y(dovetail_depth()){
                mirror([0,1,0]){
                    dovetail_m([fl_cube_w()-1, 1, fl_cube_mount_h()], t=2*roc, r=fl_cube_roc());
                }
            }
            hull(){
                translate([-w/2, dovetail_depth(), 0]){
                    cube([w, tiny(), fl_cube_mount_h()]);
                }
                reflect_x(){
                    cyl_y_pos = dovetail_depth() + excitation_filter_thickness() + 2* excitation_filter_offset();
                    translate([w/2-roc, cyl_y_pos, 0]){
                        cylinder(r=roc, h=fl_cube_mount_h(), $fn=16);
                    }
                }
            }

        }

        // add a hole for the LED
        translate_z(beam_z){
            printable_horizontal_hole(h=999, r=beam_d/2, $fn=16, extra_height=0, center=true);
        }
    }
}

/**
* Slip plate for mounting the star LED without the structure to mount it.
* This forms part of the `illuminator_holder()`
*/
module illumintor_slip_plate(){
    w = illuminator_width();
    difference(){
        translate([-w/2+1,1,0]){
            minkowski(){
                //base
                cube([w-2, 40-2, slip_plate_thickness()]);
                cylinder(r=1,h=0.1, $fn=16);
            }
        }
        reflect_x(){
            hull(){
                for (y_tr = [15, 37]){
                    translate([slip_plate_slot_separation()/2, y_tr, -tiny()]){
                        cylinder(r=1.3, h=slip_plate_thickness()+1, $fn=8);
                    }
                }
            }
        }
    }
}


/**
* The mounting structure to hold the for the slip plate onto the optics module
* This forms part of the `illuminator_holder()`
*/
module reflection_illumintor_mount(){
    depth = 4;
    screw_height = filter_cube_z()+slip_plate_thickness()+2;
    height = fl_cube_mount_h()+slip_plate_thickness();

    w_bottom = fl_cube_w()+11;
    w_middle = fl_cube_w()+10;
    w_top = fl_cube_w()+1.5;
    w_cut = fl_cube_w()+1;
    difference(){
        hull(){
            translate_x(-w_bottom/2){
                cube([w_bottom, depth, 4]);
            }
            translate_x(-w_middle/2){
                cube([w_middle, depth, screw_height]);
            }
            translate([-w_top/2, 0 , height-tiny()]){
                cube([w_top, depth, tiny()]);
            }
        }
        translate_z(100+screw_height){
            cube([w_cut, 3*depth, 200], center=true);
        }

        reflect_x(){
                //mounting hole to optics module
            translate([(fl_cube_w()/2+3),-tiny(),screw_height]){
                rotate_x(-90){
                    cylinder(d = 2.6, h= 6, $fn=10);
                }
            }
        }
    }
}

/**
* The slip plate including the structure to mount it to the optics module
* This forms part of the `illuminator_holder()`
*/
module mounted_illumintor_slip_plate(){
    difference(){
        union(){
            reflection_illumintor_mount();
            illumintor_slip_plate();
        }
        //chamfer the front
        hull(){
            translate_z(-tiny()){
                cube([999,4,tiny()], center=true);
            }
            translate([0, -tiny(), 2]){
                cube([999,tiny(),tiny()], center=true);
            }
        }

    }
}

/**
* The slot to be cut out of the `illuminator_holder()` to hold the excitation
* filter 
*/
module excitation_slot(){
    excitation_width = 13;

    height = filter_cube_z()+ fl_cube_w()-excitation_filter_offset();
    //Double height slot to cut through and out the bottom.
    slot_dims = [excitation_width, excitation_filter_thickness(), 2*height];
    y_tr = dovetail_depth() + excitation_filter_offset() + slot_dims.y;

    translate_y(y_tr){
        cube(slot_dims, center=true);
    }
}



// Geometry of illuminator holder
module illuminator_holder(){
    difference(){
        union(){
            translate_z(slip_plate_thickness()){
                fl_cube_mount();
            }
            mounted_illumintor_slip_plate();
        }
        excitation_slot();
    }
}

translate([25,-10,0]){
    illuminator_holder();
}

lens_holder();


