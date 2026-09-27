use <./libs/lib_nano_converter_plate.scad>
use <./libs/utilities.scad>

PI_VERSION = 4;

nano_converter_plate_stl(PI_VERSION);

module nano_converter_plate_stl(pi_version=4){
    exterior_brim(r=8, smooth_r = 5){
        nano_converter_plate(pi_version);
    }
    echo(str("Pi version: ",pi_version));
}
