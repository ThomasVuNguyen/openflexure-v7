use <../openscad/libs/libfeet.scad>
use <../openscad/libs/utilities.scad>
use <librender/render_utils.scad>
use <librender/render_settings.scad>
use <librender/assembly_parameters.scad>
use <librender/tools.scad>
use <mount_microscope.scad>
use <mount_illumination.scad>
use <mount_optics.scad>

FRAME = 1;

render_mount_upright_optics(FRAME, optics_version="upright");

module render_mount_upright_optics(frame, optics_version="upright"){
    assert(optics_version=="upright","The upright optics mounting renders only apply to the upright optics version");
    if (frame == 1){
        mounted_microscope_frame(){
            om_pos = translate_pos(optics_module_pos(low_cost=true), [0, -10, -6.5]);
            render_upright_optics(om_pos, screw_tight=false);
        }
        mounted_microscope_with_illumination(optics_version=optics_version);
    }
    else if (frame == 2){
        mounted_microscope_frame(){
            om_pos = translate_pos(optics_module_pos(low_cost=true), [0, -4, -6.5]);
            render_upright_optics(om_pos, screw_tight=false);
        }
        mounted_microscope_with_illumination(optics_version=optics_version);
    }
    else if (frame == 3){
        mounted_microscope_frame(){
            om_pos = translate_pos(optics_module_pos(low_cost=true), [0, -4, -6.5]);
            ak_pos = translate_pos(optics_module_insertion_allen_key_pos(), [0, 0, -6.5]);
            place_part(locate_on_upright()){
                place_part(ak_pos){
                    allen_key_2_5(30);
                }
            }
            render_upright_optics(om_pos, screw_tight=false);
        }
        mounted_microscope_with_illumination(optics_version=optics_version);
    }
    else if (frame == 4){
        mounted_microscope_frame(){
            om_pos = translate_pos(optics_module_pos(low_cost=true), [0, -4, 0]);
            ak_pos = optics_module_allen_key_pos();
            place_part(locate_on_upright()){
                place_part(ak_pos){
                    allen_key_2_5(30);
                }
            }
            render_upright_optics(om_pos, screw_tight=false);
        }
        mounted_microscope_with_illumination(optics_version=optics_version);
    }
    else if (frame == 5){
        mounted_microscope_frame(){
            om_pos = optics_module_pos(low_cost=true);
            ak_pos = optics_module_allen_key_pos();
            place_part(locate_on_upright()){
                place_part(ak_pos){
                    allen_key_2_5(-30, clockwise_arrow=true);
                }
            }
            render_upright_optics(om_pos, screw_tight=true);
        }
        mounted_microscope_with_illumination(optics_version=optics_version);
    }
    else if (frame == 6){
        mounted_microscope_frame(){
            om_pos = optics_module_pos(low_cost=true);
            place_part(locate_on_upright()){
                place_part(z_foot_cap_placement()){
                    explode=10;
                    translate_z(-explode){
                        rotate_x(180){
                            color(extras_colour()){
                                foot_cap();
                            }
                        }
                    }
                }
            }
            render_upright_optics(om_pos, screw_tight=true);
        }
        mounted_microscope_with_illumination(optics_version=optics_version);
    }
    else if (frame == 7){
        mounted_microscope_upright_with_optics(optics_version=optics_version);
    }
}

module mounted_microscope_upright_with_optics(optics_version="upright", manual=false){
    assert(optics_version=="upright","The upright optics mounting renders only apply to the upright optics version");
    mounted_microscope_frame(manual=manual){
            place_part(locate_on_upright()){
                om_pos = optics_module_pos(low_cost=true);
                render_optics("low_cost", om_pos, screw_tight=true);
                place_part(z_foot_cap_placement()){
                    rotate_x(180){
                        color(extras_colour()){
                            foot_cap();
                        }
                    }
                }
            }
    }
    mounted_microscope_with_illumination(optics_version=optics_version, manual=manual);
}

module render_upright_optics(om_pos=undef, screw_tight=false){
    place_part(locate_on_upright()){
        render_optics("low_cost", om_pos=om_pos, screw_tight=screw_tight);
    }
}
