/******************************************************************
*                                                                 *
* OpenFlexure Microscope: actuator tension band                   *
*                                                                 *
* The microscope stage actuators need a tension band to provide a *
* reciprocal force between the captive nut in the gear and the    *
* stage arm. The recommendation is to use a Viton O-ring, but if  *
* you have a 3d printer can reliably print with TPU filament, you *
* can print this instead and use it in place of the O-ring.       *
*                                                                 *
* Print this part using .1mm layer height, with randomized        *
* perimeter start and end positions if possible. For strength,    *
* The part should be printed entirely with perimeters, no gap     *
* fill. The part is designed to be printed with a 0.4mm nozzle.   *
* Printing with a 1mm nozzle hasn't been tested, and isn't        *
* recommended.
*                                                                 *
* (c) Bill Schaller, June 2020                                    *
* Released under the CERN Open Hardware License v1.2              *
*                                                                 *
******************************************************************/


$fn = 64;

actuator_tension_band(nozzle_width=0.4);

module actuator_tension_band(nozzle_width){
    band_height = 1.8;
    ideal_band_thickness = 1.5;
    band_inner_diameter = 30;

    actual_band_thickness = ideal_band_thickness - (ideal_band_thickness % nozzle_width);
    band_outer_diameter = band_inner_diameter + actual_band_thickness * 2;

    difference(){
        cylinder(h=band_height, d=band_outer_diameter, center = true);
        cylinder(h=band_height+1, d=band_inner_diameter, center = true);
    }
}
