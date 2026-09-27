use <./libs/microscope_parameters.scad>
use <./libs/cable_tidies_lib.scad>


UPRIGHT = false;

cable_tidies_stl(UPRIGHT);

module cable_tidies_stl(upright){
    params = default_params();
    cable_tidies(params, upright);
}
