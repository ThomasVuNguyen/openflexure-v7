use <../openscad/libs/upright_z_axis.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>
use <librender/render_utils.scad>
use <librender/hardware.scad>
use <prepare_main_body.scad>

FRAME = 7;

render_prepare_upright_z_mount(FRAME);

module render_prepare_upright_z_mount(frame){
    params = render_params();
    if (frame==1){
        z_mount_nut(exploded=true, low=false, right=true, front=true);
        coloured_render(body_colour()){
            translate_z(0){
                upright_z_spacer_labelled(params, 1);
            }
        }
    }
    if (frame==2){
        z_mount_temp_screw(exploded=true, right=true, front=true);
        z_mount_nut(exploded=false, low=true, right=true, front=true);
        coloured_render(body_colour()){
            translate_z(0){
                upright_z_spacer_labelled(params, 1);
            }
        }
    }
    if (frame==3){
        z_mount_temp_screw(exploded=false, right=true, front=true, turn=true);
        z_mount_nut(exploded=false, low=false, right=true, front=true);
        coloured_render(body_colour()){
            translate_z(0){
                upright_z_spacer_labelled(params, 1);
            }
        }
    }
    if (frame==4){
        z_mount_nut(exploded=false, low=false, right=true, front=true);
        z_mount_nut(exploded=true, low=false, right=true, front=false);
        z_mount_nut(exploded=true, low=false, right=false, front=true);
        z_mount_nut(exploded=true, low=false, right=false, front=false);
        coloured_render(body_colour()){
            translate_z(0){
                upright_z_spacer_labelled(params, 1);
            }
        }
    }
    if (frame==5){
        z_mount_nut(exploded=false, low=false, right=true, front=true);
        z_mount_temp_screw(exploded=true, right=true, front=false);
        z_mount_nut(exploded=false, low=true, right=true, front=false);
        z_mount_temp_screw(exploded=true, right=false, front=true);
        z_mount_nut(exploded=false, low=true, right=false, front=true);
        z_mount_temp_screw(exploded=true, right=false, front=false);
        z_mount_nut(exploded=false, low=true, right=false, front=false);
        coloured_render(body_colour()){
            translate_z(0){
                upright_z_spacer_labelled(params, 1);
            }
        }
    }
    if (frame==6){
        z_mount_nut(exploded=false, low=false, right=true, front=true);
        z_mount_temp_screw(exploded=false, right=true, front=false, turn=true);
        z_mount_nut(exploded=false, low=false, right=true, front=false);
        z_mount_temp_screw(exploded=false, right=false, front=true, turn=true);
        z_mount_nut(exploded=false, low=false, right=false, front=true);
        z_mount_temp_screw(exploded=false, right=false, front=false, turn=true);
        z_mount_nut(exploded=false, low=false, right=false, front=false);
        coloured_render(body_colour()){
            translate_z(0){
                upright_z_spacer_labelled(params, 1);
            }
        }
    }
    if (frame==7){
        prepared_upright_z_mount();
    }
}

module z_mount_temp_screw(exploded=false, right=true, front=true, turn=false){
    params=render_params();
    screw_pos = exploded ? z_mount_temp_screw_pos_exp(params, right, front) : z_mount_screw_pos(params, right, front);
    // translate from the mounted screw position, by the thickness of the plastic part and the washer
    translate_z(-3.3){
        // screw
        place_part(screw_pos){
            m3_cap_x10();
            if (turn){
                translate_z(4){
                    turn_clockwise(5);
                }
            }
        }
        // construction line
        if (exploded){
            construction_line(translate_pos(z_mount_screw_pos(params, right, front), [0, 0, -10]),
                            z_mount_temp_screw_pos_exp(params, right, front),
                            .2);
        }
    }
}

module z_mount_nut(exploded=false, low=false, right=true, front=true){
    params=render_params();
    nut_pos_basic = exploded ? z_mount_nut_pos_exp(params, right, front) : z_mount_nut_pos(params, right, front);
    z_low = low ? -2 : 0;
    nut_pos = front ? nut_pos_basic : 
                        right ? replace_value("rotation3", 30+45, nut_pos_basic) : 
                                replace_value("rotation3", 30-45, nut_pos_basic);
    translate_z(z_low){
        // nut
        place_part(nut_pos){
            m3_nut();
        }
        // construction line
        if (exploded){
            construction_line(translate_pos(z_mount_nut_pos(params, right, front), [0, 0, -2+1.25]),
                            translate_pos(z_mount_nut_pos_exp(params, right, front), [0, 0, +1.25]),
                            .2);
        }
    }
}

module prepared_upright_z_mount(){
    params=render_params();
    z_mount_nut(exploded=false, low=false, right=true, front=true);
    z_mount_nut(exploded=false, low=false, right=true, front=false);
    z_mount_nut(exploded=false, low=false, right=false, front=true);
    z_mount_nut(exploded=false, low=false, right=false, front=false);
    coloured_render(body_colour()){
        translate_z(0){
            upright_z_spacer_labelled(params, 1);
        }
    }
}
