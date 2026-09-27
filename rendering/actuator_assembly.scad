
use <../openscad/libs/gears.scad>
use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/lib_actuator_assembly_tools.scad>
use <../openscad/libs/libfeet.scad>
use <../openscad/libs/upright_z_axis.scad>
use <../openscad/libs/lib_gear_tools.scad>
use <librender/hardware.scad>
use <librender/tools.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>
use <prepare_main_body.scad>
use <prepare_separate_z_actuator.scad>


FRAME = 2;
OPTICS_VERSION = "rms"; // "rms", "upright"
MANUAL = true;

render_actuator_assembly(FRAME, MANUAL, OPTICS_VERSION);

module render_actuator_assembly(frame, manual=false, optics_version="rms"){
    upright = (optics_version=="upright");
    if (frame==1){
        what_you_need(manual=manual, optics_version=optics_version);
    }else if (frame==2){
        mount_lead_screw(manual=manual, exploded=true, tools=true);
    }else if (frame==3){
        mount_lead_screw(manual=manual, exploded=false, tools=true);
    }else if (frame==4){
        mount_lead_screw(manual=manual, exploded=false, tools=false);
    }else if (frame==5){
        body_with_x_nut(manual=manual, upright=upright, exploded=true);
    }else if (frame==6){
        body_with_x_gear(manual=manual, upright=upright, exploded=true);
    }
    else if (frame==7){
        body_with_x_gear(manual=manual, upright=upright, exploded=false);
    }
    else if (frame==8){
        body_with_x_gear(manual=manual, upright=upright, exploded=false, lifted=true);
        place_part(x_lead_oil_placement()){
            oil_bottle();
        }
    }
    else if (frame==9){
        body_with_assembled_actuators(manual=manual, upright=upright, x_only=true);
    }
    else if (frame==10){
        body_with_assembled_actuators(manual=manual, upright=upright, x_only=false);
    }
    else if (frame==11){
        separate_z_actuator_with_assembled_actuators(manual=manual);
    }
    
}

module render_foot(foot, lie_flat=false){
    color(extras_colour()){
        render(6){
            if ((foot == "X") || (foot == "Y")){
                outer_foot(render_params(), lie_flat=lie_flat, letter=foot);
            }
            else{
                middle_foot(render_params(), lie_flat=lie_flat, letter="Z");
            }
        }
    }
}

module what_you_need(manual=false, optics_version="rms"){
    params = render_params();
    spacing = manual ? 45 : 40;
    offset_x = manual ? -8 : 0;
    axes = (optics_version=="upright") ? 4 : 3;
    translate_x(offset_x){
    repeat([0, spacing, 0],axes,center=true){
        color(extras_colour()){
            if (manual) {
                thumbwheel();
            }
            else {
                large_gear();
            }
        }
        translate_x(-21){
            rotate_y(90){
                rotate_z(30){
                    m3_hex_x25();
                }
            }
        }
        translate([-28, 6, 0]){
            m3_washer();
        }
        translate([-36, 6, 0]){
            m3_washer();
        }
        translate([-32, -6, 0]){
            m3_nut(brass=true);
        }
        translate_x(-32){
            viton_band();
        }

    }
    }
    translate([28, spacing*((axes-1)/2), 0]){
        rotate_z(90){
            render_foot("X", lie_flat=true);
        }
    }
    repeat([0, spacing, 0],(axes-2),center=true){
        translate_x(28){
            rotate_z(90){
                render_foot("Z", lie_flat=true);
            }
        }
    }
    translate([28, -spacing*((axes-1)/2), 0]){
        rotate_z(90){
            render_foot("Y", lie_flat=true);
        }
    }
    color(tools_colour()){
        render(6){
            translate_x(50){
                band_tool_arms(params, vertical=false);
            }
        }
    }
    color(tools_colour()){
        render(6){
            translate([70, 18, 1.7]){
                band_tool_holder(params);
            }
        }
    }
    color(tools_colour()){
        render(6){
            translate([70, 56, 0]){
                nut_tool();
            }
        }
    }
    coloured_render(tools_colour()){
        translate([70, -54, 0]){
            rotate_z(90){
                nut_spinner();
            }
        }
    }
    if (!manual){
        coloured_render(tools_colour()){
            translate([68, -17, 0]){
                rotate_z(90){
                    gear_holder();
                }
            }
        }
    }
    translate([60, -55, 0]){
        rotate_z(30){
            m3_nut();
        }
    }
}

module x_nut(exploded=false){
    nut_pos = exploded ? x_nut_placement_exp() : x_nut_placement();
    if (exploded){
        construction_line(x_nut_placement(), x_nut_placement_exp());
    }
    place_part(nut_pos){
        m3_nut(brass=true, center=true);
    }
}

module x_lead_screw_assembly(manual=false, exploded=false){
    lead_assembly_pos = exploded ? x_lead_assembly_placement_exp() : x_lead_assembly_placement();
    place_part(lead_assembly_pos){
        lead_screw_assembly(manual=manual, exploded=exploded, construction_offset=[0, 0, -25]);
    }
}

module x_actuator_assembly(manual=false){
    x_nut();
    x_lead_screw_assembly(manual=manual);
    place_part(x_foot_placement()){
            render_foot("X", lie_flat=false);
            viton_band_in_situ_vertical();
    }
}

module y_actuator_assembly(manual=false){
    place_part(y_nut_placement()){
        m3_nut(brass=true, center=true);
    }
    place_part(y_lead_assembly_placement()){
        lead_screw_assembly(manual=manual);
    }
    place_part(y_foot_placement()){
            render_foot("Y", lie_flat=false);
            viton_band_in_situ_vertical();
    }
}

module z_actuator_assembly(manual=false){
    place_part(z_nut_placement()){
        m3_nut(brass=true, center=true);
    }
    place_part(z_lead_assembly_placement()){
        lead_screw_assembly(manual=manual);
    }
    place_part(z_foot_placement()){
            render_foot("Z", lie_flat=false);
    }
    place_part(z_oring_placement()){
            viton_band_in_situ_vertical();
    }
}

module body_with_x_nut(manual=false, upright=false, exploded=false){
    main_body_prepared(manual=manual, upright=upright);
    x_nut(exploded=exploded);
}

module body_with_x_gear(manual=false, upright=false, exploded=false, lifted=false){
    body_with_x_nut(manual=manual, upright=upright);
    z_tr = lifted ? 5 : 0;
    translate_z(z_tr){
        x_lead_screw_assembly(manual=manual, exploded=exploded);
    }
}

module body_with_assembled_actuators(manual=false, upright=false, x_only=false, translucent_body=false){
    x_actuator_assembly(manual=manual);
    if (!x_only){
        y_actuator_assembly(manual=manual);
        z_actuator_assembly(manual=manual);
    }
    main_body_prepared(manual=manual, upright=upright, translucent_body=translucent_body);
}

module separate_z_actuator_with_assembled_actuators(manual=false){
    z_actuator_assembly(manual=manual);
    prepared_separate_z_actuator(manual=manual);
}

module lead_screw_assembly(manual=false, exploded=false, construction_offset=[0, 0, 0]){
    //The assembly of the gear the M3x25 lead screw and the two washers

    //exploded translations for the parts

    tr_wash1 = exploded ? [0 ,0, -27] : [0, 0, -.5];
    tr_wash2 = exploded ? [0 ,0, -32] : [0, 0, -1];
    //translate everything so the gear is in place at the bottom.
    translate_z(1){
        translate(large_gear_screw_pos()){
            rotate_z(30){
                m3_hex_x25();
            }
        }
        color(extras_colour()){
            if (manual) {
                thumbwheel();
            }
            else {
                large_gear();
            }
        }
        translate(tr_wash1){
            m3_washer();
        }
        translate(tr_wash2){
            m3_washer();
        }
        if (exploded){
            construction_line([0,0,0], tr_wash2+construction_offset);
        }
    }
}

module mount_lead_screw(manual=false, exploded=false, tools=false){
    tr_screw_explode = manual ? 48 : 35 ;
    tr_screw = exploded ? [0 ,0, tr_screw_explode] : large_gear_screw_pos();
    tr_nut_spinner = exploded ? [0 ,0, -7] : [0 ,0, 0];
    tr_gear_holder = exploded ? [0 ,0, 50] : [0 ,0, 11];
    tr_nut = exploded ? [0 ,0, -30] : [0 ,0, -16];

    translate(tr_screw){
        rotate_z(30){
            m3_hex_x25();
        }
    }
    color(extras_colour()){
        if (manual){
            thumbwheel();
        }
        else {
            large_gear();
        }
    }
    if (tools){
        coloured_render(tools_colour()){
            translate(tr_nut_spinner){
                rotate_x(180){
                    nut_spinner();
                }
            }
        }
        if (!manual) {
            coloured_render(tools_colour()){
                translate(tr_gear_holder){
                    rotate_x(180){
                        gear_holder();
                    }
                }
            }
        }
        translate(tr_nut){
            m3_nut();
        }
        if (!exploded){
            translate_z(-18){
                turn_anticlockwise(8);
            }
        }
    }
    if (exploded){
        construction_line(tr_gear_holder, tr_nut);
    }
}

