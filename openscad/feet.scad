
use <./libs/microscope_parameters.scad>
use <./libs/compact_nut_seat.scad>
use <./libs/libfeet.scad>

module feet_stl(){
    params = default_params();
    x_tr = actuator_housing_xy_size().x+1.5;
    translate([x_tr, 0]){
        outer_foot(params, lie_flat=true, letter="X");
    }
    middle_foot(params,lie_flat=true, letter="Z");
    translate([-x_tr, 0]){
        outer_foot(params, lie_flat=true, letter="Y");
    }
}

feet_stl();
