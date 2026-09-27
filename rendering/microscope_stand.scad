
use <../openscad/libs/utilities.scad>
use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/lib_microscope_stand.scad>
use <../openscad/nano_converter_plate.scad>
use <./librender/electronics.scad>
use <./electronics/sangaboard.scad>
use <./librender/assembly_parameters.scad>
use <./librender/render_utils.scad>
use <./librender/render_settings.scad>
use <./librender/hardware.scad>
use <mount_motors.scad>

OPTICS_VERSION = "rms";
microscope_stand_rendered(optics_version=OPTICS_VERSION);

module microscope_stand_rendered(optics_version="rms", use_nano=false){
    params = render_params();
    
    slide = true;
    slide_dist = slide ? 90 : 0;
    rendered_electronics_drawer(params, use_nano=use_nano, slide_dist=slide_dist);

    electronics_drawer_frame_xy(params){
        translate(electronics_drawer_front_nut_trap_pos()){
            rotate_y(90){
                m3_nut();
            }
        }
        translate(electronics_drawer_side_screw_pos()){
            rotate_x(90){
                m3_cap_x10();
            }
        }
        
        translate(electronics_drawer_front_screw_pos()){
            rotate_y(90){
                m3_cap_x10();
            }
        }
    }
    connector_positions = [x_connector_pos_board(params),
                           y_connector_pos_board(params),
                           z_connector_pos_board(params)];
    connector_positions_out = [x_connector_pos_board_out(params, slide_dist),
                               y_connector_pos_board_out(params, slide_dist),
                               z_connector_pos_board_out(params, slide_dist)];
    con_pos = slide ? connector_positions_out : connector_positions;

    cable_positions = [y_cable_verticies(slide), y_cable_verticies(slide), z_cable_verticies(slide)];

    assembled_microscope_without_electronics(optics_version=optics_version,
                                             connector_positions=con_pos,
                                             cable_positions=cable_positions);
}



module rendered_electronics_drawer(params, use_nano=false, slide_dist=0){
    stand_params = default_stand_params();
    coloured_render(extras_colour()){
        electronics_drawer_frame_xy(params, slide_dist=slide_dist){
            electronics_drawer(stand_params);
        }
    }
    electronics_drawer_frame_xy(params, slide_dist=slide_dist){
        inset = electronics_drawer_board_inset();
        pi_pos = inset + [0, 0, electronics_drawer_standoff_h()] ;
        sanga_pos = inset + [0, 0, sanga_stand_height()];
        translate(pi_pos){
            rpi_4b();
        }

        translate(sanga_pos){
            if (use_nano){
                coloured_render(extras_colour()){
                    nano_converter_plate();
                }
            }
            else{
                sangaboard_v0_5();
            }
        }

        translate_z(sangaboard_v0_5_dims().z){
            translate(sanga_pos + pi_hole_pos()[0]){
                no2_x6_5_selftap();
            }
            translate(sanga_pos + pi_hole_pos()[1]){
                no2_x6_5_selftap();
            }
            if (use_nano){
                block_hole_pos = electronics_drawer_block_hole_pos();
                plate_screw_pos = [block_hole_pos.x, block_hole_pos.y, sanga_pos.z];
                translate(plate_screw_pos){
                    no2_x6_5_selftap();
                }
            }
        }
        translate_z(pi_board_dims().z){
            translate(pi_pos + pi_hole_pos()[2]){
                no2_x6_5_selftap();
            }
            translate(pi_pos + pi_hole_pos()[3]){
                no2_x6_5_selftap();
            }
        }
        translate(electronics_drawer_side_nut_trap_pos()){
            rotate_x(90){
                rotate_z(30){
                    m3_nut();
                }
            }
        }
        
    }
}
