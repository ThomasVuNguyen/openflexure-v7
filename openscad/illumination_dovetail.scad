use <./libs/illumination.scad>
use <./libs/microscope_parameters.scad>
use <./libs/utilities.scad>

illumination_dovetail_stl();

module illumination_dovetail_stl(){
    params = default_params();
    translate_z(-illumination_dovetail_z(params)){
        illumination_dovetail(params, h = 60);
    }
}
