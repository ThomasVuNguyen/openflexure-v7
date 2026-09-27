use <librender/hardware.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/test_pieces/nut_trap_test.scad>


FRAME=3;

render_prepare_nut_trap_test(FRAME);

module render_prepare_nut_trap_test(frame){
    params = render_params();
    if (frame==1){
        render_nut_trap_test();
        trap_nut(exploded=true);
    }else if (frame==2){
        render_nut_trap_test();
        trap_nut(low=true);
        trap_nut_temp_screw(turn=false,exploded=true);
    }else if (frame==3){
        render_nut_trap_test();
        trap_nut();
        trap_nut_temp_screw(turn=true);
    }
}

module render_nut_trap_test(){
    coloured_render(body_colour()){
        nut_trap_test_object();
    }
}

module trap_nut_temp_screw(turn=false, exploded=false){
    explode = 15;
    screw_height = 10;
    screw_pos = exploded ? [0, 0 , screw_height+explode] : [0, 0, screw_height];
    if (exploded){
        construction_line([0, 0, 2], [0, 0, 2+explode]);
    }
    place_part(screw_pos){
        m3_cap_x10();
        if (turn){
            translate_z(4){
                turn_clockwise(5);
            }
        }
    }
}

module trap_nut(nut_num=0, low=false, exploded=false){
    nut_height = 2.2;
    nut_pos = exploded ? [-15, 0, nut_height] :
        low ? [0, 0, nut_height] : [0, 0, nut_height+2.5];
    rotate_z(-90){
        if (exploded){
            construction_line([-15, 0, nut_height], [0, 0, nut_height]);
        }
        place_part(nut_pos){
            m3_nut(center=true);
        }
    }
}
