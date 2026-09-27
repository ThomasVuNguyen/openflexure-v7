/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Gears for actuators                     *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
* This file generates a small gear, for motor control.            *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./libs/gears.scad>
use <./libs/utilities.scad>

// The ratio is the ratio between the 'large' gear on the actuator and the 'small' gear on the motor.
// This means that it is a gearing down ratio.
// The standard ratio is 2. The total number of teeth on both gears is 36, which is defined by the distance between the rotation axes.
// For an integer number of teeth, allowed ratios are of the form n/(36-n). Ratios from 0.8 (16/20, 1:1.25) to 2 (24/12, 1:0.5) are expected to fit in the body

// Gearing ratio for x and y axes. Ratio for z axis fixed at 2
RATIO = 2;

printable_small_gears(ratio=RATIO);

module printable_small_gears(ratio=2){
    // check the ratio gives an integer number of teeth
    assert(floor(n_teeth_small_gear(ratio))==n_teeth_small_gear(ratio),"The number of teeth on the small gear is not integer");
    // Calculate the spacing from the gear pitch radius.
    // Add 4mm of clearance
    spacing = small_gear_pitch_radius(ratio) + small_gear_pitch_radius(ratio=2) + 4;
    // x and y gears
    repeat([0, 2*spacing, 0], 2, center=true){
        // 3.15 is a trade off. Firm to push on some printers that print
        // the gears loose. Should be press fit with a small clamp/vice
        // if the printer prints tight. All are then locked with two screws
        // Can be adjusted for printers outside this range.
        small_gear(flat_shaft_w=3.15, ratio=ratio);
    }
    // z gear
    small_gear(flat_shaft_w=3.15, ratio=2);
}
