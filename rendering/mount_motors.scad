


use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/gears.scad>
use <../openscad/libs/wall.scad>
use <../openscad/libs/main_body_transforms.scad>
use <../openscad/libs/z_axis.scad>
use <../openscad/libs/main_body_structure.scad>
use <../openscad/libs/cable_tidies_lib.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>
use <librender/render_utils.scad>
use <librender/hardware.scad>
use <mount_illumination.scad>
use <mount_microscope.scad>
use <mount_upright_optics.scad>
use <motor_assembly.scad>

FRAME = 5;
OPTICS_VERSION = "low_cost"; // "upright", "low_cost", "rms"
render_mount_motors(FRAME, OPTICS_VERSION);

module render_mount_motors(frame, optics_version="rms"){
    if (frame == 1){
        assembled_microscope_without_electronics(optics_version=optics_version,
                                                 xy_motor=true,
                                                 z_motor=false,
                                                 cable_tidy_screw=false,
                                                 explode="xy");
    }
    else if (frame == 2){
        assembled_microscope_without_electronics(optics_version=optics_version,
                                                 xy_motor=true,
                                                 z_motor=false,
                                                 cable_tidy_screw=false,
                                                 explode="none");
    }
    else if(frame == 3){
        assembled_microscope_without_electronics(optics_version=optics_version,
                                                 cable_tidy_screw=false,
                                                 explode="z");
    }
    else if(frame == 4){
        assembled_microscope_without_electronics(optics_version=optics_version, cable_tidy_screw=false);
    }
    else if(frame == 5){
        assembled_microscope_without_electronics(optics_version=optics_version,
                                                 cable_tidy_screw=true,
                                                 explode = "cable_tidy_screw");
    }
    else if(frame == 6){
        assembled_microscope_without_electronics(optics_version=optics_version);
    }
}

// This module will add motors for a motorised version, but will pass through a manual version unchanged 
module assembled_microscope_without_electronics(optics_version="rms",
                                                manual=false,
                                                post=false,
                                                xy_motor=true,
                                                z_motor=true,
                                                explode=undef,
                                                connector_positions=[undef, undef, undef],
                                                cable_positions=[undef, undef, undef],
                                                cable_tidy_screw=true){
    params = render_params();
    if (!manual){
        mounted_microscope_frame(){
            if (xy_motor){
                exploded = explode == "xy";
                mirror([1, 0, 0]){
                    y_motor_and_cap(params,
                                    exploded=exploded,
                                    connector_pos=connector_positions.x,
                                    cable_pos=cable_positions.x,
                                    mirror_connector=true);
                }
                y_motor_and_cap(params,
                                exploded=exploded,
                                connector_pos=connector_positions.y,
                                cable_pos=cable_positions.y);
            }

            if (z_motor){
                exploded = explode == "z";
                z_motor_and_cap(params,
                                optics_version=optics_version,
                                exploded=exploded,
                                connector_pos=connector_positions.z,
                                cable_pos=cable_positions.z,
                                cap=true);
            }
            if (cable_tidy_screw){
                exploded = explode == "cable_tidy_screw" ;
                cable_tidy_screws(params, exploded=exploded);
            }
        }
    }
    if (optics_version == "upright"){
        mounted_microscope_upright_with_optics(optics_version=optics_version, manual=manual);
    }
    else{
        mounted_microscope_with_illumination(optics_version=optics_version, manual=manual, post=post);
    }
}

module y_motor_and_cap(params, exploded=false, connector_pos=undef, cable_pos=undef, mirror_connector=false){
    y_connector_pos = is_undef(connector_pos) ? y_connector_pos(params) : connector_pos;
    y_cable_pos = is_undef(cable_pos) ? y_cable_verticies() : cable_pos;
    explode_unit = exploded ? 10 : 0;
    y_actuator_frame(params){
        translate_z(explode_unit){
            motor_with_gear(y_motor_pos(params),
                            y_connector_pos,
                            y_cable_pos,
                            mirror_connector=mirror_connector);
        }

        translate_z(y_motor_z_pos(params) + 3*explode_unit){
            reflect_x(){
                place_part(motor_screw_pos()){
                    m3_cap_x10();
                    if (exploded){
                        construction_line([0, 0, 0], [0, 0, -4*explode_unit], 0.2);
                    }
                }
            }
        }
    }

    coloured_render(extras_colour()){
        translate_z(side_housing_h(params)+2*explode_unit){
            side_cable_tidy(params);
        }
    }   
}

module z_motor_and_cap(params, optics_version="rms", exploded=false, connector_pos=undef, cable_pos=undef, cap=false){
    z_connector_pos = is_undef(connector_pos) ? z_connector_pos() : connector_pos;
    z_cable_pos = is_undef(cable_pos) ? z_cable_verticies() : cable_pos;
    explode_unit = exploded ? 10 : 0;
    explode_cable_tidy = (optics_version=="upright") ? 0.5 : 2;

    if (cap){
        coloured_render(extras_colour()){
            if (exploded){
                z_cable_tidy_frame(params, explode_cable_tidy*explode_unit){
                    z_cable_tidy_frame_undo(params){
                        if (optics_version=="upright"){
                            front_cable_tidy_upright(params);
                        }
                        else{
                            front_cable_tidy(params);
                        }
                    }
                }
            }
            else{
                if (optics_version=="upright"){
                    front_cable_tidy_upright(params);
                }
                else{
                    front_cable_tidy(params);
                }
            }
        }
    }
    motor_placement = (optics_version=="upright") ? locate_on_upright(): create_placement_dict([0,0,0]) ; 
    place_part(motor_placement){
        z_cable_tidy_frame(params){
            translate_z(explode_unit){
                motor_with_gear(z_motor_pos(), z_connector_pos, z_cable_pos);
            }
            tight_screw = (optics_version=="upright") ? -1.5 : 0 ;
            translate_z(3*explode_unit + tight_screw){
                reflect_x(){
                    place_part(motor_screw_pos()){
                        m3_cap_x10();
                        if (exploded){
                            construction_line([0, 0, 0], [0, 0, -4*explode_unit], 0.2);
                        }
                    }
                }
            }
        }
    }
    if (optics_version=="upright"){
        // screws for the main body z cable tidy
        z_cable_tidy_frame(params){
            tight_screw = -0.5 ;
            translate_z(2*explode_unit + tight_screw){
                reflect_x(){
                    place_part(motor_screw_pos()){
                        m3_cap_x10();
                        if (exploded){
                            construction_line([0, 0, 0], [0, 0, -4*explode_unit], 0.2);
                        }
                    }
                }
            }
        }
    }
}

module cable_tidy_screws(params, exploded){
    ex_dist = 20;
    h = exploded ? side_housing_h(params) + ex_dist : side_housing_h(params) + 1.5;
    screw_location = side_housing_screw_pos() + [0, 0, h];
    reflect_x(){
        side_housing_placement(params){
            translate(side_housing_cut_pos()){
                translate(screw_location){
                    no2_x6_5_selftap();
                    if (exploded){
                        construction_line([0, 0, 0], [0, 0, -ex_dist]);
                    }
                }
            }
        }
    }
}
