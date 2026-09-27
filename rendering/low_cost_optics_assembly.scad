use <../openscad/libs/utilities.scad>
use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/z_axis.scad>
use <../openscad/lens_tool.scad>
use <../openscad/libs/lib_optics.scad>
use <../openscad/libs/optics_configurations.scad>
use <../openscad/libs/cameras/logitech_c270.scad>

use <librender/assembly_parameters.scad>
use <librender/render_utils.scad>
use <librender/render_settings.scad>
use <librender/optics.scad>
use <librender/electronics.scad>
use <librender/hardware.scad>
use <librender/rendered_components.scad>

FRAME = 11;
// CAMERA_TYPE is either "c270" or "pi_camera"
CAMERA_TYPE = "pi_camera"; 

render_low_cost_assembly(FRAME, CAMERA_TYPE);

module render_low_cost_assembly(frame, camera_type){
    if (frame <= 3){
        assemble_lens_spacer(frame, camera_type);
    }
    else if (frame == 4){
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=false,
                                 screw=false,
                                 ribbon_cable=false,
                                 opt_axis_line=true,
                                 connector_open=true,
                                 explode="camera",
                                 camera_type=camera_type);
    }
    else if (frame == 5){
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=false,
                                 screw=false,
                                 ribbon_cable=false,
                                 connector_open=true,
                                 camera_type=camera_type);
    }
    else if (frame == 6){
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=true,
                                 screw=false,
                                 ribbon_cable=false,
                                 connector_open=true,
                                 explode="nut",
                                 camera_type=camera_type);
        if (camera_type == "c270"){
            rendered_backshell();
        }
    }
    else if (frame == 7){
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=true,
                                 screw=true,
                                 ribbon_cable=false,
                                 connector_open=true,
                                 explode="screw",
                                 camera_type=camera_type);
        if (camera_type == "c270"){
            rendered_backshell();
        }
    }
    else if (frame == 8){
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=true,
                                 screw=true,
                                 ribbon_cable=false,
                                 screw_tight=false,
                                 connector_open=true,
                                 camera_type=camera_type);
        if (camera_type == "c270"){
            rendered_backshell();
        }
    }
    else if (frame == 9){
        assert(camera_type=="pi_camera","Camera cable insert only for pi Camera")
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=true,
                                 screw=true,
                                 ribbon_cable=true,
                                 screw_tight=false,
                                 connector_open=true,
                                 explode="ribbon_cable",
                                 camera_type=camera_type);
    }
    else if (frame == 10){
        assert(camera_type=="pi_camera","Camera cable insert only for pi Camera")
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=true,
                                 screw=true,
                                 ribbon_cable=true,
                                 screw_tight=false,
                                 connector_open=true,
                                 camera_type=camera_type);
    }
    else if (frame == 11){
        assert(camera_type=="pi_camera","Camera cable insert only for pi Camera")
        rendered_low_cost_optics(optics_module_pos(),
                                 cut=false,
                                 lens=true,
                                 camera=true,
                                 nut=true,
                                 screw=true,
                                 ribbon_cable=true,
                                 screw_tight=false,
                                 connector_open=false,
                                 camera_type=camera_type);
    }
    else if (frame == 12){
        assert(camera_type=="c270","C270 back screw only for C270 Camera")
        render_mount_c270_back_shell(optics_module_pos(), explode=true, platform=false);
    }
    else if (frame == 13){
        assert(camera_type=="c270","C270 back screw only for C270 Camera")
        render_mount_c270_back_shell(optics_module_pos(), explode=false, platform=false);
    }
    else if (frame == 14){
        assert(camera_type=="c270","C270 back screw only for C270 Camera")
        render_mount_c270_back_shell(optics_module_pos(), explode=false, platform=true, backshell_out=true);
    }
    else if (frame == 15){
        assert(camera_type=="c270","C270 back screw only for C270 Camera")
        render_mount_c270_back_shell(optics_module_pos(), explode=false, platform=true, backshell_out=false, screw_out=true);
    }
    else if (frame == 16){
        assert(camera_type=="c270","C270 back screw only for C270 Camera")
        render_mount_c270_back_shell(optics_module_pos());
    }
}


module rendered_backshell(){
    params = render_params();
    optics_config = c270lens_config();
    coloured_render(optics_module_colour()){
        translate_z(lens_spacer_z(params, optics_config)){
            rotate_x(180){
                c270_backshell();
            }
        }
    }
}

module assemble_lens_spacer(frame, camera_type="pi_camera"){
    params = render_params();
    optics_config = (camera_type == "c270") ? c270lens_config() : pilens_config();
    pos = (frame == 1) ?
        lens_spacer_pos_above_tool(params, optics_config):
        lens_spacer_pos_on_tool(params, optics_config);
    cut = (frame == 3)? true : false;
    rotate_in_view = (camera_type == "c270")? 135 : 0;
    rotate_z(rotate_in_view){
        rendered_low_cost_optics(pos,
                                cut=cut,
                                lens=false,
                                camera=false,
                                nut=false,
                                screw=false,
                                ribbon_cable=false,
                                camera_type=camera_type);
    }
    if (camera_type == "pi_camera"){
        picamera2_lens();
    }
    else if (camera_type == "c270"){
        c270_lens();
    }
}

module rendered_camera_platform(camera_type="pi_camera"){
    params = render_params();
    optics_config = (camera_type == "c270") ? c270lens_config() : pilens_config();
    coloured_render(optics_module_colour()){
        camera_platform(params, optics_config, 5);
    }
}

module camera_platform_and_screws(lens_spacer_z, explode=false, connector_open=false, camera_type="pi_camera"){
    ex_dist = 13;
    screw_z = - 1 - (explode ? 2*ex_dist : 0);
    holes = (camera_type == "c270") ? c270_holes() : picamera2_holes();
    camera_rot = (camera_type == "c270") ? 0 : 135 ;
    camera_pos = create_placement_dict([0, 0, lens_spacer_z], [0, 0, camera_rot]);
    camera_pos_ex = translate_pos(camera_pos, [0, 0, -ex_dist]);

    render_pos = explode ? camera_pos_ex : camera_pos;
    cover_pos = explode ? picamera_cover_pos(ex_dist=ex_dist) : picamera_cover_pos();
    platform_z_pos = !explode ? 0 :
        (camera_type == "c270") ? - ex_dist : - 2*ex_dist;
    translate_z(platform_z_pos){
        rendered_camera_platform(camera_type=camera_type);
    }
    place_part(render_pos){
        if (camera_type == "pi_camera"){
            picamera2(lens=false, connector_open=connector_open);
        }
        else if (camera_type == "c270"){
            raise_cam = explode ? ex_dist : 0;
            translate_z(raise_cam){
                c270_board();
            }
        }
        for (hole_pos = holes){
            translate(hole_pos - [0, 0, screw_z]){
                if (camera_type == "pi_camera"){
                    no2_x6_5_selftap();
                }
                else if (camera_type == "c270"){
                    no1_x5_0_selftap();
                }
                if (explode){
                    construction_line([0, 0, 0], [0, 0, 2*screw_z]);
                }
            }
        }
    }
}

module rendered_low_cost_optics(pos,
                                cut=false,
                                lens=true,
                                camera=true,
                                nut=true,
                                screw=true,
                                ribbon_cable=true,
                                opt_axis_line=false,
                                explode=undef,
                                screw_tight=true,
                                connector_open=false,
                                cable_positions=undef,
                                camera_type="pi_camera"){
    
    cut_camera = (camera_type == "c270")? "+xy" : "+x";
    cut_dir = cut ? cut_camera : "none";
    params = render_params();
    optics_config = (camera_type == "c270") ? c270lens_config() : pilens_config();
    ribbon_pos = is_undef(cable_positions) ?
        default_ribbon_pos(low_cost=true, params=params, optics_config=optics_config):
        cable_positions;

    place_part(pos){
        cutaway(cut_dir, optics_module_colour()){
            lens_spacer(params, optics_config);
        }
        if (nut){
            exploded = (explode == "nut") ? true : false;
            nut_pos_ex = translate_pos(camera_platform_nut_pos(), [0, 5, 20]);
            nut_pos = exploded ? nut_pos_ex : camera_platform_nut_pos();
            place_part(nut_pos){
                m3_nut();
            }
            if (exploded){
                translate([0, -1, -2]){
                    construction_line(nut_pos_ex,
                                      translate_pos(camera_platform_nut_pos(), [0,0,5]));
                }
            }
        }
        if (screw){
            exploded = (explode == "screw") ? true : false;
            screw_pos_ex = translate_pos(camera_platform_screw_pos(), [0, 12, 0]);
            screw_pos_assembled = translate_pos(camera_platform_screw_pos(), [0, 4, 0]);
            screw_pos = exploded ? screw_pos_ex :
                screw_tight ? camera_platform_screw_pos() : screw_pos_assembled;
            place_part(screw_pos){
                m3_cap_x10();
            }
            if (exploded){
                translate_y(-8){
                    construction_line(screw_pos_ex, screw_pos_assembled);
                }
            }
        }
        lens_spacer_z = lens_spacer_z(params, optics_config);
        if (camera){
            exploded = (explode == "camera") ? true : false;
            camera_platform_and_screws(lens_spacer_z, exploded, connector_open=connector_open, camera_type=camera_type);
        }
        if (ribbon_cable){
            ribbon_start = create_placement_dict([0, 0, lens_spacer_z-1.25], [0, 0, 135], [0, 180, 0], init_translation=[15, 0, 0]);
            positions = concat([ribbon_start], ribbon_pos);
            exploded = (explode == "ribbon_cable") ? true : false;
            ribbon_tr = exploded ? [15, -15, 0] : [0, 0, 0];
            translate(ribbon_tr){
                picamera_cable(positions);
            }
            if (exploded){
                construction_line(translate_pos(ribbon_start, -ribbon_tr),
                                  translate_pos(ribbon_start, ribbon_tr));
            }
        }
        // lens last as transparent!
        if (lens){
            translate_z(pi_lens_z_pos(params, optics_config)){
                mirror([0, 0, 1]){
                    if (camera_type == "pi_camera"){
                        picamera2_lens();
                    }
                    else if (camera_type == "c270"){
                        c270_lens();
                    }
                }
            }
        }
        if (opt_axis_line){
            construction_line_dashed([0,0,20],[0,0,85],width=0.2, line_color="white", dash_period=5.5);
            translate([0,0,21]){
                circle_label(rad=4, line_w=0.2, line_color="red");
            }
        }
    }
}

module render_mount_c270_back_shell(pos, explode=false, platform=true, backshell_out=false, screw_out=false){
    params = render_params();
    optics_config = c270lens_config();
    lens_spacer_z = lens_spacer_z(params, optics_config);
    ex_dist = 13;
    camera_pos = explode ? lens_spacer_z - ex_dist  : lens_spacer_z ;

    holes = c270_holes();
    screw_z = 1 + (explode ? ex_dist : 0);

    place_part(pos){
        coloured_render(optics_module_colour()){
            lens_spacer(params, optics_config);
        }
        // lens last as transparent!
        translate_z(pi_lens_z_pos(params, optics_config)){
            mirror([0, 0, 1]){
                c270_lens();
            }
        }
    }
    translate_z(camera_pos){
        c270_board();
        for (hole_pos = holes){
            translate(hole_pos - [0, 0, screw_z]){
                if (explode){
                    construction_line([0, 0, 0.8*screw_z], [0, 0, 2*screw_z], line_color="white");
                }
            }
        }
        rotate_z(180){
            translate(c270_far_third_hole_pos() - [0,0,screw_z]){
                mirror([0,0,1]){
                    no1_x5_0_selftap();
                }
                if (explode){
                    construction_line([0, 0, 0], [0, 0, 2*screw_z]);
                }
            }
        }
    }

    if (platform){
        rendered_camera_platform(camera_type="c270");
        backshell_pos = backshell_out ? -8 : 0;
        translate_y(backshell_pos){
            rendered_backshell();
        }
        if (!backshell_out){
            screw_ex = screw_out ? ex_dist : 0;
            pos = c270_backshell_screw_positions();
            backshell_screw_z = pos[1].z;
            for (p = pos){
                translate( [p.x, -p.y, 0] + [0,0,lens_spacer_z-backshell_screw_z-screw_ex]){
                    mirror([0,0,1]){
                        no2_x6_5_selftap();
                    }
                    if (screw_out){
                        construction_line([0, 0, 0], [0, 0, screw_ex]);
                    }
                } 
            }
        }
    }
}
