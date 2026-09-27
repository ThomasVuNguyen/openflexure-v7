
use <../openscad/libs/utilities.scad>
use <../openscad/libs/main_body_structure.scad>
use <../openscad/libs/z_axis.scad>
use <../openscad/libs/lib_optics.scad>
use <../openscad/libs/optics_configurations.scad>
use <../openscad/libs/cameras/logitech_c270.scad>

use <librender/assembly_parameters.scad>
use <librender/render_utils.scad>
use <librender/render_settings.scad>
use <librender/tools.scad>
use <librender/hardware.scad>

use <rms_optics_assembly.scad>
use <low_cost_optics_assembly.scad>
use <actuator_assembly.scad>
use <upright_condenser_assembly.scad>

FRAME = 8;
OPTICS_VERSION = "rms"; // "rms", "low_cost", "c270", "upright"
MANUAL = false;

render_mount_optics(FRAME, OPTICS_VERSION, MANUAL);

module render_mount_optics(frame, optics_version, manual=false){
    low_cost = (optics_version=="low_cost" || optics_version=="c270")? true : false ;
    upright = (optics_version=="upright");
    if (frame==1){
        frame1_translate = optics_version=="c270" ? [0, 10, 15] : [0, -10, -100] ;
        frame1_rotate = optics_version=="c270" ? 50 : 0 ;
        om_pos = translate_pos(optics_module_pos(low_cost), frame1_translate);
        line_start = translate_pos(om_pos, [0, 0, 40]);
        line_end = translate_pos(om_pos, [0, 0, 97]);
        if (optics_version != "c270") {
            construction_line(line_start, line_end,.3, arrow=true);
        }
        rotate_x(frame1_rotate){
            render_optics(optics_version, om_pos, screw_tight=false);
        }
        body_with_assembled_actuators(manual=manual, upright=upright);
    }
    else if (frame==2){
        om_pos = translate_pos(optics_module_pos(low_cost), [0, -10, -6.5]);
        render_optics(optics_version, om_pos, screw_tight=false);
        body_with_assembled_actuators(manual=manual, upright=upright);
    }
    else if (frame==3){
        om_pos = translate_pos(optics_module_pos(low_cost), [0, -10, -6.5]);
        rendered_z_mount();
        render_optics(optics_version, om_pos, screw_tight=false);
        body_with_assembled_actuators(manual=manual, upright=upright, translucent_body=true);
    }
    else if (frame==4){
        om_pos = translate_pos(optics_module_pos(low_cost), [0, -4, -6.5]);
        rendered_z_mount();
        render_optics(optics_version, om_pos, screw_tight=false);
        body_with_assembled_actuators(manual=manual, upright=upright, translucent_body=true);
    }
    else if (frame==5){
        om_pos = translate_pos(optics_module_pos(low_cost), [0, -4, -6.5]);
        ak_pos = translate_pos(optics_module_insertion_allen_key_pos(), [0, 0, -6.5]);
        place_part(ak_pos){
            allen_key_2_5(30);
        }
        rendered_z_mount();
        render_optics(optics_version, om_pos, screw_tight=false);
        body_with_assembled_actuators(manual=manual, upright=upright, translucent_body=true);
    }
    else if (frame==6){
        om_pos = translate_pos(optics_module_pos(low_cost), [0, -4, 0]);
        place_part(optics_module_allen_key_pos()){
            allen_key_2_5(30);
        }
        rendered_z_mount();
        render_optics(optics_version, om_pos, screw_tight=false);
        body_with_assembled_actuators(manual=manual, upright=upright, translucent_body=true);
    }
    else if (frame==7){
        place_part(optics_module_allen_key_pos()){
            allen_key_2_5(-30, clockwise_arrow=true);
        }
        rendered_z_mount();
        render_optics(optics_version, optics_module_pos(low_cost), screw_tight=true);
        body_with_assembled_actuators(manual=manual, upright=upright, translucent_body=true);
    }
    else if (frame==8){
        body_with_optics(optics_version, manual=manual);
    }
}

module render_optics(optics_version="rms", om_pos=undef, screw_tight=false,  cable_positions=undef){
    if (optics_version == "low_cost"){
        params = render_params();
        optics_config = pilens_config();
        cable_pos = is_undef(cable_positions) ?
            curled_ribbon_pos(low_cost=true, params=params, optics_config=optics_config) :
            cable_positions;
        rendered_low_cost_optics(om_pos, screw_tight=screw_tight, cable_positions=cable_pos);
    }
    else if (optics_version == "c270"){
        params = render_params();
        optics_config = c270lens_config();
        rendered_low_cost_optics(om_pos, screw_tight=screw_tight, ribbon_cable=false, camera_type="c270");
        place_part(om_pos){
            rendered_backshell();
            lens_spacer_z = lens_spacer_z(params, optics_config);
            pos = c270_backshell_screw_positions();
            for (p = pos){
                translate( [-p.x, -p.y, lens_spacer_z - p.z]){
                    mirror([0,0,1]){
                        no2_x6_5_selftap();
                    }
                }
            }
        }
    }
    else if (optics_version == "rms"){
        cable_pos = is_undef(cable_positions) ? curled_ribbon_pos() : cable_positions;
        rendered_optics_module(om_pos, screw=true, screw_tight=screw_tight, cable_positions=cable_pos);
    }
    else if (optics_version == "upright"){
        place_part(om_pos){
            completed_upright_condenser(explode="none", nut=true, screw=true, screw_tight=screw_tight);
        }

    }
}

module body_with_optics(optics_version="rms", manual=false, translucent_body=false){
    low_cost = (optics_version=="low_cost" || optics_version=="c270")? true : false ;
    upright = optics_version=="upright";
    render_optics(optics_version, optics_module_pos(low_cost), screw_tight=true);
    body_with_assembled_actuators(manual=manual, upright=upright, translucent_body=translucent_body);
}

module rendered_z_mount(manual=false){
    function no_lug_params() = let(
        params = render_params()
    ) replace_value("include_motor_lugs", false, params);    
    params = !manual ? render_params() : no_lug_params();

    coloured_render(body_colour()){
        z_axis_flexures(params);
        z_axis_struts(params);
        objective_mount(params);
    }
}
