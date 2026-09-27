// Stand for the standard microscope configuration. The microscope screws
// onto this base, and a drawer houses the electronics.

// (c) Richard Bowman 2021
// Released under the CERN Open Hardware License

use <./libs/microscope_parameters.scad>
use <./libs/lib_microscope_stand.scad>

TALL_BUCKET_BASE = false;

microscope_stand_stl(TALL_BUCKET_BASE);

module microscope_stand_stl(tall_bucket_base){
    params = default_params();
    stand_params = default_stand_params(tall=tall_bucket_base);
    microscope_stand(params, stand_params);
}
