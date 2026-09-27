use <../openscad/libs/illumination.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <../openscad/libs/gears.scad>
use <librender/render_settings.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/rendered_components.scad>
use <librender/hardware.scad>
use <librender/optics.scad>
use <librender/electronics.scad>
use <mount_microscope.scad>

// False by default so we don't need to run build before render in ci
USE_BUILT_STL = false;
FRAME = 7;
assemble_condenser(FRAME);

// Use a pre-built STL file
// TODO: make this robust to stale or missing STL files
STL_FOLDER = "../docs/models";
module cached_stl(fname){
    echo(str("Using cached STL: ", fname, ".stl"));
    import(str(STL_FOLDER, "/", fname, ".stl"));
}

module assemble_condenser(frame){
    if (frame<=3){
        insert_condenser_lens(frame);
    }
    else if(frame <= 6){
        assemble_condenser_thumbscrew(frame-3);
    }
    else if(frame <= 10){
        mount_led_board(frame-6);
    }
    else if(frame <= 12){
        mount_led_cable(frame-10);
    }
    else if(frame <= 16){
        mount_condenser_lid(frame-12);
    }
}



module assemble_condenser_thumbscrew(frame){
    explosions = ["nut", "thumbscrew", undef];
    dovetail_height = key_lookup("overall_height", condenser_dovetail_params());
    // The sloping nut trap means that it's best to put the nut in when
    // the condenser is lens-down, i.e. in its orientation as used,
    // with the print bed side on top, hence "flipped" orientation.
    flipped = create_placement_dict([0, 0, dovetail_height], [0, 180, 0]);
    echo("placement", flipped);
    thumbscrew = (frame>1) ? true : false;
    rendered_condenser_assembly(flipped,
                                include_led=false,
                                include_thumbscrew=thumbscrew,
                                include_nut=true,
                                include_lid=false,
                                explode=explosions[frame - 1]);
}

module insert_condenser_lens(frame){
    rendered_lens_tool();
    place_part(condenser_lens_tool_pos()){
        condenser_lens();
    }
    pos = (frame == 1) ? condenser_pos_above_tool() : condenser_pos_on_tool();
    cut = (frame == 3) ? true : false;
    rendered_condenser(pos, cut);
}

function condenser_upside_down() = create_placement_dict([0, 0, 30], rotation1=[0,180,0]);

module mount_led_board(frame){
    explosions = ["led_board", undef, "led_board_screws", undef];
    rendered_condenser_assembly(
        condenser_upside_down(),
        include_led=false,
        include_thumbscrew=true,
        include_nut=true,
        include_led_board=true,
        include_led_board_screws=(frame>2),
        include_lid=false,
        explode=explosions[frame - 1]
    );
}

module mount_led_cable(frame){
    rendered_condenser_assembly(
        condenser_upside_down(),
        include_led=false,
        include_thumbscrew=true,
        include_nut=true,
        include_led_board=true,
        include_led_board_screws=true,
        include_lid=false,
        explode=undef
    );
    place_part(condenser_upside_down()){
        rendered_illumination_connector(
            explode=(frame==1),
            straight_cable=true
        );
    }
}

module mount_condenser_lid(frame){
    explosions=["lid", undef, "lid_screws", undef];
    rendered_condenser_assembly(
        condenser_upside_down(),
        include_led=false,
        include_thumbscrew=true,
        include_nut=true,
        include_led_board=true,
        include_led_board_screws=true,
        include_lid=true,
        include_lid_screws=(frame>2),
        explode=explosions[frame-1]
    );
    place_part(condenser_upside_down()){
        rendered_illumination_connector(straight_cable=true);
    }
}

// The white acrylic diffuser
module rendered_diffuser(explode=false){
    coloured_render("WhiteSmoke"){
        rotate_y(180){
            translate_z(explode?5:0){
                diffuser();
            }
        }
    }
}

// The printed spacer between the diffuser and the PCB
module rendered_spacer(explode=false){
    z_pos = diffuser_thickness();
    coloured_render(extras_colour()){
        rotate_z(180){
            rotate_y(180){
                translate_z(z_pos + (explode?10:0)){
                    if (USE_BUILT_STL){
                        cached_stl("condenser_board_spacer");
                    }else{
                        condenser_board_spacer();
                    }
                }
            }
        }
    }
}

// The illumination PCB
function illumination_pcb_thickness()=1.6;
module rendered_illumination_pcb(explode=false){
    // NB z=0 is the top of the board
    z_pos = diffuser_thickness() + condenser_board_spacer_thickness() + illumination_pcb_thickness();
    rotate_y(180){
        translate_z(z_pos + (explode?15:0)){
            illumination_board();
        }
    }
}

// connector for the illumination power wires
module rendered_illumination_connector(explode=false, straight_cable=false){
    offset = illumination_board_connector_offset();
    z_pos = diffuser_thickness() + condenser_board_spacer_thickness() + illumination_pcb_thickness() + offset.z;
    rotate_y(180){
        translate_z(z_pos){
            translate_y(offset.y + (explode ? 15 : 0)){
                rotate_x(-90){
                    dupont_connector_housing(2, center=true);
                    if(straight_cable){
                        illumination_wires();
                    }
                }
            }
        }
    }
}

// Straight red and black wires, up along the Z axis
module illumination_wires(){
    coloured_render("DimGray"){
        wire(d=1, points=[[2.54/2,0,8], [1/2,0,15], [1/2,0,99]]);
    }
    coloured_render("red"){
        wire(d=1, points=[[-2.54/2,0,8], [-1/2,0,15], [-1/2,0,99]]);
    }
}

// PCB mounting screws
module rendered_illumination_pcb_screws(explode=false){
    z_pos = diffuser_thickness() + condenser_board_spacer_thickness() + illumination_pcb_thickness();
    rotate_y(180){
        reflect_x(){
            translate_x(illumination_mounting_hole_sep()/2){
                translate_z(z_pos + (explode?20:0)){
                    no2_x6_5_selftap();
                }
                if (explode){
                    construction_line([0, 0, z_pos], [0, 0, 20 + z_pos]);
                }
            }
        }
    }
}

// Lid of the condenser
module rendered_condenser_lid(explode=false){
    coloured_render(extras_colour()){
        // NB both the lid and the condenser render upside down, so
        // we must move the lid down so that it matches up with
        // the condenser.
        translate_z(-condenser_lid_h() - (explode ? 15 : 0)){
            if (USE_BUILT_STL){
                cached_stl("condenser_lid");
            }else{
                condenser_lid();
            }
        }
    }
}

module rendered_led_holder(explode=false){
    coloured_render(extras_colour()){
        translate_z(-condenser_lid_h() + 5 + (explode ? 20 : 0)){
            if (USE_BUILT_STL){
                cached_stl("condenser_led_holder");
            }else{
                condenser_led_holder();
            }
        }
    }
}

module rendered_led(explode=false){
    translate_z(-condenser_lid_h() + 5 + (explode ? 20 : 0)){
        translate_z(-0.5){
            led();
        }
        reflect_x(){
            translate([2.54/2, 0, -0.75]){
                rotate_x(-90){
                    coloured_render("DimGray"){
                        cylinder(d=1.5, h=20);
                    }
                }
            }
        }
        translate([0, 12, -0.75]){
            rotate_x(-90){
                illumination_wires();
            }
        }
    }
}

// Screws attaching the LED holder to the lid
module rendered_led_screws(explode=false){
    z_pos = -condenser_lid_h() + 7;
    exploded_z_pos = z_pos + 25;
    base_r = condenser_base_r(condenser_lens_diameter());
    reflect_x(){
        translate_x(illumination_mounting_hole_sep()/2){
            translate_z((explode?exploded_z_pos:z_pos)){
                no2_x6_5_selftap();
            }
            if (explode){
                construction_line([0, 0, z_pos], [0, 0, exploded_z_pos]);
            }
        }
    }
}

// Screws attaching the lid to the condenser
module rendered_condenser_lid_screws(explode=false){
    z_pos = 2;
    exploded_z_pos = 25;
    base_r = condenser_base_r(condenser_lens_diameter());
    rotate_y(180){
        reflect_x(){
            translate(condenser_lid_mounting_hole_pos(base_r)){
                translate_z((explode?exploded_z_pos:z_pos)){
                    no2_x6_5_selftap();
                }
                if (explode){
                    construction_line([0, 0, z_pos], [0, 0, exploded_z_pos]);
                }
            }
        }
    }
}

module rendered_condenser(pos, cut=false){
    if (cut){
        cutaway("+x", extras_colour()){
            place_part(pos){
                condenser();
            }
        }
    }else{
        coloured_render(extras_colour()){
            place_part(pos){
                if (USE_BUILT_STL){
                    cached_stl("condenser");
                }else{
                    condenser();
                }
            }
        }
    }
}

// This module renders the condenser (excluding cable), including
// the thumbscrew, lid, lens, and internals.  By default, the LED
// board and other internal components are not rendered, as they
// are not visible.
//
// `pos` should be a placement dictionary, which defaults to the
// in-place position of the condenser. 
// `cut` will produce a cut-through of the condenser (you may wish
// to enable the internal components for this).
// `explode` is set to a string (see the definition for valid ones)
// and will cause the relevant part to appear "exploded".
module rendered_condenser_assembly(pos=undef,
                                   include_led=false,
                                   include_thumbscrew=true,
                                   include_nut=true,
                                   include_led_board=false,
                                   include_led_board_screws=false,
                                   include_lid=true,
                                   include_lid_screws=undef,
                                   cut=false,
                                   explode=undef,
                                   tighten_arrow=false){
    cond_pos = is_undef(pos) ? condenser_pos() : pos;
    rendered_condenser(cond_pos, cut=cut);
    place_part(cond_pos){
        place_part(condenser_lens_pos_relative()){
            condenser_lens();
        }
        if (include_led){
            led();
        }
        if (include_led_board){
            rendered_diffuser(explode=(explode=="led_board"));
            rendered_spacer(explode=(explode=="led_board"));
            rendered_illumination_pcb(explode=(explode=="led_board"));
        }
        if (include_led_board_screws){
            rendered_illumination_pcb_screws(explode=(explode=="led_board_screws"));
        }
        if (include_nut){
            exploded = explode == "nut";
            nut_pos = condenser_clamp_axis_pos(4.4);
            explode_nut_translation = 20*[cos(30)*sin(30), cos(30)*cos(30), -sin(30)];
            nut_pos_exp = translate_pos(condenser_clamp_axis_pos(4.4),
                                        explode_nut_translation);
            if (exploded){
                construction_line(nut_pos, nut_pos_exp);
            }                            
            place_part(exploded ? nut_pos_exp : nut_pos){
                condenser_nut();
            }
        }
        if (include_thumbscrew){
            exploded = explode == "thumbscrew";
            screw_pos = exploded ? 40 : 1;
            thumbscrew_pos = exploded ? 20 : 14.4;
            if (exploded){
                construction_line(condenser_clamp_axis_pos(4),
                                  condenser_clamp_axis_pos(50));
            }
            if (tighten_arrow){
                place_part(condenser_clamp_axis_pos(29)){
                    rotate_x(90){
                        turn_clockwise(8, 5, .15);
                    }
                }
            }

            place_part(condenser_clamp_axis_pos(screw_pos)){
                condenser_m3x25();
            }
            place_part(condenser_clamp_axis_pos(thumbscrew_pos)){
                rendered_illumination_thumbscrew();
            }
        }
        if (include_lid){
            rendered_condenser_lid(explode=(explode=="lid"));
            if (is_undef(include_lid_screws) || include_lid_screws){
                rendered_condenser_lid_screws(explode=(explode=="lid_screws"));
            }
        }else if (include_lid_screws){
            echo("WARNING: condenser lid screws are only included if the lid is also included.");
        }
    }
}

module rendered_illumination_thumbscrew(){
    coloured_render(extras_colour()){
        rotate_x(90){
            illumination_thumbscrew();
        }
    }
}

module condenser_m3x25(){
    rotate_x(90){
        translate_z(25){
            m3_hex_x25();
        }
    }
}

module condenser_nut(){
    rotate_x(90){
        rotate_z(30){
            m3_nut();
        }
    }
}
