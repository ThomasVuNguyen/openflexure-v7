use <../openscad/libs/main_body_structure.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/main_body_transforms.scad>
use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/z_axis.scad>
use <librender/hardware.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>
use <librender/rendered_main_body.scad>

FRAME = 13;
MANUAL = false;

render_prepare_main_body(FRAME,MANUAL);

module render_prepare_main_body(frame, manual=false){
    params = render_params();
    if (frame==1){
        render_body(manual=manual);
        stage_nut(params, exploded=true);
    } else if (frame==2){
        render_body(manual=manual);
        stage_nut(params, low=true);
        stage_nut_temp_screw(params, exploded=true);
    } else if (frame==3){
        render_body(manual=manual);
        stage_nut(params);
        stage_nut_temp_screw(params, turn=true);
    } else if (frame==4){
        render_body(manual=manual);
        stage_nut(params);
        stage_nut(params, nut_num=1, exploded=true);
        stage_nut(params, nut_num=2, exploded=true);
        stage_nut(params, nut_num=3, exploded=true);
    } else if (frame==5){
        render_body(manual=manual);
        stage_nut(params);
        stage_nut(params, nut_num=1);
        stage_nut_temp_screw(params, nut_num=1, turn=true);
        stage_nut(params, nut_num=2);
        stage_nut_temp_screw(params, nut_num=2, turn=true);
        stage_nut(params, nut_num=3);
        stage_nut_temp_screw(params, nut_num=3, turn=true);
    } else if (frame==6){
        main_body_stage_prepared(params, manual=manual);
    } else if (frame==7){
        main_body_stage_prepared(params, manual=manual);
        illum_platform_nut(params, right=true, exploded=true);
        illum_platform_nut(params, right=false, exploded=true);
    } else if (frame==8){
        main_body_stage_prepared(params, manual=manual);
        illum_platform_nut(params, right=true, low=true);
        illum_platform_nut_temp_screw(params, right=true, exploded=true);
        illum_platform_nut(params, right=false, low=true);
        illum_platform_nut_temp_screw(params, right=false, exploded=true);
    } else if (frame==9){
        main_body_stage_prepared(params, manual=manual);
        illum_platform_nut(params, right=true);
        illum_platform_nut_temp_screw(params, right=true, turn=true);
        illum_platform_nut(params, right=false);
        illum_platform_nut_temp_screw(params, right=false, turn=true);
    } else if (frame==10){
        main_body_illumination_prepared(params, manual=manual);
        y_motor_nut(params, right=false, exploded=true, low=true);
        y_motor_nut(params, right=true, exploded=true, low=true);
    } else if (frame==11){
        main_body_illumination_prepared(params, manual=manual);
        y_motor_nut(params, right=true, low=true);
        y_motor_nut(params, right=false, low=true);
        y_motor_nut_temp_screw(params, right=true, exploded=true);
        y_motor_nut_temp_screw(params, right=false, exploded=true);
    } else if (frame==12){
        main_body_illumination_prepared(params, manual=manual);
        y_motor_nut(params, right=false);
        y_motor_nut(params, right=true);
        y_motor_nut_temp_screw(params, right=true, turn=true);
        y_motor_nut_temp_screw(params, right=false, turn=true);
    } else if (frame==13){
        main_body_illumination_prepared(params, manual=manual);
        z_motor_nut(params, right=false, exploded=true, low=true);
        z_motor_nut(params, right=true, exploded=true, low=true);
    } else if (frame==14){
        main_body_illumination_prepared(params, manual=manual);
        z_motor_nut(params, right=true, low=true);
        z_motor_nut(params, right=false, low=true);
        z_motor_nut_temp_screw(params, right=true, exploded=true);
        z_motor_nut_temp_screw(params, right=false, exploded=true);
    } else if (frame==15){
        main_body_illumination_prepared(params, manual=manual);
        z_motor_nut(params, right=false);
        z_motor_nut(params, right=true);
        z_motor_nut_temp_screw(params, right=true, turn=true);
        z_motor_nut_temp_screw(params, right=false, turn=true);
    }
}

module main_body_stage_prepared(params, translucent_body=false, manual=false){
    stage_nut(params);
    stage_nut(params, nut_num=1);
    stage_nut(params, nut_num=2);
    stage_nut(params, nut_num=3);
    render_body(translucent_body=translucent_body, manual=manual);
}

module main_body_illumination_prepared(params, translucent_body=false, manual=false){
    illum_platform_nut(params, right=false);
    illum_platform_nut(params, right=true);
    main_body_stage_prepared(params, translucent_body=translucent_body, manual=manual);
}

module main_body_prepared(translucent_body=false, manual=false, upright=false){
    params = render_params();
    if (!manual){
        reflect_x(){
            y_motor_nut(params, right=true);
            y_motor_nut(params, right=false);
        }
        z_motor_nut(params, right=false);
        z_motor_nut(params, right=true);
    }
    main_body_illumination_prepared(params, translucent_body=translucent_body, manual=manual);
}

module render_body(translucent_body=false, manual=false){
    alpha = translucent_body ? 0.2 : 1.0;
    rendered_main_body(body_colour(), alpha, manual=manual);
}

module stage_nut_temp_screw(params, nut_num=0, turn=false, exploded=false){
    nut_pos = exploded ? stage_nut_temp_screw_pos_exp(params) : stage_nut_temp_screw_pos(params);
    rotate_z(45+nut_num*90){
        if (exploded){
            construction_line(stage_nut_temp_screw_pos(params), stage_nut_temp_screw_pos_exp(params));
        }
        place_part(nut_pos){
            m3_cap_x10();
            if (turn){
                translate_z(4){
                    turn_clockwise(5);
                }
            }
        }
    }
}

module stage_nut(params, nut_num=0, low=false, exploded=false){
    nut_pos = exploded ? stage_nut_placement_exp(params) :
        low ? stage_nut_placement_low(params) : stage_nut_placement(params);
    rotate_z(45+nut_num*90){
        if (exploded){
            construction_line(stage_nut_placement_low(params), stage_nut_placement_exp(params));
        }
        place_part(nut_pos){
            m3_nut(center=true);
        }
    }
}

module illum_platform_nut(params, right=true, low=false, exploded=false){
    nut_pos = exploded ? illum_platform_nut_placement_exp(params, right) :
        low ? illum_platform_nut_placement_low(params, right) : illum_platform_nut_placement(params, right);
    if (exploded){
        construction_line(illum_platform_nut_placement_low(params, right), illum_platform_nut_placement_exp(params, right));
    }
    place_part(nut_pos){
        m3_nut(center=true);
    }
}

module illum_platform_nut_temp_screw(params, right=true, turn=false, exploded=false){
    nut_pos = exploded ? illum_platform_nut_temp_screw_pos_exp(params, right) : illum_platform_nut_temp_screw_pos(params, right);
    if (exploded){
        construction_line(illum_platform_nut_temp_screw_pos(params, right), illum_platform_nut_temp_screw_pos_exp(params, right));
    }
    place_part(nut_pos){
        m3_cap_x10();
        if (turn){
            translate_z(4){
                turn_clockwise(5);
            }
        }
    }
}

module y_motor_nut(params, right=true, exploded=false, low=false){
    explode_unit = exploded ? (right ? [-12, 0, -2.5] : [12, 0, -2.5] ) : [0, 0, low ? -2.5 : 0];
    y_actuator_frame(params){
        place_part(motor_screw_pos() + [right ? 0 : -motor_screw_separation(), 0, y_motor_z_pos(params)-7]){
            translate(explode_unit){
                m3_nut();
            }
            if (exploded){
                construction_line([0, 0, -1.5], [right ? -8 : 8, 0, -1.5]);
            }
        }
    }
}

module y_motor_nut_temp_screw(params, right=true, exploded=false, turn=false){
    explode_unit = exploded ? [0, 0, 20] : [0, 0, 0];
    y_actuator_frame(params){
        place_part(motor_screw_pos() + [right ? 0 : -motor_screw_separation(), 0, y_motor_z_pos(params)-2]){
            translate(explode_unit){
                m3_cap_x10();
            }
            if (exploded){
                construction_line([0, 0, 20], [0, 0, 0]);
            }
            if (turn){
                translate_z(4){
                    turn_clockwise(5);
                }
            }
        }
    }
}

module z_motor_nut(params, right=true, exploded=false, low=false){
    z_low = (low) ? -2.5 : 0;
    explode_x = 12;
    explode_unit = exploded ? (right ? [-explode_x, 0, -2.5] : [explode_x, 0, -2.5] ) : [0, 0, z_low];
    z_cable_tidy_frame(params){
        translate([right ? motor_screw_separation()/2 : -motor_screw_separation()/2, 12, -5]){
            translate(explode_unit){
                m3_nut();
            }
            if (exploded){
                line_x = explode_x - 1.5;
                construction_line([0, 0, -1.5], [right ? -line_x : line_x, 0, -1.5]);
            }
        }
    }
}

module z_motor_nut_temp_screw(params, right=true, exploded=false, turn=false){
    explode_unit = exploded ? [0, 0, 20] : [0, 0, 0];
    z_cable_tidy_frame(params){
        translate([right ? motor_screw_separation()/2 : -motor_screw_separation()/2, 12, 0]){
            translate(explode_unit){
                m3_cap_x10();
            }
            if (exploded){
                construction_line([0, 0, 20], [0, 0, 0]);
            }
            if (turn){
                translate_z(4){
                    turn_clockwise(5);
                }
            }
        }
    }
}
