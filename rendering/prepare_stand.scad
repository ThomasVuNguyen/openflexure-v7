use <librender/hardware.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/lib_microscope_stand.scad>
use <../openscad/libs/simple_post_stand_lib.scad>

FRAME = 1;
MANUAL = false;
POST = false; // render manual microscope with simple post stand

render_prepare_stand(FRAME, MANUAL, POST);

module render_prepare_stand(frame, manual=false, post=false){
    assert(!(post && !manual), "Post stand only for manual microscope");
    params = render_params();
    stand_params = render_stand_params(manual=manual, post=post);
    if (frame==1){
        assert(!manual, "There are no stand supports to remove for the manual stand");
        render_stand(params, stand_params);
        coloured_render(remove_colour()){
            stand_supports(params, stand_params);
        }
    }else if (frame==2){
        render_stand(params, stand_params, manual=manual, post=post);
        stand_nut(params, stand_params, exploded=true);
    }else if (frame==3){
        render_stand(params, stand_params, manual=manual, post=post);
        stand_nut(params, stand_params, low=true);
        stand_nut_temp_screw(params, stand_params, exploded=true);
    }else if (frame==4){
        render_stand(params, stand_params, manual=manual, post=post);
        stand_nut(params, stand_params);
        stand_nut_temp_screw(params, stand_params, turn=true);
    }else if (frame==5){
        render_stand(params, stand_params, manual=manual, post=post);
        stand_nut(params, stand_params);
        stand_nut(params, stand_params, nut_num=1, exploded=true);
        if (!(manual && post)){
            stand_nut(params, stand_params, nut_num=2, exploded=true);
            stand_nut(params, stand_params, nut_num=3, exploded=true);
        }
    }
    else if (frame==6){
        render_stand(params, stand_params, manual=manual, post=post);
        stand_nut(params, stand_params);
        stand_nut(params, stand_params, nut_num=1);
        stand_nut_temp_screw(params, stand_params, nut_num=1, turn=true);
        if (!(manual && post)){
            stand_nut(params, stand_params, nut_num=2);
            stand_nut_temp_screw(params, stand_params, nut_num=2, turn=true);
            stand_nut(params, stand_params, nut_num=3);
            stand_nut_temp_screw(params, stand_params, nut_num=3, turn=true);
        }
    }
    else if (frame==7){
        stand_prepared(params, stand_params, manual=manual, post=post);
    }
    // last frames used when putting in the nut for fitting
    // the electronics drawer, wiring.md
    else if (frame==8){
        assert(!manual, "There is no electronics drawer nut for the manual stand");
        stand_prepared(params, stand_params);
        render_electronics_drawer_nut(exploded=true);
    }
    else if (frame==9){
        assert(!manual, "There is no electronics drawer nut for the manual stand");
        stand_prepared(params, stand_params);
        render_electronics_drawer_nut(exploded=false);
    }
}

function render_stand_params(manual=false, post=false) = let(
        params_no_pi = default_stand_params(tall=false, no_pi=true),
        z_nominal = microscope_stand_height(params_no_pi)-microscope_depth(),
        post_mount_height = key_lookup("foot_height", default_params()),
        st_params_post = replace_value("extra_height", post_mount_height-z_nominal, params_no_pi),
        st_params_normal = default_stand_params(tall=false, no_pi=false)
    ) !manual? st_params_normal : post? st_params_post : params_no_pi;

module stand_prepared(params, stand_params, manual=false, post=false){
    render_stand(params, stand_params, manual=manual, post=post);
    stand_nut(params, stand_params);
    stand_nut(params, stand_params, nut_num=1);
    if (!(manual && post)){
        stand_nut(params, stand_params, nut_num=2);
        stand_nut(params, stand_params, nut_num=3);
    }
}

module render_stand(params, stand_params, manual=false, post=false){
    coloured_render(stand_colour()){
        if (manual && post){
            simple_post_stand(params);
        }
        else{
            microscope_stand(params, stand_params, supports=false);
        }
    }
}

module stand_nut_temp_screw(params, stand_params, nut_num=0, turn=false, exploded=false){
    nut_pos = exploded ? stand_nut_temp_screw_pos_exp(params, stand_params, nut_num) : stand_nut_temp_screw_pos(params, stand_params, nut_num);
    if (exploded){
        construction_line(stand_nut_temp_screw_pos(params, stand_params, nut_num), stand_nut_temp_screw_pos_exp(params, stand_params, nut_num));
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

module stand_nut(params, stand_params, nut_num=0, low=false, exploded=false){
    nut_pos = exploded ? stand_nut_placement_exp(params, stand_params, nut_num) :
        low ? stand_nut_placement_low(params, stand_params, nut_num) : stand_nut_placement(params, stand_params, nut_num);
    if (exploded){
        construction_line(stand_nut_placement_low(params, stand_params, nut_num), stand_nut_placement_exp(params, stand_params, nut_num));
    }
    place_part(nut_pos){
        m3_nut(center=true);
    }
}

module render_electronics_drawer_nut(exploded=false){
    explode = exploded ? [0,0,15] : [0,0,0] ;
    electronics_drawer_frame_xy(render_params()){
        translate(explode + [-6.9,0,0]){
            translate(electronics_drawer_front_screw_pos()){
                if (exploded){
                    translate_x(1){
                        construction_line([0,0,-1.5], -explode);
                    }
                }
                rotate([90,30,90]){
                    m3_nut();
                }
            }
        }
    }
}
