// This generates the thumbwheels, more finger-friendly alternatives to the gears

use <./libs/gears.scad>
use <./libs/utilities.scad>

repeat([0, 44, 0], 3, center=true){
    thumbwheel();
}