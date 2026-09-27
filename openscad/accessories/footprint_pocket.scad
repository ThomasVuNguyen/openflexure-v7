/*

A footprint for the microscope stand - this can be used to laser-cut
a pocket for it to sit neatly in a baseplate.  Unlike footprint.scad
it produces a "thick" shape with one outline slightly bigger than the
footprint of the bucket base, and one a bit smaller.  I make a laser
cut base by "pocketing" the difference between the two lines and
cutting the smaller of the two - so the microscope sits on a 3mm wide
lip.  This works more nicely than just a big pocket.

*/
use <../libs/lib_microscope_stand.scad>

difference(){
    offset(0.1){
        footprint_2d();
    }
    offset(-3){
        footprint_2d();
    }
}