use <./libs/illumination.scad>

condenser_stl();

module condenser_stl(){
    // NB the module is called in the renders with default arguments.  If
    // non-default arguments are used here, it will mean the STL doesn't
    // match the renders.
    condenser();
}