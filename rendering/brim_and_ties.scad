use <../openscad/libs/main_body_structure.scad>
use <../openscad/libs/z_axis.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <librender/assembly_parameters.scad>
use <../openscad/libs/microscope_parameters.scad>
use <librender/render_settings.scad>
use <librender/rendered_main_body.scad>

FRAME = 1;
MANUAL = false;

render_brim_and_ties(FRAME, MANUAL);

module render_brim_and_ties(frame, manual=false){
    function no_lug_params() = let(
        params = render_params()
    ) replace_value("include_motor_lugs", false, params);

    params = !manual ? default_params() : no_lug_params();;
    smart_brim_r = key_lookup("smart_brim_r", params);

    if (frame==1){
        color(remove_colour()){
            render(6){
                exterior_brim(r=smart_brim_r, brim_only=true){
                    main_body(params, version_string="", hash="");
                }
            }
        }
    }
    color((frame==3)? remove_colour() : body_colour()){
        xy_leg_ties(params);
    }
    color((frame==2)? remove_colour() : body_colour()){
        xy_actuators(params, ties_only=true);
    }
    color((frame==2)? remove_colour() : body_colour()){
        z_actuator_column(params, ties_only=true);
    }
    color(body_colour()){
        render(6){
            rendered_main_body(manual=manual);
        }
    }
}