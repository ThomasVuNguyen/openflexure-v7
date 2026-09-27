/**
* This generates a version of the main body designed for manual operation
* There are no cable tidy channels
* There are no motor lugs
*/

use <./libs/utilities.scad>
use <./libs/libdict.scad>
use <./libs/microscope_parameters.scad>
use <./libs/main_body_structure.scad>

//Note that the main body is complex enough you should run Render not preview
// To use in preview wrap with render(6)
VERSION_STRING = "Custom";
HASH = "#untracked";
main_body_manual_stl(VERSION_STRING, HASH);

module main_body_manual_stl(version_string, hash){
    params = default_params();
    no_lug_params = replace_value("include_motor_lugs", false, params);
    smart_brim_r = key_lookup("smart_brim_r", no_lug_params);
    exterior_brim(r=smart_brim_r){
        main_body(no_lug_params, version_string, hash);
    }
}