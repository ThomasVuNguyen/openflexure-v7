
use <../openscad/libs/lib_microscope_stand.scad>
use <../openscad/libs/utilities.scad>
use <./librender/render_utils.scad>
use <./librender/render_settings.scad>
use <./librender/assembly_parameters.scad>
use <./librender/hardware.scad>
use <mount_optics.scad>
use <prepare_stand.scad>


FRAME = 1;
OPTICS_VERSION = "rms"; // "rms", "low_cost", "c270", "upright"
MANUAL = false;
POST = false; // use simple post stand for manual?

render_mount_microscope(FRAME, OPTICS_VERSION, MANUAL, POST);

module render_mount_microscope(frame, optics_version, manual=false, post=false){
    assert(!(post && !manual), "Post stand only for manual microscope");
    if (frame==1){
        mounted_microscope(optics_version=optics_version, manual=manual, post=post, exploded=true);
    }
    else if (frame==2){
        mounted_microscope(optics_version=optics_version, manual=manual, post=post);
    }
}

module mounted_microscope(stand_params=default_stand_params(), optics_version="rms", manual=false, post=false, exploded=false){
    assert(!(post && !manual), "Post stand only for manual microscope");
    params = render_params();
    stand_params = render_stand_params(manual=manual, post=post);
    stand_prepared(params, stand_params, manual=manual, post=post);
    screws = (manual && post) ? [0, 1] : [0, 1, 2, 3] ;
    for (i = screws){
        stand_lug_screw(params, stand_params, i, exploded=exploded);
    }
    mounted_microscope_frame(manual=manual, post=post, exploded=exploded){
        body_with_optics(optics_version=optics_version, manual=manual);
    }
}

module mounted_microscope_frame(manual=false, post=false, exploded=false){
    stand_params = render_stand_params(manual=manual, post=post);
    place_part(microscope_on_stand_pos(stand_params, exploded=exploded)){
        children();
    }
}

module stand_lug_screw(params, stand_params, screw_num=0, turn=false, exploded=false){
    screw_pos = exploded ? stand_lug_pos_exp(params, stand_params, screw_num) : stand_lug_pos(params, stand_params, screw_num);
    if (exploded){
        construction_line(stand_lug_pos(params, stand_params, screw_num),
                          stand_lug_pos_exp(params, stand_params, screw_num),
                          .25);
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
