


use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/lib_microscope_stand.scad>
use <../openscad/electronics_drawer.scad>
use <librender/assembly_parameters.scad>
use <librender/render_utils.scad>
use <librender/render_settings.scad>
use <librender/hardware.scad>
use <librender/electronics.scad>
use <./electronics/sangaboard.scad>
use <./mount_motors.scad>
use <./mount_sample_clips.scad>
use <./mount_microscope.scad>
use <./prepare_pi_and_sangaboard.scad>

FRAME = 16;
OPTICS_VERSION = "rms";

render_mount_electronics(FRAME, OPTICS_VERSION);

module render_mount_electronics(frame, optics_version="rms"){
    if (frame == 1){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true, exploded=true);
    }
    if (frame == 2){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true, exploded=false);
    }
    if (frame == 3){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=true, pi_rotated=true);
    }
    if (frame == 4){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=true);
        render_rpi_4b_screws(slide=true, exploded=true);
    }
    if (frame == 5){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
    }
    if (frame == 6){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
        render_rpi_ribbon(slide=true, exploded=true);
    }
    if (frame == 7){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
        render_rpi_ribbon(slide=true, exploded=false);
    }
    if (frame == 8){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
        render_rpi_ribbon(slide=true, exploded=false);
        render_sangaboard_v0_5(slide=true, exploded=true);
        render_sangaboard_screws(slide=true, exploded=true);
    }
    if (frame == 9){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
        render_rpi_ribbon(slide=true, exploded=false);
        render_sangaboard_v0_5(slide=true, exploded=false);
        render_sangaboard_screws(slide=true, exploded=false);
    }
    if (frame == 10){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
        render_rpi_ribbon(slide=true, exploded=false);
        render_sangaboard_v0_5(slide=true, exploded=false);
        render_sangaboard_screws(slide=true, exploded=false);
        render_motor_wire_placed(motor_number=0, long=true, slide=true, exploded=true);
    }
    if (frame == 11){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
        render_rpi_ribbon(slide=true, exploded=false);
        render_sangaboard_v0_5(slide=true, exploded=false);
        render_sangaboard_screws(slide=true, exploded=false);
        render_motor_wire_placed(motor_number=0, long=true, slide=true, exploded=false);
    }
    if (frame == 12){
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true, exploded=false);
        render_rpi_4b_screws(slide=true, exploded=false);
        render_rpi_ribbon(slide=true, exploded=false);
        render_sangaboard_v0_5(slide=true, exploded=false);
        render_sangaboard_screws(slide=true, exploded=false);
        render_motor_wire_placed(motor_number=0, long=true, slide=true);
        render_motor_wire_placed(motor_number=1, long=true, slide=true);
        render_motor_wire_placed(motor_number=2, long=true, slide=true);
    }
    if (frame == 13){
        microscope_with_clips(optics_version=optics_version);
        render_electronics_drawer(slide=true);
        render_drawer_nut(slide=true);
        render_rpi_4b(slide=true);
        render_rpi_4b_screws(slide=true);
        render_rpi_ribbon(bent=true, slide=true, exploded=false);
        render_sangaboard_v0_5(slide=true);
        render_sangaboard_screws(slide=true);
        render_motor_wire_placed(motor_number=0, long=true, slide=true);
        render_motor_wire_placed(motor_number=1, long=true, slide=true);
        render_motor_wire_placed(motor_number=2, long=true, slide=true);
    }
    if (frame == 14){
        microscope_with_clips(optics_version=optics_version);
        render_electronics_drawer(slide=false);
        render_drawer_nut(slide=false);
        render_rpi_4b(slide=false);
        render_rpi_4b_screws(slide=false);
        render_sangaboard_v0_5(slide=false);
        render_sangaboard_screws(slide=false);
    }
    if (frame == 15){
        microscope_with_clips(optics_version=optics_version);
        render_electronics_drawer(slide=false);
        render_drawer_nut(slide=false);
        render_rpi_4b(slide=false);
        render_rpi_4b_screws(slide=false);
        render_sangaboard_v0_5(slide=false);
        render_sangaboard_screws(slide=false);
        render_electronics_drawer_screw(exploded=true);
    }
    if (frame == 16){
        microscope_with_clips(optics_version=optics_version);
        render_electronics_drawer(slide=false);
        render_drawer_nut(slide=false);
        render_rpi_4b(slide=false);
        render_rpi_4b_screws(slide=false);
        render_sangaboard_v0_5(slide=false);
        render_sangaboard_screws(slide=false);
        render_electronics_drawer_screw(exploded=false);
    }
}

module microscope_with_clips(optics_version="rms", manual=false, post=false){
    assembled_microscope_without_electronics(optics_version=optics_version, manual=manual, post=post);
    mounted_microscope_frame(manual=manual, post=post){
        render_sample_clips();
    }
}

module render_electronics_drawer(slide=false){
    slide_out = slide? [100,0,0] : [0,0,0] ; 
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out){
            coloured_render(body_colour()){
                electronics_drawer_stl(pi_version=4, sanga_version="stack_11mm");
            }
        }
    }
}

module render_drawer_nut(slide=false, exploded=false){
    slide_out = slide? [100,0,0] : [0,0,0] ; 
    explode = exploded ? [0,6.9,15] : [0,6.9,0] ;
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out){
            translate(explode){
                translate(electronics_drawer_side_screw_pos()){
                    if (exploded){
                        construction_line([0,0,-3], [0,0,-explode.z]);
                    }                
                    rotate_x(90){
                        rotate_z(30){
                            m3_nut(center=true);
                        }
                    }
                }
            }
        }
    }
}

module render_rpi_4b(slide=false, exploded=false, pi_rotated=false){
    slide_out = slide ? [100,0,0] : [0,0,0] ;
    explode = exploded ? [0,0,0.5] : [0,0,0] ;
    place = pi_rotated ? insert_pi_rotation_pos() : create_placement_dict([0,0,0]);
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out + explode){
            translate(electronics_drawer_board_inset() + [0, 0, electronics_drawer_standoff_h()]){
                place_part(place){
                    pi_and_sd_card();
                }
            }
        }
    }
}

function insert_pi_rotation_pos() = let(
    x = pi_board_dims().x,
    y = pi_board_dims().y,
    angle = (8/80)*180/3.14
    )create_placement_dict(translation=[x,y,0], rotation1=[0,0,-angle], init_translation=[-x,-y,0]);

module render_rpi_4b_screws(slide=false, exploded=false){
    slide_out = slide ? [100,0,0] : [0,0,0] ;
    explode = exploded ? [0,0,15] : [0,0,0] ;
    hole_pos = pi_hole_pos(true);
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out + explode){
            translate([0, 0, electronics_drawer_standoff_h()+1]){
                for (i = [2, 3]){
                    translate(hole_pos[i]){
                        no2_x6_5_selftap();
                    }
                    if (exploded){
                        construction_line(hole_pos[i], hole_pos[i]-[0,0,20]);
                    }
                }
            }
        }
    }
}

module render_rpi_ribbon(bent=false, slide=false, exploded=false){
    last_pos = bent ? [-20, 11, 38] : [50, 11, 300];
    ribbon_pos = [create_placement_dict([45.7, 11, 12.5], [0, 0, 180], [0, 270, 0]),
                create_placement_dict([45, 11, 15], [0, 0, 180], [0, 270, 0]),
                create_placement_dict([45, 11, 32], [0, 0, 180], [0, 270, 0]),
                create_placement_dict([44, 11, 35], [0, 0, 180], [0, 270, 0]),
                create_placement_dict(last_pos, [0, 0, 180], [0, 0, 0])];
    slide_out = slide ? [100,0,0] : [0,0,0] ;
    explode = exploded ? [0,0,15] : [0,0,0] ;
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out + explode){
            translate(electronics_drawer_board_inset() + [0, 0, electronics_drawer_standoff_h()]){
                picamera_cable(ribbon_pos);
            }
        }
    }
}

module render_motor_wire_placed(motor_number=0, long=false, slide=false, exploded=false){
    slide_out = slide ? [100,0,0] : [0,0,0] ;
    explode = exploded ? [0,0,10] : [0,0,0] ;
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out + explode){
            render_motor_wire(motor_number=motor_number, long=long);
        }
    }
}

module render_motor_wire(motor_number=0, long=false){
    end_x = long ? -110 : -10 ;
    motor_connector_pos = [[28,11.5,23.5],[35.5,11.5,23.5],[43,11.5,23.5]];
    motor_wire_offset = 1.5;
    wire_run = [[0,0,1.1],[0,0,8],[-2,0,10],[-20,2,10],[end_x,2,10]];
    colours = ["blue", "pink", "yellow", "orange", "red"];
    wire_pos = [-5.08, -2.54, 0, 2.54, 5.08];
    translate(motor_connector_pos[motor_number]){
        rotate_z(270){
            motor_jst_connector();
        }
        translate_z(motor_wire_offset * motor_number){
            for (i = [0:4]){
                translate_y(wire_pos[i]){
                    coloured_render(colours[i]){
                        wire(d=1,points=wire_run);
                    }
                }
            }
        }
    }
}

module render_sangaboard_v0_5(slide=false, exploded=false){
    slide_out = slide ? [100,0,0] : [0,0,0] ;
    explode = exploded ? [0,0,12] : [0,0,0] ;
    hole_pos = pi_hole_pos(true);
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out + explode){
            translate(electronics_drawer_board_inset() + [0, 0, sanga_stand_height("stack_11mm")]){
                sangaboard_v0_5();
            }
        }
    }
}

module render_sangaboard_screws(slide=false, exploded=false){
    slide_out = slide ? [100,0,0] : [0,0,0] ;
    stack = 11.5 + 5; // stack height 11.5mm, plus two board thicknesses, plus header base thickness
    explode = exploded ? [0,0,25] : [0,0,0] ;
    hole_pos = pi_hole_pos(true);
    electronics_drawer_frame_xy(render_params()){
        translate(slide_out + explode){
            translate([0, 0, electronics_drawer_standoff_h()+stack]){
                for (i = [0, 1]){
                    translate(hole_pos[i]){
                        no2_x6_5_selftap();
                    }
                    if (exploded){
                        construction_line(hole_pos[i], hole_pos[i]-[0,0,30]);
                    }
                }
            }
        }
    }
}

module render_electronics_drawer_screw(exploded=false){
    explode_side = exploded ? [0,-15,0] : [0,0,0] ;
    explode_front = exploded ? [25,0,0] : [0,0,0] ;
    electronics_drawer_frame_xy(render_params()){
        translate(explode_side){
            translate(electronics_drawer_side_screw_pos()){
                if (exploded){
                    construction_line([0,0,0], -explode_side);
                }
                rotate_x(90){
                    m3_cap_x10();
                }
            }
        }
        translate(explode_front){
            translate(electronics_drawer_front_screw_pos()){
                if (exploded){
                    construction_line([0,0,0], -explode_front);
                }
                rotate([90,0,90]){
                    m3_cap_x10();
                }
            }
        }
    }
}

module render_microscope(optics_version="rms", manual=false, post=false){
        microscope_with_clips(optics_version=optics_version, manual=manual, post=post);
        if (!manual){
            render_electronics_drawer(slide=false);
            render_rpi_4b(slide=false);
            render_rpi_4b_screws(slide=false);
            render_sangaboard_v0_5(slide=false);
            render_sangaboard_screws(slide=false);
            render_electronics_drawer_screw(exploded=false);
        }
}
