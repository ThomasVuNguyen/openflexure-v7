/**
* This is an alternative optics module that is to
* be used together with the camera platform, to make a cheap
* optics module that uses the webcam lens.  New in this version
* is compatibility with the taller stage (because the sensor is
* no longer required to sit below the microscope body).
*/


use <./libs/microscope_parameters.scad>
use <./libs/lib_optics.scad>
use <./libs/optics_configurations.scad>
use <./libs/utilities.scad>

lens_spacer_stl();

// render on the x-y plane rather than in place
module lens_spacer_stl(){
    params = default_params();
    optics_config = c270lens_config();
    translate_z(-lens_spacer_z(params, optics_config)){
        lens_spacer(params, optics_config);
    }
}
