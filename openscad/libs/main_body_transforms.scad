/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope body transforms              *
*                                                                 *
* Various transforms used in the microscope.                      *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>
use <libdict.scad>
use <./microscope_parameters.scad>

module shear_x(amount=1){
    // Shear transformation: tilt the Y axis towards the X axis
    // e.g. if amount=1, then a straight line in Y will be
    // tilted to 45 degrees between X and Y, while X lines are
    // unchanged.  This is used in the Z axis.

    shear_matrix = [[1, amount, 0, 0],
                    [0, 1, 0, 0],
                    [0, 0, 1, 0],
                    [0, 0, 0, 1]];

    multmatrix(shear_matrix){
        children();
    }
}


module leg_frame(params, angle){
    leg_r = key_lookup("leg_r", params);
    // Transform into the frame of one of the legs of the stage
    rotate(angle){
        translate([0,leg_r,]){
            children();
        }
    }
}

module each_leg(params){
    // Repeat for each of the legs of the stage
    for(angle=[45,135,-135,-45]){
        leg_frame(params, angle){
            children();
        }
    }
}

module each_actuator(params){
    // Repeat this for both of the actuated legs (the ones with levers)
    reflect_x(){
        leg_frame(params,45){
            children();
        }
    }
}

module y_actuator_frame(params){
    translate(y_actuator_pos(params)){
        rotate(45){
            children();
        }
    }
}