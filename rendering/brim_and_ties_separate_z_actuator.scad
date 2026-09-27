use <../openscad/libs/upright_z_axis.scad>
use <../openscad/libs/z_axis.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <../openscad/libs/microscope_parameters.scad>
use <librender/render_settings.scad>
use <librender/rendered_separate_z_actuator.scad>

FRAME = 1;

render_brim_and_ties_separate_z_actuator(FRAME);

module render_brim_and_ties_separate_z_actuator(frame){
    params = default_params();
    smart_brim_r = key_lookup("smart_brim_r", params);
    if (frame==1){
        color(remove_colour()){
            render(6){
                exterior_brim(r=smart_brim_r, brim_only=true){
                   separate_z_actuator(params, cable_guides = false, cable_housing = false, rectangular = true);
                }
            }
        }
    }
    color((frame==2)? remove_colour() : body_colour()){
        z_actuator_column(params, ties_only=true);
    }
    color(body_colour()){
        render(6){
            rendered_separate_z_actuator();
        }
    }
}
