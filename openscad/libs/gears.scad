/*A library of modules and functions that define the gears for the actuators.

Two gears join the motor to the actuator of the Openflexure
microscope. This provides a gearing ratio between the motor and
the driven motion of the stage

The ratio is the ratio between the 'large' gear on the actuator
and the 'small' gear on the motor.
This means that it is a gearing down ratio.

The standard ratio is 2. The standard total number of teeth on
both gears is 36, which is defined by the distance between the
rotation axes.
For an integer number of teeth on the small gear, allowed
ratios are of the form `(36-n)/n`.

Ratios from 0.8 (16/20, 1:1.25) to 2 (24/12, 1:0.5)
fit in the body for x and y.
*/

// SPDX-License-Identifier: CERN-OHL-S-2.0
// For copyright and authorship information, see the Git history at:
// https://gitlab.com/openflexure/openflexure-microscope

use <./MCAD/involute_gears.scad> // forward slash - for platform independence
use <./microscope_parameters.scad>
use <./utilities.scad>
use <./compact_nut_seat.scad>


/**
* Total number of teeth on the large and small gears
*/
function total_gear_teeth() = 36;


/**
* Number of teeth on the small gear
*/
function n_teeth_small_gear(ratio=2) = total_gear_teeth() / (ratio + 1);

/**
* Number of teeth on the large gear
*/
function n_teeth_large_gear(ratio=2) = n_teeth_small_gear(ratio) * ratio;

/**
* Distance from the centre of the small gear to the centre of the large gear
*/
function gear_c2c_distance() = 20;

/**
* The MCAD circular pitch used for both the small and large gears.
* Note that MCAD uses its own definition of circular pitch. To get the true
* circular pitch (the distance between teeth along the pitch circle) you
* must muliply by pi/180.
*/
function gear_pitch() = gear_c2c_distance() * 360 / (total_gear_teeth());

/**
* The pitch radius for the large gear.
* The pitch radius is the ditance from the centre of gear to the meshing point.
* This is calcualted as:
*    pitch radius = Nteeth * circular_pitch / 360
*/
function large_gear_pitch_radius(ratio=2) = gear_pitch_radius(gear_pitch(), n_teeth_large_gear(ratio));


/**
* The total radius of the large gear
*/
function large_gear_radius(ratio=2) = gear_outer_radius(large_gear_pitch_radius(ratio), n_teeth_large_gear(ratio));

/**
* The poisition of the screw for the large gear relateive to the centre of the bottom plane of the gear.
*/
function large_gear_screw_pos() = [0, 0, 1.5];

/**
* The pitch radius for the small gear.
* The pitch radius is the ditance from the centre of gear to the meshing point.
* This is calcualted as:
*    pitch radius = Nteeth * circular_pitch / 360
*/
function small_gear_pitch_radius(ratio=2) = gear_pitch_radius(gear_pitch(), n_teeth_small_gear(ratio));

/**
* The total radius of the small gear measired over the teeth
*/
function small_gear_radius(ratio=2) = gear_outer_radius(small_gear_pitch_radius(ratio), n_teeth_small_gear(ratio));

/**
* The value of $fn used for the small gear
*/
function small_gear_fn() = 32;

/**
* Radius of the flange on the large gear. This is larger than the radius across the teeth
* by half the distance from the meshing point to the end of the teeth.
*/
function small_gear_flange_radius(ratio=2) = let(
    pitch_r = small_gear_pitch_radius(ratio),
    outer_r = small_gear_radius(ratio),
    additional_r = (outer_r-pitch_r)/2
) outer_r + additional_r;

/**
* Profile of the large gears that are attached to the actuator lead screw and sit ontop
* of the actuator housing. These are driven by the small gear (see `small_gear()`).
*/
module large_gear_profile(height, ratio=2){
    pitch = gear_pitch();
    gear(number_of_teeth=n_teeth_large_gear(ratio),
         circular_pitch=pitch,
         circles=0,
         gear_thickness=height,
         hub_thickness=height,
         hub_diameter=20,
         rim_thickness=height,
         bore_diameter=0);
}

/**
* A version of the large gear profile that has a slight offest enlargement.
* Used with difference() to make a loose fit over the gear.
*/
module loose_large_gear_profile(height, ratio=2){
    gap = 0.2;
    linear_extrude(height){
        offset(gap){
            projection(cut=true){
                translate_z(-tiny()){
                    large_gear_profile(height=1, ratio=ratio);
                }
            }
        }
    }
}

/**
* Large gears that are attached to the actuator lead screw and sit ontop
* of the actuator housing. These are driven by the small gear (see `small_gear()`).
*/
module large_gear(ratio=2){
    $fn=32;

    pitch_r = large_gear_pitch_radius(ratio);
    height = 6; // height of nut trap
    difference(){
        // intersection used to chamfer the bottom of the gear
        intersection(){
            large_gear_profile(height=height, ratio=ratio);
            cylinder(r1=pitch_r-2,r2=pitch_r+18,h=20);
        }
        translate(large_gear_screw_pos()+[0,0,height+1]){
            mirror([0,0,1]){
                nut_trap_and_slot(actuator_nut_size(), actuator_nut_slot_size(), slot_length=0, include_bridged_top=false);
            }
            cylinder(r=actuator_shaft_radius(), h=99, center=true, $fn=16);
        }
    }
}

function small_gear_height() = 9.5;
function small_gear_screw_hole(flat_shaft_w=3.15) = let(
    //Adding 1.25 makes the wall very close to 0.4 mm
    // Should print as a single filament with a 0.4mm nozzle
    y=flat_shaft_w/2+1.25,
    z=small_gear_height()-1.5
) [0, y, z];


/**
* The cut-out in the small gear for the motor shaft
*/
module motor_shaft_cut_out(flat_shaft_w){
    shaft_d=5.2;
    intersection(){
        //5.4mm diameter, slightly loose for 5mm shaft.
        cylinder(d=shaft_d, h=99, center=true);
        cube([99,flat_shaft_w,99], center=true);
    }
    cylinder(d=shaft_d, h=3, center=true);
    reflect_y(){
        screw_pos = small_gear_screw_hole(flat_shaft_w);
        translate_y(screw_pos.y){
            no2_selftap_hole(h=99, center=true);
            //counterbore
            translate_z(screw_pos.z){
                cylinder(d=4.5, h=99);
            }
        }
    }
}

/**
* Small gears that attach onto the 28BYJ-48 stepper motor shaft for motorised actuation
*/
module small_gear(flat_shaft_w=3.15, ratio=2){
    $fn=small_gear_fn();
    h=small_gear_height();
    difference(){
        union(){
            gear(number_of_teeth=n_teeth_small_gear(ratio),
                 circular_pitch=gear_pitch(),
                 circles=0,
                 gear_thickness=h,
                 hub_thickness=h,
                 hub_diameter=1,
                 rim_thickness=h,
                 bore_diameter=1);
            //Flange on the bottom of the gear improve adhesion during printing
            cylinder(r=small_gear_flange_radius(ratio),h=0.5);
        }
        motor_shaft_cut_out(flat_shaft_w=flat_shaft_w);
    }
}

/**
* Thumbwheels for hand actuation of the microscope
*/
module thumbwheel(){
    lobe_r = 10;
    lobe_h = 5;
    base_low_r = 10;
    base_up_r = 12;
    base_h = 12.5;
    n_lobe = 6;
    height = 6; // height of nut trap

    difference()
    {
        union()
        {
            cylinder(r1=base_low_r,r2=base_up_r,h=base_h);
            for( n = [0 : n_lobe-1] )
            {
                deg = 360*n/n_lobe;
                translate([lobe_r*sin(deg),lobe_r*cos(deg),base_h]){
                    thumbwheel_lobe(r=lobe_r,h=lobe_h);
                }
            }
        }
        translate([0,0,height+1.5]){
            mirror([0,0,1]){
                nut_trap_and_slot(actuator_nut_size(), actuator_nut_slot_size(), slot_length=0, include_bridged_top=false, bottom_hole=99);
            }
            cylinder(r=actuator_shaft_radius(), h=99, center=true, $fn=16);
        }
    }
}

/**
* A lobe for the thumbwheel with conical support
*/
module thumbwheel_lobe(r=5, h=5)
{
    hull(){
        cylinder(r=r,h=h);
        translate_z(-h){
            cylinder(r=tiny(),h=tiny());
        }
    }
}

/**
* A thumbscrew for the locking dovetail on the illumination
*/
module illumination_thumbscrew(){
    h=14;
    taper_h=5;
    difference()
    {
        hull(){
            cylinder(r = 4, h=taper_h, $fn=8);
            translate_z(taper_h){
                cylinder(r=5, h=h-taper_h, $fn=8);
            }
        }
        translate_z(12){
            m3_nut_hole(h=99, shaft=true, tight=true);
        }
    }
}

/* Cut-out for the motor lugs

Create cylinders separated by the motor screw separation and optionally
hull them.

:param r: radius of each cylinder
:param h: height of each cylinder
:param hulled: whether to hull the cylinders.
*/
module motor_lug_clearance(r, h, hulled=true){
    if (hulled){
        hull(){
            motor_lug_clearance(r=r, h=h, hulled=false);
        }
    }
    else{
        reflect_x(){
            translate_x(motor_screw_separation()/2){
                cylinder(r=r, h=h);
            }
        }
    }
}

/*
The cut-out used by the z-axis to provide space for the motors.

This also contains extra space so that the z-nut traps are not
obscured by the condenser mount.

:param h: Height of the cut-out

This does not include clearance for the cable or motor shaft
The centre of the motor body is at the origin, not the shaft.
*/
module motor_clearance(h=15){
    motor_d = 28;
    clearance = 3;
    cylinder(d=motor_d+clearance, h=h);
    // Space for the indent that holds the motor lugs
    motor_lug_clearance(r=5-tiny(), h=h, hulled=false);
    // Space for access
    translate_z(1.6){
        motor_lug_clearance(r=5.2, h=h-1.6, hulled=true);
    }
    // Space for the z-nut traps
    translate_z(-8){
        motor_lug_clearance(r=3.3, h=h+8, hulled=true);
    }
    // Space for the screw shaft below.
    translate_z(-12){
        motor_lug_clearance(r=2, h=13, hulled=false);
    }
}

/* Clearance for the small gear, large gear, and motor on the z-axis.

This also contains extra space so that the z-nut traps are not
obscured by the condenser mount.

It's positioned with the centre of the large gear at the origin.

:param gear_h: This should be height of the motor lugs above the flat surface
    for the large gear, in motor_lugs in compact_nut_seat.scad.
:param h: height of the cut-out.
*/
module motor_and_gear_clearance(gear_h=10, h=999){

    linear_extrude(h){
        offset(1.5){
            hull(){
                circle(r=large_gear_radius(), $fn=n_teeth_large_gear()*4);
                translate([0,gear_c2c_distance()]){
                    circle(r=small_gear_flange_radius(), $fn=small_gear_fn());
                }
            }
        }
    }
    translate([0,gear_c2c_distance()-7.8,gear_h]){
        motor_clearance(h=h-gear_h);
    }
}

/* Clearance for the thumbwheels, without motor.

It's positioned with the centre of the thumbwheel at the origin.

:param side_pillar_h: is the z height of the access cut-outs. This is equivalent
    to the gear_h parameter for motor_and_gear_clearance().
:param h: height of the cut-out.
*/
module thumbwheel_clearance(side_pillar_h=10, h=999){
    thumbwheel_r = 20;
    small_gear_nominal_r = 8.5;
    linear_extrude(h){
        offset(1.5){
            hull(){
                circle(r=thumbwheel_r, $fn=32);
                translate([0,gear_c2c_distance()]){
                    circle(r=small_gear_nominal_r, $fn=32);
                }
            }
        }
    }
    // Motor lugs and screw cut-outs are not necessary for thumbwheels,
    // but the motor lugs are useful in defining the illuminator mount shape,
    // and the blank screw cut-outs make more space to hold the thumbwheel
    translate([0, gear_c2c_distance()-7.8, side_pillar_h]){
        motor_lug_clearance(r=5.2, h=h, hulled=true);
    }
}
