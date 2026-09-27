use <../openscad/libs/microscope_parameters.scad>
use <librender/assembly_parameters.scad>
use <mount_upright_optics.scad>
use <mount_illumination.scad>

FRAME = 1;
OPTICS_VERSION = "low_cost"; // "upright", "low_cost", "rms", "c270"
MANUAL = false;
 
render_check_actuator_centre(FRAME, OPTICS_VERSION, MANUAL);

module render_check_actuator_centre(frame, optics_version, manual){
    check_actuator_centre(optics_version=optics_version, manual=manual, post=false);
}

module check_actuator_centre(optics_version, manual=false, post=false){
    params = render_params();
    if (optics_version == "upright"){
        mounted_microscope_upright_with_optics(optics_version=optics_version, manual=manual);
    }
    else{
        mounted_microscope_with_illumination(optics_version=optics_version, manual=manual, post=post);
    }
}