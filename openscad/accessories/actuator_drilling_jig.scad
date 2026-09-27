/******************************************************************
*                                                                 *
* OpenFlexure Microscope: actuator column drilling jig            *
*                                                                 *
* If you need to drill out the hole for the M3 screw, it's not    *
* hard to snap the flexure at the bottom of the actuator column.  *
* This tool is inserted from the bottom of the microscope to stop *
* the column rotating, and hopefully avoid snapping the flexure.  *
* To use it, slide it in from the bottom.  Then, when you drill   *
* out the hole, hold the tool and *not* the body of the           *
* microscope, so no torque goes through the microscope body.      *
* An M4 screw can be used to mount the tool to a workbench.       *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <../libs/microscope_parameters.scad>
use <../libs/utilities.scad>
use <../libs/libdict.scad>
use <../libs/compact_nut_seat.scad>

actuator_drilling_jig();

module actuator_drilling_jig(){
    params = default_params();
    actuator_h = key_lookup("actuator_h", params);
    outer_clearance = 0.5;
    clearance_radius = column_base_radius() + outer_clearance;

    difference(){
        translate_z(-7){
            offset_thick_section(h=actuator_h+5, offset=-outer_clearance, center=false, shift=false){
                nut_seat_void();
            }
        }

        //void for the actuator column
        minkowski(){
            actuator_column(actuator_h+1, no_voids=true, flip_nut_slot=true);
            cylinder(r=0.5, h=tiny(), $fn=8);
        }
        //clearance for the lever
        translate_x(-clearance_radius){
            mirror([0,1,0]){
                cube([clearance_radius*2,999,999]);
            }
        }
        //clearance for the column core
        cylinder(r=clearance_radius, $fn=16, h=999);
        //mounting bolt
        translate_z(-4){
            cylinder(r=4,h=6);
        }
        cylinder(r=2.6,h=999,center=true);
    }
}