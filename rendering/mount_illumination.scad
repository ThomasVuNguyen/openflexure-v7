use <../openscad/libs/illumination.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <../openscad/libs/lib_microscope_stand.scad>
use <librender/render_settings.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/hardware.scad>
use <librender/electronics.scad>
use <actuator_assembly.scad>
use <mount_microscope.scad>
use <prepare_stand.scad>
use <prepare_upright_z_mount.scad>
use <condenser_assembly.scad>
use <mount_optics.scad>
use <../openscad/libs/z_axis.scad>
use <../openscad/libs/upright_z_axis.scad>

FRAME = 5;
OPTICS_VERSION = "rms"; // "rms", "low_cost", "c270", "upright"
MANUAL = true;

mount_illumination(FRAME, OPTICS_VERSION, MANUAL);

module mount_illumination(frame, optics_version="rms", manual=false){

    stand_params = render_stand_params(manual=manual);
    z_actual = microscope_stand_height(stand_params)-microscope_depth();
    if (frame == 1){
        mounted_microscope_frame(manual=manual){
            if (optics_version=="upright"){
                rendered_upright_z_spacer_assembly(exploded=true);
            }
            else {
                rendered_illumination_dovetail_assembly(exploded=true);
            }
        }
        mounted_microscope(stand_params=stand_params, optics_version=optics_version, manual=manual);
    }
    else if (frame == 2){
        mounted_microscope_frame(manual=manual){
            if (optics_version=="upright"){
                rendered_upright_z_spacer_assembly();
            }
            else {
                rendered_illumination_dovetail_assembly();
            }
        }
        mounted_microscope(stand_params=stand_params, optics_version=optics_version, manual=manual);
    }
    else if (frame == 3){
        mounted_microscope_frame(manual=manual){
            if (optics_version=="upright"){
                rendered_upright_z_spacer_assembly();
                rendered_upright_z_axis(exploded=true, manual=manual);
            }
            else {
                rendered_illumination_dovetail_assembly();
                feeding_illumination_wire(exploded=true);
            }
        }
        mounted_microscope(stand_params=stand_params, optics_version=optics_version, manual=manual);
    }
    else if (frame == 4){
        mounted_microscope_frame(manual=manual){
            if (optics_version=="upright"){
                rendered_upright_z_spacer_assembly();
                rendered_upright_z_axis(, manual=manual);
            }
            else {
                rendered_illumination_dovetail_assembly();
                feeding_illumination_wire(exploded=false);
            }
        }
        mounted_microscope(stand_params=stand_params, optics_version=optics_version, manual=manual);
    }
    else if (frame == 5){
        if (optics_version=="upright"){
            // For upright the assembly steps finish in frame 4; This is the final frame to be rendered and
            // is equivalent to frame == 8 for other microscopes.
            mounted_microscope_with_illumination(stand_params=stand_params, optics_version=optics_version, manual=manual);
        }
        else {
            mounted_microscope_frame(manual=manual){
                rendered_illumination_dovetail_assembly();
                rendered_condenser_assembly(pos=condenser_pos_exp(), include_led=false);
                illumination_wiring(manual=manual, exploded=true);                
            }
        }
        mounted_microscope(stand_params=stand_params, optics_version=optics_version, manual=manual);
    }
    else if (frame == 6){
        if (optics_version=="upright"){
            // Nothing to show. Frame 5 is the final frame for the upright.
        }
        else{
            mounted_microscope_frame(manual=manual){
                rendered_illumination_dovetail_assembly();
                rendered_condenser_assembly(pos=condenser_pos_exp(), include_led=false);
                illumination_wiring(manual=manual, exploded=true);
            }
            line_offset = [0 ,35, z_actual-20];
            line_pos1 = translate_pos(condenser_pos_exp(), line_offset);
            line_pos2 = translate_pos(condenser_pos(), line_offset);
            construction_line(line_pos1, line_pos2, .4, arrow=true);
        }
        mounted_microscope(stand_params=stand_params, optics_version=optics_version, manual=manual);
    }
    else if (frame == 7){
        if (optics_version=="upright"){
            // Nothing to show. Frame 5 is the final frame for the upright.
        }
        else {
            mounted_microscope_frame(manual=manual){
                rendered_illumination_dovetail_assembly();
                rendered_condenser_assembly(include_led=false, tighten_arrow=true);
                illumination_wiring(manual=manual);
            }
        }
        mounted_microscope(stand_params=stand_params, optics_version=optics_version, manual=manual);
    }
    else if (frame == 8){
        if (optics_version=="upright"){
            // Nothing to show. Frame 5 is the final frame for the upright.
        }
        else{
            mounted_microscope_with_illumination(stand_params=stand_params, optics_version=optics_version, manual=manual);
        }
    }
}

module mounted_microscope_with_illumination(stand_params=default_stand_params(), optics_version="rms", manual=false, post=false){
    mounted_microscope_frame(manual=manual, post=post){
        if (optics_version=="upright"){
            rendered_upright_z_spacer_assembly();
            rendered_upright_z_axis(manual=manual);
        }
        else{
            rendered_illumination_dovetail_assembly();
            rendered_condenser_assembly(include_led=false);
            illumination_wiring(manual=manual);
        }
    }
    mounted_microscope(stand_params, optics_version=optics_version, manual=manual, post=post);
}

module rendered_upright_z_spacer_assembly(exploded=false){
    params = render_params();
    dovetail_lift = exploded ? 10 : 0;
    translate_z(dovetail_lift){
        prepared_upright_z_mount();
    }
    upright_z_spacer_screw(params, right=true, exploded=exploded);
    upright_z_spacer_screw(params, right=false, exploded=exploded);
    upright_z_spacer_back_screw(params, exploded=exploded);
}

module rendered_illumination_dovetail_assembly(exploded=false){
    params = render_params();
    dovetail_lift = exploded ? 10 : 0;
    coloured_render(body_colour()){
        translate_z(dovetail_lift){
            illumination_dovetail(params, h = 60);
        }
    }
    illumination_dovetail_screw(params, right=true, exploded=exploded);
    illumination_dovetail_screw(params, right=false, exploded=exploded);
}

module illumination_dovetail_screw(params, right=true, turn=false, exploded=false){
    screw_pos = exploded ? illum_dovetail_screw_pos_exp(params, right=right) : illum_dovetail_screw_pos(params, right=right);
    washer_pos = exploded ? illum_dovetail_washer_pos_exp(params, right=right) : illum_dovetail_washer_pos(params, right=right);
    if (exploded){
        construction_line(translate_pos(illum_dovetail_screw_pos(params, right=right), [0, 0, -10]),
                          illum_dovetail_screw_pos_exp(params, right=right),
                          .2);
    }
    place_part(screw_pos){
        m3_cap_x10();
        if (turn){
            translate_z(4){
                turn_clockwise(5);
            }
        }
    }
    place_part(washer_pos){
        m3_washer();
    }
}

// The two wires powering the illumination PCB
module illumination_wiring(params=render_params(), exploded=false, manual=false){
    top_z = condenser_z()+2 + (exploded ? 30 : 0); //NB should match `condenser_pos_exp()`
    housing_top = illumination_cable_housing_top_pos(params, z_extra=2);
    drop = illumination_dovetail_z(params) - housing_top.z;
    base_point_1 = (manual) ? left_illumination_screw_pos(params) + [0, -5, -65] : housing_top ;
    base_point_2 = (manual) ? base_point_1 + [-5, -5, -5] : illumination_cable_housing_bottom_pos(params) ;
    points=[
        [0,10,top_z],
        [0,illumination_dovetail_y()-2,top_z],
        illumination_cable_channel_xypos() + [0,0,top_z],
        illumination_cable_channel_xypos() + [0,0,illumination_dovetail_z(params)],
        left_illumination_screw_pos(params) + [-5, -5, -drop/2],
        base_point_1,
        base_point_2
    ];
    coloured_render("DimGray"){
        wire(
            d=1,
            points=flat_wire_points(d=1, points=points, n=2, index=0)
        );
    }
    coloured_render("red"){
        wire(
            d=1,
            points=flat_wire_points(d=1, points=points, n=2, index=1)
        );
    }
}

module feeding_illumination_wire(params=render_params(), exploded=false){
    top_z = condenser_z() +30;
    corner_z = illumination_dovetail_z(params) + (exploded ? 30 : 15);

    connector_pos = exploded ?
        illumination_cable_channel_xypos() + [0,0,illumination_dovetail_z(params)+15] :
        illumination_cable_channel_xypos() + [-5,0,illumination_dovetail_z(params)-5];
    
    points=[
        [0,illumination_dovetail_y()-2,top_z],
        illumination_cable_channel_xypos() + [0,0,top_z],
        illumination_cable_channel_xypos() + [0.1,0,corner_z],
        connector_pos + [0,0,10]
    ];
    translate(connector_pos){
        dupont_connector_housing(2, center=true);
    }
    coloured_render("DimGray"){
        wire(
            d=1,
            points=flat_wire_points(d=1, points=points, n=2, index=0, connector_d=2.5, connector_vector=[1,0,0])
        );
    }
    coloured_render("red"){
        wire(
            d=1,
            points=flat_wire_points(d=1, points=points, n=2, index=1, connector_d=2.5, connector_vector=[1,0,0])
        );
    }
}

module rendered_upright_z_axis(exploded=false, manual=false){
    params=render_params();
    lift = (exploded ? 10 : 0);
    z_translate = illumination_dovetail_z(params)*2 + upright_z_spacer_height(params,1) + lift;
    translate_z(z_translate){
        rotate_y(180){
            separate_z_actuator_with_assembled_actuators(manual=manual);
        }
    }
    z_mount_screw(exploded, right=true, front=true);
    z_mount_screw(exploded, right=false, front=true);
    z_mount_screw(exploded, right=true, front=false);
    z_mount_screw(exploded, right=false, front=false);
}

module upright_z_spacer_screw(params, right=true, turn=false, exploded=false){
    screw_pos = exploded ? illum_dovetail_screw_pos_exp_short(params, right=right) : illum_dovetail_screw_pos(params, right=right);
    washer_pos = exploded ? illum_dovetail_washer_pos_exp_short(params, right=right) : illum_dovetail_washer_pos(params, right=right);
    if (exploded){
        construction_line(translate_pos(illum_dovetail_screw_pos(params, right=right), [0, 0, -10]),
                          illum_dovetail_screw_pos_exp(params, right=right),
                          .2);
    }
    place_part(screw_pos){
        m3_cap_x10();
        if (turn){
            translate_z(4){
                turn_clockwise(5);
            }
        }
    }
    place_part(washer_pos){
        m3_washer();
    }
}

module upright_z_spacer_back_screw(params, turn=false, exploded=false){
    screw_pos = exploded ? illum_dovetail_back_screw_pos_exp(params) : illum_dovetail_back_screw_pos(params);
    washer_pos = exploded ? illum_dovetail_back_washer_pos_exp(params) : illum_dovetail_back_washer_pos(params);
    if (exploded){
        construction_line(translate_pos(illum_dovetail_back_screw_pos(params), [0, 0, -10]),
                          illum_dovetail_back_screw_pos_exp(params),
                          .2);
    }
    place_part(screw_pos){
        m3_cap_x10();
        if (turn){
            translate_z(4){
                turn_clockwise(5);
            }
        }
    }
    place_part(washer_pos){
        m3_washer();
    }
}

module z_mount_screw(exploded=false, right=true, front=true){
    params=render_params();
    screw_pos = exploded ? z_mount_screw_pos_exp(params, right, front) : z_mount_screw_pos(params, right, front);
    washer_pos = exploded ? z_mount_washer_pos_exp(params, right, front) : z_mount_washer_pos(params, right, front);

    // screw
    place_part(screw_pos){
        m3_cap_x10();
    }
    // washer
    place_part(washer_pos){
        m3_washer();
    }
    // construction line
    if (exploded){
        construction_line(translate_pos(z_mount_screw_pos(params, right, front), [0, 0, -10]),
                          z_mount_screw_pos_exp(params, right, front),
                          .2);
    }
}

function locate_on_upright() = let(
    z_offset = key_lookup("sample_z",render_params()),
    init_translation = [0, 0, -z_offset],
    rotation1 = [0, 180, 0],
    rotation2 = [0, 0, 0],
    rotation3 = [0, 0, 0],
    translation = [0, 0, z_offset + 1] // +1mm for the standard nominal sample thickness
) create_placement_dict(translation, rotation3, rotation2, rotation1, init_translation);
