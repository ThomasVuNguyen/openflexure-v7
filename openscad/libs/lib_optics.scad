// This file defines the optics modules
// It is part of the OpenFlexure Microscope
// It is released under the CERN Open Hardware License.

use <./utilities.scad>
use <./z_axis.scad>
use <./microscope_parameters.scad>
use <./optics_configurations.scad>
use <./lighttrap.scad>
use <./libdict.scad>
use <./lib_fl_cube.scad>
use <./rms_calculations.scad>
use <./rms_thread.scad>
// camera.scad has generic camera modules forward the correct
// camera module depending on the optics configuration
use <./cameras/camera.scad>
use <./cameras/logitech_c270.scad>

$fn=24;

function optics_wedge_bottom() = -2; //bottom of dovetail (<0 to allow some play)

// This is used for both the lens spacer and the tube lens gripper
function lens_aperture(lens_r) = lens_r - 1.5;

// This function is used because the C270 camera needs to be rotated when used with a lens spacer
// in order to fit in between the xy stage legs
function is_c270_spacer(optics_config) = (key_lookup("optics_type", optics_config) == "spacer")
                                            && (key_lookup("camera_type", optics_config) == "logitech_c270");

// This function is used because the Arducam B0196 camera needs a cut-out in the 
// camera platform for the USB cable
function is_b0196_spacer(optics_config) = (key_lookup("optics_type", optics_config) == "spacer")
                                            && (key_lookup("camera_type", optics_config) == "arducam_b0196") ;

// This function gives extra 1mm lift in z for the low cost optics modules to allow for use cases
// of the low cost optics when the slide is placed with the sample on top. The
// working distance is enough to focus through a slide, and the extra 1mm in mounting screw and nut 
// position allows the mechanics to reach that point. 
function camera_platform_extra_lift() = 1;

module optical_path(optics_config, lens_z, camera_mount_top_z){
    // The cut-out part of a camera mount, consisting of
    // a feathered cylindrical beam path.  Camera mount is now cut out
    // of the camera mount body already.

    rms = key_lookup("optics_type", optics_config) == "RMS";
    lens_r = rms ?
        key_lookup("tube_lens_r", optics_config):
        key_lookup("lens_r", optics_config);
    aperture_r = is_c270_spacer(optics_config)?
        lens_aperture(lens_r)-2:
        lens_aperture(lens_r);

    union(){
        translate_z(camera_mount_top_z-tiny()){
            //beam path
            lighttrap_cylinder(r1=5, r2=aperture_r, h=lens_z-camera_mount_top_z+2*tiny());
        }
        translate_z(lens_z){
            //lens
            cylinder(r=aperture_r,h=99);
        }
    }
}

module lens_gripper(lens_r=10,h=6,lens_h=3.5,base_r=-1,t=0.65,solid=false, flare=0.4){
    // This creates a tapering, distorted hollow cylinder suitable for
    // gripping a small cylindrical (or spherical) object
    // The gripping occurs lens_h above the base, and it flares out
    // again both above and below this.
    trylinder_gripper(inner_r=lens_r, h=h, grip_h=lens_h, base_r=base_r, t=t, solid=solid, flare=flare);
}

module camera_mount_top_slice(optics_config){
    // A thin slice of the top of the camera mount
    thick_section(h=tiny(), center=false, shift=false){
        camera_mount(optics_config);
    }
}

module optics_module_body_outer(params, optics_config, body_r, body_top, rms_mount_h, wedge_top, bottom_r, include_wedge){
    // The outer shape of the optics module body. Including the camera mount.

    beamsplitter = key_lookup("beamsplitter", optics_config);
    camera_rotation = key_lookup("camera_rotation", optics_config);
    camera_mount_top_z = rms_camera_mount_top_z(params, optics_config);

    // The top of the camera mount
    module top_of_camera_mount_in_place(){
        rotate(camera_rotation){
            translate_z(camera_mount_top_z){
                camera_mount_top_slice(optics_config);
            }
        }
    }

    // The bottom of the cylindrical body of the mount, and the fitting wedge
    module bottom_of_body_and_wedge(){
        translate_z(optics_wedge_bottom()){
            cylinder(r=bottom_r,h=tiny());
        }
        //the bottom of the wedge
        if (include_wedge){
            translate_z(optics_wedge_bottom()){
                objective_fitting_wedge(h=tiny());
            }
        }
    }

    // The top of the cylindrical body, and the fitting wedge
    module top_of_body_and_wedge(){
        translate_z(body_top){
            cylinder(r=body_r, h=tiny());
        }
        if (include_wedge){
            translate_z(wedge_top){
                objective_fitting_wedge(h=tiny());
            }
        }
    }

    // The optics module is built from the bottom upwards - each pair of
    // shapes in the list below is hulled together to form the shape
    union(){
        if(beamsplitter){
            sequential_hull(){
                top_of_camera_mount_in_place();
                union(){
                    bottom_of_body_and_wedge();
                    fl_cube_casing_bottom(params, optics_config);
                }
                union(){
                    top_of_body_and_wedge();
                    extra_optics_body_for_beamsplitter(params, optics_config);
                }
            }
        }
        else {
            sequential_hull(){
                top_of_camera_mount_in_place();
                bottom_of_body_and_wedge();
                top_of_body_and_wedge();
            }
        }
        // The actual camera mount
        rotate(camera_rotation){
            translate_z(camera_mount_top_z){
                camera_mount(optics_config);
            }
        }
        // The housing for the RMS thread and tube lens gripper
        translate_z(body_top){
            cylinder(r=body_r, h=rms_mount_h);
        }
    }
}

module extra_optics_body_for_beamsplitter(params, optics_config){
    bs_rotation = key_lookup("beamsplitter_rotation", optics_config);
    rotate(bs_rotation){
        hull(){
            //the box to fit the fl cube in
            fl_cube_casing(params, optics_config);
            //the mounts for the fl cube screw holes
            fl_screw_holes(params, optics_config, d = 4, h =8);
        }
    }
}

module fl_cube_casing_bottom(params, optics_config){
    bottom = fl_cube_bottom(params, optics_config);
    translate_z(bottom){
        thick_section(){
            translate_z(-bottom){
                extra_optics_body_for_beamsplitter(params, optics_config);
            }
        }
    }
}

module optics_module_beamsplitter_cutout(params, optics_config){
    bs_rotation = key_lookup("beamsplitter_rotation", optics_config);

    cube_dim = [1, 1, 1] * fl_cube_w();
    cube_centre_z = fl_cube_bottom(params, optics_config)+fl_cube_w()/2;

    rotate(bs_rotation){
        translate_y(-2.5){
            fl_screw_holes(params, optics_config, d = 2.5, h = 6);
        }
        hull(){
            translate([0, -fl_cube_w(), cube_centre_z+3.5]){
                cube(cube_dim + [15, 0, 7], center=true);
            }
            translate([0, -fl_cube_w()-6, cube_centre_z+9]){
                cube(cube_dim + [20, 0, 6], center=true);
            }
        }
    }
}

module optics_module_body(
    params,  //microscope parameter dictionary
    optics_config, //dictionary of optics configuration
    body_r, //radius of mount body
    body_top, //z_poistion of the top of the body
    rms_mount_h, // height of the rms mount
    wedge_top, //z position of the top of the fitting_wedge
    bottom_r=8, //radius of the bottom of the mount
    include_wedge=true //set this to false to remove the attachment point
){
    // Make the main body of the optics module: A camera mount, a cylindrical body and a wedge for mounting.
    // Just add a lens mount on top for a complete optics module!

    beamsplitter = key_lookup("beamsplitter", optics_config);

    //The tube + the camera mount
    difference(){
        optics_module_body_outer(params, optics_config, body_r, body_top, rms_mount_h, wedge_top, bottom_r, include_wedge);
        // Mount for the nut that holds it on
        if (include_wedge){
            translate_z(-1){
                objective_fitting_cutout(params);
            }
        }
        // screw holes  and faceplate for fl module
        if(beamsplitter){
            optics_module_beamsplitter_cutout(params, optics_config);
        }
    }

}

// An RMS thread cutter with an extra plug
// This module cuts out an RMS thread, with space below it for
// the tube_lens_gripper
module rms_thread_and_cutout_for_tube_lens(mount_h){
    // cut the RMS thread for the objective
    translate_z(mount_h - 5.5){
        rms_thread_cutter(h=6, $fn=32, peak_points=2);
    }
    // add a smaller cylinder to provide space for the lens gripper
    // for the tube lens
    cylinder(r=rms_thread_nominal_d()/2-1.2, h=mount_h-1, $fn=60);
}

/**
* This is the mount for the tube lens. The objective threads into
* the threaded hole, defined in rms_thread_and_cutout_for_tube_lens
*/
module tube_lens_gripper(optics_config, pedestal_h){
    gripper_t = key_lookup("gripper_t", optics_config);
    tube_lens_r = key_lookup("tube_lens_r", optics_config);
    aperture_r = lens_aperture(tube_lens_r);

    //NB the RMS thread is now part of rms_thread_and_cutout_for_tube_lens

    translate_z(-tiny()){ // ensure these parts join properly to the floor at z=0
        // gripper for the tube lens
        lens_gripper(lens_r=tube_lens_r, lens_h=pedestal_h+1, h=pedestal_h+1+2.5+tiny(), t=gripper_t);
        // pedestal to raise the tube lens up within the gripper
        // NB this becomes a tube rather than a cylinder, but the inner part 
        // is cut out by `optical_path` or `optical_path_fl`
        cylinder(r=aperture_r+.8, h=pedestal_h+tiny());
    }
}

/**
* This optics module takes an RMS objective and a tube length correction lens
*/
module optics_module_rms(params, optics_config, include_wedge=true){
    assert(key_lookup("optics_type", optics_config)=="RMS",
    "Cannot create an RMS optics module for a non-RMS configuration.");

    beamsplitter = key_lookup("beamsplitter", optics_config);

    // height of pedestal for tube lens to sit on (to allow for flex)
    pedestal_h = 2;
    //height of the top of the wedge
    wedge_top = 27;

    // The optics (i.e. tube lens and objective) are mounted in a cylinder at
    // the top, with an RMS thread at the top and a gripper for the tube lens
    // inside.
    rms_optics_mount_z = tube_lens_face_z(params, optics_config) - pedestal_h;
    rms_optics_mount_base_r = rms_thread_nominal_d()/2+1;
    rms_optics_mount_h = objective_shoulder_z(params, optics_config)-rms_optics_mount_z;

    camera_mount_top_z = rms_camera_mount_top_z(params, optics_config);
    difference(){
        union(){
            // The bottom part is just a camera mount with a flat top
            difference(){
                // camera mount with a body that's shorter than the fitting wedge
                optics_module_body(params,
                                   optics_config,
                                   body_r=rms_optics_mount_base_r,
                                   bottom_r=10.5,
                                   body_top=rms_optics_mount_z,
                                   rms_mount_h=rms_optics_mount_h,
                                   wedge_top=wedge_top,
                                   include_wedge=include_wedge);
                // cut a hole for the rms thread and tube lens gripper
                translate_z(rms_optics_mount_z){
                    rms_thread_and_cutout_for_tube_lens(rms_optics_mount_h);
                }
            }
            translate_z(rms_optics_mount_z){
                tube_lens_gripper(
                    optics_config,
                    pedestal_h=pedestal_h
                );
            }
        }
        // camera cut-out and hole for the beam
        if(beamsplitter){
            optical_path_fl(params, optics_config, rms_optics_mount_z, camera_mount_top_z);
        }
        else{
            optical_path(optics_config, rms_optics_mount_z, camera_mount_top_z);
        }
    }
}

module lens_spacer_gripper(lens_r, lens_h, pedestal_h, lens_assembly_base_r, lens_assembly_z){

    lens_assembly_h = lens_h + pedestal_h; //height of the lens assembly

    // A lens gripper to hold the objective
    translate_z(lens_assembly_z){
        // gripper
        trylinder_gripper(inner_r=lens_r,
                          grip_h=lens_assembly_h-1.5,
                          h=lens_assembly_h,
                          base_r=lens_assembly_base_r,
                          flare=0.4,
                          squeeze=lens_r*0.15);
        // pedestal to raise the tube lens up within the gripper
        aperture_r = lens_aperture(lens_r);
        tube(ri=aperture_r, ro=aperture_r+1, h=pedestal_h);
    }
}

/**
* Calculate the z_position of the lens spacer.
* z position of lens is parfocal_distance below the sample
* To reach the bottom of the spacer also subtract camera_sensor_height
* and the desired lens spacing
*/
function lens_spacer_z(params, optics_config) = let(
    sample_z = key_lookup("sample_z", params),
    parfocal_distance = key_lookup("parfocal_distance", optics_config),
    lens_spacing = key_lookup("lens_spacing", optics_config)
) sample_z - (parfocal_distance + camera_sensor_height(optics_config) + lens_spacing);

module lens_spacer(params, optics_config){
    // Mount a lens some distance from the camera

    assert(key_lookup("optics_type", optics_config)=="spacer", "Use spacer optics configuration to create a lens spacer.");

    // unpack lens spacer parameters
    lens_r = key_lookup("lens_r", optics_config);
    lens_h = key_lookup("lens_h", optics_config);
    lens_spacing = key_lookup("lens_spacing", optics_config);

    // z_position of the lens for this piece.
    // This is the height of the camera_sensor above the circuit board plus the spacing between the lens and the sensor
    lens_z = camera_sensor_height(optics_config)+lens_spacing;

    pedestal_h = 4; // extra height on the gripper, to allow it to flex
    lens_assembly_z = lens_z - pedestal_h; //z position of the bottom of the lens assembly

    lens_assembly_base_r = lens_r+1; //outer size of the lens grippers

    // This is the height of the block the camera mounts into.
    camera_mount_height = camera_mount_height(optics_config);
    lens_spacer_rotate = is_c270_spacer(optics_config)? -135: 0;

    rotate_z(lens_spacer_rotate){
        translate_z(lens_spacer_z(params, optics_config)){
            difference(){
                union(){
                    // This is the main body of the mount
                    sequential_hull(){
                        translate_z(camera_mount_height){
                            camera_mount_top_slice(optics_config);
                        }
                        translate_z(camera_mount_height+5){
                            cylinder(r=6,h=tiny());
                        }
                        translate_z(lens_assembly_z){
                            cylinder(r=lens_assembly_base_r, h=tiny());
                        }
                    }

                    lens_spacer_gripper(lens_r, lens_h, pedestal_h, lens_assembly_base_r, lens_assembly_z);

                    // add the camera mount
                    translate_z(camera_mount_height){
                        camera_mount(optics_config, screwhole=false, counterbore=false);
                    }
                }
                union(){
                    // cut out the optical path
                    z_offset_lens_spacer_optical_path = is_c270_spacer(optics_config) ?
                                                                    2.8: // to match the light trap to the mount aperture, C270
                                                                    0; // to match the light trap to the mount aperture, Picam 2 and B0196
                    optical_path(optics_config, lens_assembly_z, camera_mount_top_z=z_offset_lens_spacer_optical_path);
                    // cut out counterbores
                    translate_z(camera_mount_height){
                        camera_mount_counterbore(optics_config);
                    }
                }
            }
        }
    }
}

function camera_mounting_post_height(optics_config) = key_lookup("mounting_post_height", optics_config);

function camera_board_thickness(optics_config) = key_lookup("board_thickness", optics_config);


/**
* camera_platform(params, base_r, h)
*
* * params - the microscope parameter dictionary
* * optics_config - optics configuration dictionary
* * base_r - radius of mount body
*/
module camera_platform(params, optics_config, base_r, camera_rotation=0){

    assert(key_lookup("optics_type", optics_config)=="spacer", "Use spacer optics configuration to create a camera_platform.");

    // platform height is 5mm below the lens spacer (board is 1mm thick mounting posts are 4mm tall)
    platform_h = lens_spacer_z(params, optics_config) - camera_mounting_post_height(optics_config) - camera_board_thickness(optics_config);
    assert(platform_h > upper_z_flex_z(params), "Platform height too low for z-axis mounting");

    camera_extra_rotation = is_c270_spacer(optics_config)? -135: 0;
    camera_mounting_posts_rotate  = camera_rotation + camera_extra_rotation;

    // Make a camera platform with a fitting wedge on the side and a platform on the top
    difference(){
        union(){
            // This is the main body of the mount
            sequential_hull(){
                hull(){
                    cylinder(r=base_r,h=tiny());
                    objective_fitting_wedge(h=tiny());
                }
                translate_z(platform_h){
                    hull(){
                        cylinder(r=base_r,h=tiny());
                        objective_fitting_wedge(h=tiny());
                        rotate_z(camera_mounting_posts_rotate){
                            camera_bottom_mounting_posts(optics_config, bottom_slice=true);
                        }
                    }
                }
            }

            // add the camera mount posts
            translate_z(platform_h){
                rotate_z(camera_mounting_posts_rotate){
                    camera_bottom_mounting_posts(optics_config, cutouts=false);
                }
            }
        }

        // Mount for the nut that holds it on 
        // The hole translated in -z from the nominal position lifts the platform up.
        translate_z(-camera_platform_extra_lift()){
            objective_fitting_cutout(params, y_stop=true, face_stops=true);
        }

        // Undercut on build plate
        undercut_objective_fitting_wedge(undercut_height = 1.5);
        // add the camera mount holes
        translate_z(platform_h){
            rotate_z(camera_mounting_posts_rotate){
                camera_bottom_mounting_posts(optics_config, outers=false, cutouts=true);
            }
        }
        // mark the optic axis
        translate_z(platform_h){
            cylinder(r=1, h=2, center = true);
        }
        // cut-out for Arducam b0196 cable
        if(is_b0196_spacer(optics_config)){
            rotate_z(45 + camera_rotation){
                translate([9,-11.5,10]){
                    cube([7,12,99]);
                }
            }
        }
        // cut ledge for the backshell, with a little clearance
        if(is_c270_spacer(optics_config)){
            rotate_z(camera_rotation){
                translate_z(lens_spacer_z(params, optics_config)-0.1){
                    rotate([180,0,0]){
                        c270_backshell();
                    }
                }
            }
        }
    }
}


// A module to difference() from an objective fitting wedge
// to undercut a little and so stop over extrusion or brim
// interfering with the mounting.
// At 45 degrees in y-z plane, less than 45 degrees on the plane of the mating faces
module undercut_objective_fitting_wedge(wedge_width_plus=20, undercut_height = 1.5){
    difference(){
        translate([0,13,-(10/2 - undercut_height + tiny())]){
            rotate_x(-45){
                cube([wedge_width_plus,10,20], center = true);
            }
        }
        sequential_hull(){
            translate_z(-10 + undercut_height){
                hull(){
                    translate_x(-wedge_width_plus/2){
                        cube([wedge_width_plus,tiny(),tiny()]);
                    }
                    translate_y(-10){
                        objective_fitting_wedge(h=tiny());
                    }
                }
            }
            translate_z(10 + undercut_height){
                hull(){
                    translate_x(-wedge_width_plus/2){
                        cube([wedge_width_plus,tiny(),tiny()]);
                    }
                    translate_y(10){
                        objective_fitting_wedge(h=tiny());
                    }
                }
            }
        }
    }
}

module configurable_optics_module(optics, camera_type, beamsplitter, parfocal_distance, camera_rotation, beamsplitter_rotation){
    params = default_params();
    // 45mm is the default parfocal distance.
    // If this setting is changed, it would normally be to 35mm.
    // The code below will print a warning if it is changed.
    if (parfocal_distance!=45){
        if (parfocal_distance==35){
            echo("Generating an optics module for older, 35mm parfocal, objectives.  Please check carefully, this option is not tested.");
        }
        else {
            echo("WARNING: parfocal_distance is neither 35mm nor 45mm, this may be an error.");
        }
    }

    // Note calling the optics module rms inside each if statment
    // to avoid nested ternaries
    if (optics=="rms_f50d13"){
        optics_config = rms_f50d13_config(
            camera_type=camera_type,
            beamsplitter=beamsplitter,
            parfocal_distance=parfocal_distance,
            camera_rotation=camera_rotation,
            beamsplitter_rotation=beamsplitter_rotation
        );
        optics_module_rms(params, optics_config);
    }
    else if(optics=="rms_infinity_f50d13"){
        optics_config = rms_infinity_f50d13_config(
            camera_type=camera_type,
            beamsplitter=beamsplitter,
            parfocal_distance=parfocal_distance,
            camera_rotation=camera_rotation,
            beamsplitter_rotation=beamsplitter_rotation
        );
        optics_module_rms(params, optics_config);
    }
    else{
        assert(false, "Unknown optics configuration specified");
    }

}
