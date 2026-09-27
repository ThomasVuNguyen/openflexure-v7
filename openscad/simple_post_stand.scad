use <./libs/simple_post_stand_lib.scad>
use <./libs/microscope_parameters.scad>

simple_post_stand_stl();

module simple_post_stand_stl(){
    params= default_params();
    simple_post_stand(params);
}
