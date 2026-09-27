use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <../openscad/libs/gears.scad>
use <librender/electronics.scad>
use <librender/render_utils.scad>
use <librender/render_settings.scad>
use <librender/assembly_parameters.scad>
use <./librender/hardware.scad>


FRAME=1;

motor_assembly(FRAME);

module motor_assembly(frame){
    if (frame==1){
        motor_with_gear(exploded=true);
    }else if (frame==2){
        motor_with_gear();
    }
}


module motor_with_gear(motor_pos=[0, 0, 0], connector_pos=undef, wire_points=[], exploded=false, mirror_connector=false){

    gear_pos = exploded ? small_gear_pos_exp() : small_gear_pos();
    // Rotate motor shaft angle to match small gear, which itself is rotated to mesh with the large gear.
    // reverse the angle because the motor is built shaft down and the gear is built shaft up.
    gear_angle = key_lookup("rotation2", gear_pos);
    shaft_angle = - gear_angle.z + 90; 
    if (exploded){
        construction_line(small_gear_pos_exp(), small_gear_pos());
    }
    motor28BYJ48(motor_pos, connector_pos, wire_points, mirror_connector=mirror_connector, shaft_angle=shaft_angle);
    place_part(motor_pos){
        place_part(gear_pos){
            coloured_render(extras_colour()){
                small_gear();
            }
            screw_pos =  exploded ?
                small_gear_screw_pos_exp() :
                small_gear_screw_pos();
            reflect_y(){
                if (exploded){
                    construction_line(small_gear_screw_pos_exp(), small_gear_screw_pos());
                }
                place_part(screw_pos){
                    no2_x6_5_selftap();
                }
            }
            
        }
    }
}
