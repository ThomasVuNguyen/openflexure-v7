
use <./libs/microscope_parameters.scad>
use <./libs/libdict.scad>
use <./libs/utilities.scad>
use <./libs/upright_z_axis.scad>

separate_z_actuator_manual_with_smart_brim(params = default_params());

module separate_z_actuator_manual_with_smart_brim(params){
    $fn=32;
    // Adds a smart brim to the z-only module to prevent the back from peeling upwards when printing
    // Smart brim is required instead of typical brim to prevent the brim affecting the internal structures
    no_lug_params = replace_value("include_motor_lugs", false, params);
    smart_brim_r = key_lookup("smart_brim_r", no_lug_params);
    exterior_brim(r=smart_brim_r){
        separate_z_actuator(no_lug_params, cable_guides = false, cable_housing = false, rectangular = true);
    }
}
