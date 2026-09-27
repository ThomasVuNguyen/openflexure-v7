

use <./libs/microscope_parameters.scad>
use <./libs/lib_optics.scad>
use <./libs/optics_configurations.scad>

camera_platform_stl();

module camera_platform_stl(){
    params = default_params();
    optics_config = pilens_config();
    camera_platform(params, optics_config, base_r = 5);
}
