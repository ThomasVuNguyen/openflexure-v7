
use <./libs/microscope_parameters.scad>
use <./libs/compact_nut_seat.scad>
use <./libs/libfeet.scad>

module feet_stl(){
    params = default_params();
    x_tr = actuator_housing_xy_size().x+1.5;
    y_tr = actuator_housing_xy_size().y+1.5;
    translate([0, 0]){
        outer_foot(params, lie_flat=true, letter="X");
    }
    translate([x_tr, 0]){
        outer_foot(params, lie_flat=true, letter="Y");
    }
    translate([0, y_tr]){
        middle_foot(params,lie_flat=true, letter="Z");
    }
    translate([x_tr, y_tr]){
        middle_foot(params,lie_flat=true, letter="Z");
    }
}

feet_stl();
