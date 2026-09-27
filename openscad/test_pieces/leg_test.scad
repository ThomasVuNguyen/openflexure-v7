use <../libs/main_body_structure.scad>
use <../libs/microscope_parameters.scad>
use <../libs/libdict.scad>
use <../libs/utilities.scad>

leg_test_object();
/**
* This is for printing a shorter version of the leg just
* to check the bridging works.
*/
module leg_test_object(){
    params = default_params();
    smart_brim_r = key_lookup("smart_brim_r", params);
    short_leg_params = replace_value("sample_z", 50, params);
    exterior_brim(r=smart_brim_r){
        leg(short_leg_params);
    }
}