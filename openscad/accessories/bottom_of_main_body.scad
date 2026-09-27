// This is mainly useful to create laser cut cases
// it's the bottom of the main body.  NB you need
// to make cut-outs underneath the moving parts and
// under the feet, to allow them to protrude through
// the plate.

use <../libs/main_body_structure.scad>
use <../libs/microscope_parameters.scad>
use <../libs/utilities.scad>

bottom_of_main_body();

module bottom_of_main_body(){
    params = default_params();
    flatten(){
        // Version and hash string isn't used, but needs to be set.
	main_body(params, version_string="", hash="");
    }
}
