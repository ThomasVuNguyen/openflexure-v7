
use <./microscope_parameters.scad>
use <./illumination.scad>
use <./libdict.scad>
use <./utilities.scad>
use <./lib_optics.scad>
use <./z_axis.scad>


// The condenser lens is 5mm focal length and the condenser body is 30mm long
// It is formed from:
//    condenser_lens_assembly_z() (22mm) + condenser_lens_assembly_pedestal_height() (5.5mm) 
//    + lens base thickness (1mm) + gripper (1.5mm)
// 
// The condenser focus is a little further away, so space by 7mm from the lens inner face not f=5mm
function  upright_condenser_platform_height() = let(
    sample_z = key_lookup("sample_z", default_params()),
    bottom_of_lens = condenser_lens_assembly_z() + condenser_lens_assembly_pedestal_height(),
    platform_ht = sample_z - bottom_of_lens - 7
) platform_ht;

// Module to create a platform with a fitting wedge for the z-axis
// and a mounting face for the condenser and cut-out for a 5mm LED or LED PCB.
// This has the cutouts that would be in the 'lid' of the condenser on the inverted microscope.
module upright_condenser_platform_separate(params, base_r=5){

    platform_h = upright_condenser_platform_height();
    assert(platform_h > upper_z_flex_z(params), "Platform height too low for z-axis mounting");

    // Make a platform with a dovetail on the side and a platform on the top
    // this is similar to the camera_platform() module, but does not have posts and has an extra cut-out
    // so it is defined separately.
    difference(){
        // This is the main body of the mount
        sequential_hull(){
            hull(){
                cylinder(r=base_r, h=tiny());
                objective_fitting_wedge(h=tiny());
            }
            translate_z(platform_h-tiny()){
                hull(){
                    // cylinder above base
                    cylinder(r=base_r, h=tiny());
                    objective_fitting_wedge(h=tiny());
                    // cylinder to match the base of the condenser
                    lens_d = condenser_lens_diameter();
                    cylinder(r=condenser_base_r(lens_d)+2, h=tiny());
                    // mounting positions for the condenser
                    reflect_x(){
                        translate_x(upright_condenser_lug_x()){
                            cylinder(r=4, h=tiny());
                        }
                    }
                }
            }
        }
        // Mount for the nut and screw hole that holds it on
        translate([0, tiny(), 0]){
            objective_fitting_cutout(params, y_stop=true);
        }
        translate_z(platform_h){
            // Add the cutouts that would be in the 'lid' of the condenser on the inverted microscope.
            // rotate cable exit away from dovetail
            rotate_z(180){
                //allow space for 2 screw heads and for board thickness
                board_bore_depth = 8.0;
                // Note: in illumination_board_cutout, 
                // h is used both for positioning and for the sizes of the cut-out parts
                // final position is relative to a mounting plane at z=h
                h = condenser_lid_h();
                translate_z(-condenser_lid_h()){
                    illumination_board_cutout(h, board_bore_depth);
                }
            }
            reflect_x(){
                translate([upright_condenser_lug_x(), 0, tiny()]){
                    mirror([0, 0, 1]){
                        no2_selftap_hole(h=8);
                    }
                }
            }
        }
        // Undercut on build plate 
        undercut_objective_fitting_wedge(undercut_height=1.5);
    }
}

function upright_condenser_lug_x() = 12;

// Condenser for attaching to platform to mount to z-axis dovetail
// for use with upright microscope
// 5mm LED or LED PCB
module upright_condenser_separate(){
    condenser(lens_assembly_z=condenser_lens_assembly_z(), include_mounting=false, basic_condenser=true);
    lens_d = condenser_lens_diameter();
    base_r = condenser_base_r(lens_d);
    difference(){
        hull(){
            cylinder(r=5, h=8);
            reflect_x(){
                translate_x(upright_condenser_lug_x()){
                    cylinder(r=4, h=4);
                }
            }
        }
        union(){
            // base of condenser module is size base_r + 0.2 
            // in the condenser_body() module of illumination.scad
            // so cutout base_r is certainly smaller, no need for - tiny()
            cylinder(r=base_r , h=99, center = true);
            reflect_x(){
                translate([upright_condenser_lug_x(), 0, 2]){
                    no2_selftap_counterbore(flip_z=false);
                    }
            }
        }
    }
}
