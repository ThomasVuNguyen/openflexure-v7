use <../../openscad/libs/microscope_parameters.scad>
use <../../openscad/libs/libdict.scad>
use <../../openscad/lens_tool.scad>
use <../../openscad/libs/z_axis.scad>
use <../../openscad/libs/illumination.scad>
use <../../openscad/libs/main_body_structure.scad>
use <../../openscad/libs/compact_nut_seat.scad>
use <../../openscad/libs/lib_microscope_stand.scad>
use <../../openscad/libs/lib_optics.scad>
use <../../openscad/libs/wall.scad>
use <../../openscad/libs/gears.scad>
use <../../openscad/libs/upright_z_axis.scad>
use <render_utils.scad>

function render_params() =  let(
    params = default_params()
) replace_value("print_ties", false, params);

PARAMS = render_params();

function z_actuator_rot() = [z_actuator_tilt(PARAMS), 0, 0];

function tr_along_z_act(dist) = let(
    ang = z_actuator_tilt(PARAMS)
) [0, -dist*sin(ang), dist*cos(ang)];


function stage_nut_placement(params) =  let(
    leg_r = key_lookup("leg_r", params),
    pos = [0, leg_r-stage_hole_inset(), leg_height(params)+4.5],
    rot = [0, 0, 30]
) create_placement_dict(pos, rot);

function stage_nut_placement_low(params) = translate_pos(stage_nut_placement(params), [0,0,-2.5]);
function stage_nut_placement_exp(params) = translate_pos(stage_nut_placement(params), [0,30,-2.5]);

function stage_nut_temp_screw_pos(params) = translate_pos(stage_nut_placement(params), [0,0,5]);
function stage_nut_temp_screw_pos_exp(params) = translate_pos(stage_nut_placement(params), [0,0,25]);

function illum_platform_nut_placement(params, right=true) = let(
    r_pos = right_illumination_screw_pos(params) - [0,0,4.75],
    r_rot = right_illumination_screw_rotation()+30,
    l_pos = left_illumination_screw_pos(params) - [0,0,4.75],
    l_rot = left_illumination_screw_rotation()+30,
    pos = right ? r_pos : l_pos,
    rot = right ? r_rot : l_rot
) create_placement_dict(pos, rot);
function illum_platform_back_nut_placement(params) = let(
    pos = illumination_back_corner_pos(params) - [0,0,4.75],
    rot = 0
) create_placement_dict(pos, rot);

function illum_platform_nut_placement_low(params, right=true) = translate_pos(illum_platform_nut_placement(params, right), [0,0,-2.5]);
function illum_platform_nut_placement_exp(params, right=true) = let(
    angle = right ? right_illumination_screw_rotation() : left_illumination_screw_rotation(),
    vector = [-20*sin(angle), 20*cos(angle), -2.5]
) translate_pos(illum_platform_nut_placement(params, right), vector);

function illum_platform_nut_temp_screw_pos(params, right=true) = translate_pos(illum_platform_nut_placement(params, right), [0,0,5]);
function illum_platform_nut_temp_screw_pos_exp(params, right=true) = translate_pos(illum_platform_nut_placement(params, right), [0,0,25]);


function stand_nut_placement(params, stand_params, nut_num) =  let(
    xy_pos = base_mounting_holes(params)[nut_num],
    z_pos = microscope_stand_lug_z(stand_params) + microscope_stand_lug_height()-4.5,
    pos = xy_pos + [0,0,1]*z_pos,
    rot = [0, 0, 30 + lug_angles(params)[nut_num]]
) create_placement_dict(pos, rot);

function stand_nut_placement_low(params, stand_params, nut_num) = translate_pos(stand_nut_placement(params, stand_params, nut_num), [0,0,-2.5]);
function stand_nut_placement_exp(params, stand_params, nut_num) = let(
    angle = lug_angles(params)[nut_num],
    explode_distance = [30*sin(angle), -30*cos(angle), -2.5]
)translate_pos(stand_nut_placement(params, stand_params, nut_num), explode_distance);

function stand_nut_temp_screw_pos(params, stand_params, nut_num) = translate_pos(stand_nut_placement(params, stand_params, nut_num), [0,0,4.5]);
function stand_nut_temp_screw_pos_exp(params, stand_params, nut_num) = translate_pos(stand_nut_placement(params, stand_params, nut_num), [0,0,25]);

//convenience function as the actuator height is used a lot
function actuator_height() = key_lookup("actuator_h", PARAMS);

function xy_nut_height() = actuator_height()-4;

function x_nut_placement() =  let(
    pos = x_actuator_pos(PARAMS) + [0, 0, xy_nut_height()],
    rot = [0, 0, 45]
) create_placement_dict(pos, rot);

function x_nut_placement_exp() =  let(
    pos = [70, 70, actuator_height()-10],
    rot = [0, 0, 45]
) create_placement_dict(pos, rot);

function y_nut_placement() =  let(
    pos = y_actuator_pos(PARAMS) + [0, 0, xy_nut_height()],
    rot = [0, 0, -45]
) create_placement_dict(pos, rot);

function z_nut_placement() =  let(
    pos = z_actuator_pos(PARAMS) + tr_along_z_act(actuator_height()-4),
    rot1 = [0, 0, 30],
    rot2 = z_actuator_rot()
) create_placement_dict(pos, rot2, rot1);

function xy_lead_assembly_height() = actuator_height()+7;

function x_lead_assembly_pos() = x_actuator_pos(PARAMS) + [0, 0, xy_lead_assembly_height()];
function y_lead_assembly_pos() = y_actuator_pos(PARAMS) + [0, 0, xy_lead_assembly_height()];
function z_lead_assembly_pos() = z_actuator_pos(PARAMS) + tr_along_z_act(actuator_height()+5);

// 'rotation1' is used to place the 'index tooth' of the large gear in the  
// direction of the small gear, to make this work for all numbers of teeth.
function x_lead_assembly_placement() = create_placement_dict(x_lead_assembly_pos(), rotation1=[0, 0, +45]);
function x_lead_assembly_placement_exp() = create_placement_dict(x_lead_assembly_pos() + [0, 0, 40], rotation1=[0, 0, +45]);
function y_lead_assembly_placement() = create_placement_dict(y_lead_assembly_pos(), rotation1=[0, 0, 135]);
function z_lead_assembly_placement() = create_placement_dict(z_lead_assembly_pos(), rotation3=z_actuator_rot(), rotation1=[0, 0, -90]);

function x_lead_oil_placement() = create_placement_dict(x_lead_assembly_pos()+[2,2,2],
                                                        [0, 0, 20],
                                                        [0, -100, 0]);

function x_foot_placement() = create_placement_dict(x_actuator_pos(PARAMS), [0, 0, -45]);
function y_foot_placement() = create_placement_dict(y_actuator_pos(PARAMS), [0, 0, 45]);
function z_foot_placement() = create_placement_dict(z_actuator_pos(PARAMS));

function z_foot_cap_placement() = let(
    actuator_housing_depth = 10,
    foot_height = key_lookup("foot_height", PARAMS) - actuator_housing_depth*sin(-z_actuator_tilt(PARAMS))
) create_placement_dict(z_actuator_pos(PARAMS), rotation1 = z_actuator_rot(), init_translation=[0,0,-foot_height]);

function z_oring_placement() = create_placement_dict(z_actuator_pos(PARAMS)+[0, .5, 1.5],
                                                     z_actuator_rot());

function optics_module_pos(low_cost=false) = let(
    z = low_cost ? -1+camera_platform_extra_lift() : 0
) create_placement_dict([0, 0, z]);
function optics_module_pos_above_tool() = create_placement_dict([0, 0, 75] ,[0, 180, 0], [0, 0, 180]);
function optics_module_pos_on_tool() = create_placement_dict([0, 0, 42] ,[0, 180, 0], [0, 0, 180]);

function tube_lens_tool_pos() = create_placement_dict([0, 0, lens_tool_height()+3.6], [0, 180, 0]);
function optics_module_mount_pos() = objective_mount_screw_pos(PARAMS);

function picamera_cover_pos(ex_dist=0) =  let(
    tr = [0, 0, -4-ex_dist],
    rotation = [0, 0, -90]
) create_placement_dict(tr, rotation);

function default_ribbon_pos(low_cost=false, params=undef, optics_config=undef) = let(
    z_start = low_cost ? lens_spacer_z(params, optics_config) + 17.5 : 0
) [create_placement_dict([17, -17, -18.75+z_start], [0, 0, 135], [0, 180, 0]),
   create_placement_dict([21, -21, -17+z_start], [0, 0, 135], [0, 180, 0]),
   create_placement_dict([22, -22, -15+z_start], [0, 0, 135], [0, 180, 0]),
   create_placement_dict([50, -50, 100+z_start], [0, 0, 135], [0, 180, 0])];

function curled_ribbon_pos(low_cost=false, params=undef, optics_config=undef) = let(
    z_start = low_cost ? lens_spacer_z(params, optics_config) + 17.5 : 0 ,
    pos1 = [create_placement_dict([12, -12, -18.75+z_start], [0, 0, 135], [0, 180, 0]),
            create_placement_dict([13.5, -13.5, -20+z_start], [0, 0, 135], [0, 180, 0]),
            create_placement_dict([14.5, -14.5, -22+z_start], [0, 0, 135], [0, 180, 0])] ,
    pos2 = [create_placement_dict([14, -14, -26+z_start], [0, 0, 135], [0, 180, 0]),
            create_placement_dict([9, -9, -36+z_start], [0, 0, 135], [0, 180, 0]),
            create_placement_dict([8, -8, -40+z_start], [0, 0, 135], [0, 180, 0]),
            create_placement_dict([8, -8, -60+z_start], [0, 0, 135], [0, 180, 0]),
            create_placement_dict([10, -10, -20], [0, 0, 135], [0, 180, 0])],
    pos3 = [create_placement_dict([12, -12, -50], [0, 0, 135]),
            create_placement_dict([11, -11, -52], [0, 0, 135]),
            create_placement_dict([-10, 10, -53], [0, 0, 135])]
) low_cost ? concat(pos1, pos2, pos3) : concat(pos1, pos3);

function optics_module_nut_pos() = create_placement_dict(optics_module_mount_pos() - [0, 3.25, 1], [90, 0, 0], [0, 0, 30]);
function optics_module_screw_pos() = create_placement_dict(optics_module_mount_pos() - [0, 0, 1], [-90, 0, 0], [0, 0, 30]);

function optics_module_allen_key_pos() = let(
    key_angle = objective_mounting_screw_access_angle() + [90, 0, 0],
    key_pos = optics_module_mount_pos() + [0, 2, -1]
) create_placement_dict(key_pos, key_angle);

function optics_module_insertion_allen_key_pos() = let(
    key_angle = objective_mounting_screw_access_angle() + [90, 0, 0],
    key_pos = optics_module_mount_pos() + [0, 2, -1]
) create_placement_dict(key_pos, [6, key_angle.y, key_angle.z]);

function pi_lens_z_pos(params, optics_config) = let(
    lens_spacer_z = lens_spacer_z(params, optics_config),
    lens_spacing = key_lookup("lens_spacing", optics_config)
) lens_spacer_z + lens_spacing + 5;
function lens_spacer_pos() = create_placement_dict([0, 0, 0]);
function lens_spacer_pos_above_tool(params, optics_config) = let(
    z_tr = pi_lens_z_pos(params, optics_config)+30
) create_placement_dict([0, 0, z_tr], [0, 180, 0], [0, 0, 180]);
function lens_spacer_pos_on_tool(params, optics_config) = let(
    z_tr = pi_lens_z_pos(params, optics_config)
) create_placement_dict([0, 0, z_tr], [0, 180, 0], [0, 0, 180]);

function camera_platform_nut_pos() = create_placement_dict(optics_module_mount_pos() - [0, 3.25, camera_platform_extra_lift()], [90, 0, 0], [0, 0, 30]);
function camera_platform_screw_pos() = create_placement_dict(optics_module_mount_pos() - [0, 0, camera_platform_extra_lift()], [-90, 0, 0], [0, 0, 30]);
function camera_platform_allen_key_pos() = create_placement_dict(optics_module_mount_pos() + [0, 2, 3-camera_platform_extra_lift()], [0, 0, 25]);


function condenser_z() = let(
    condenser_touching_stage = 42,
    condenser_focus_gap = 5
) illumination_dovetail_z(PARAMS) + condenser_touching_stage + condenser_focus_gap ;

function condenser_pos() = create_placement_dict([0, 0, condenser_z()],
                                                 [0, 0, 180],
                                                 [180, 0, 0]);

function condenser_pos_exp() = translate_pos(condenser_pos(), [0, 0, 30]);

function condenser_pos_above_tool() = create_placement_dict([0, 0, 90],
                                                            [0, 0, -90],
                                                            [180, 0, 0]);
function condenser_pos_on_tool() = create_placement_dict([0, 0, lens_tool_height()+0.01+condenser_lens_z()+condenser_lens_thickness()],
                                                         [0, 0, -90],
                                                         [180, 0, 0]);
function condenser_pos_above_tool() = translate_pos(condenser_pos_on_tool(), [0, 0, 20]);

function condenser_lens_tool_pos() = create_placement_dict([0, 0, lens_tool_height()+0.01]);
function condenser_lens_pos_relative() = create_placement_dict([0, 0, condenser_lens_z()], [180, 0, 0]);

function condenser_clamp_axis_pos(depth) = let(
    tr = [0, 37.9, 8],
    r1 = [0,0,60],
    init_tr = [0, -depth, 0]
) create_placement_dict(tr, r1, init_translation=init_tr);

function microscope_on_stand_pos(stand_params, exploded=false) = let(
    exp_height = exploded ? 10 : 0,
    z_position = microscope_stand_lug_z(stand_params) + microscope_stand_lug_height()
) create_placement_dict([0, 0, z_position+exp_height]);

function stand_lug_pos(params, stand_params, screw_num) = translate_pos(stand_nut_placement(params, stand_params, screw_num), [0, 0, 8]);
function stand_lug_pos_exp(params, stand_params, screw_num) = translate_pos(stand_nut_placement(params, stand_params, screw_num), [0, 0, 35]);

function illum_dovetail_screw_pos(params, right=true) = translate_pos(illum_platform_nut_placement(params, right), [0, 0, 8.1]);
function illum_dovetail_screw_pos_exp(params, right=true) = translate_pos(illum_dovetail_screw_pos(params, right), [0,0,32]);
function illum_dovetail_screw_pos_exp_short(params, right=true) = translate_pos(illum_dovetail_screw_pos(params, right), [0,0,10.5]);

function illum_dovetail_back_screw_pos(params) = translate_pos(illum_platform_back_nut_placement(params), [0, 0, 8.1]);
function illum_dovetail_back_screw_pos_exp(params) = translate_pos(illum_dovetail_back_screw_pos(params), [0, 0, upright_z_spacer_height(params,1)+30]);

function illum_dovetail_washer_pos(params, right=true) = translate_pos(illum_platform_nut_placement(params, right), [0, 0, 7.7]);
function illum_dovetail_washer_pos_exp(params, right=true) = translate_pos(illum_dovetail_washer_pos(params, right), [0, 0, 17]);
function illum_dovetail_washer_pos_exp_short(params, right=true) = translate_pos(illum_dovetail_washer_pos(params, right), [0, 0, 10.5]);

function illum_dovetail_back_washer_pos(params) = translate_pos(illum_platform_back_nut_placement(params), [0, 0, 7.7]);
function illum_dovetail_back_washer_pos_exp(params) = translate_pos(illum_dovetail_back_washer_pos(params), [0, 0, upright_z_spacer_height(params,1)+17]);

function z_mount_screw_pos(params, right=true, front=true) = let(
    lift = upright_z_spacer_height(params,1),
    pos_f = translate_pos(illum_dovetail_screw_pos(params, right), [0, 0, lift]),
    diff = right_back_sq_illum_corner_pos(params) - right_illumination_screw_pos(params),
    pos = front ? pos_f : translate_pos(pos_f, diff)
) pos;
function z_mount_screw_pos_exp(params, right=true, front=true) = let(
    up = front ? 14 : 40
) translate_pos(z_mount_screw_pos(params, right, front), [0,0,up]);
function z_mount_temp_screw_pos_exp(params, right=true, front=true) = let(
    up = 14
) translate_pos(z_mount_screw_pos(params, right, front), [0,0,up]);


function z_mount_washer_pos(params, right=true, front=true) = let(
    lift = upright_z_spacer_height(params,1),
    pos_f = translate_pos(illum_dovetail_washer_pos(params, right), [0, 0, lift]),
    diff = right_back_sq_illum_corner_pos(params) - right_illumination_screw_pos(params),
    pos = front ? pos_f : translate_pos(pos_f, diff)
) pos;
function z_mount_washer_pos_exp(params, right=true, front=true) = let(
    up = front ? 14 : 27
) translate_pos(z_mount_screw_pos(params, right, front), [0,0,up]);

function z_mount_nut_placement(params, right=true) = let(
    r_pos = right_illumination_screw_pos(params) - [0,0,4.75],
    r_rot = +30,
    l_pos = left_illumination_screw_pos(params) - [0,0,4.75],
    l_rot = +30,
    pos = right ? r_pos : l_pos,
    rot = right ? r_rot : l_rot
) create_placement_dict(pos, rot);
function z_mount_nut_pos(params, right=true, front=true) = let(
    lift = upright_z_spacer_height(params,1)-1,
    pos_f = translate_pos(z_mount_nut_placement(params, right), [0, 0, lift]),
    diff = right_back_sq_illum_corner_pos(params) - right_illumination_screw_pos(params),
    pos = front ? pos_f : translate_pos(pos_f, diff)
) pos;
function z_mount_nut_pos_exp(params, right=true, front=true) = let(
    low = -2,
    outy = front ? 12 : -10,
    outx = front ? 0 : (right ? 10 : -10)
) translate_pos(z_mount_nut_pos(params, right, front), [outx,outy,low]);

function small_gear_pos() = let(
    // Place gap next to 'index tooth' of the small gear in the  
    // direction of the large gear, to make this work for all numbers of teeth.
    tooth_angle = 360 / (2*n_teeth_small_gear())
)create_placement_dict([0, 0, -2], [180, 0, 0], [0, 0, tooth_angle], [0, 0, -90]);
function small_gear_pos_exp() = translate_pos(small_gear_pos(), [0, 0, -20]);

function small_gear_screw_pos() = create_placement_dict(small_gear_screw_hole());
function small_gear_screw_pos_exp() = translate_pos(small_gear_screw_pos(), [0, 0, 20]);

function motor_screw_pos() = [0.5*motor_screw_separation(), 12, 2.5];

function y_motor_pos(params) = create_placement_dict([0, 20, y_motor_z_pos(params)], [0, 0, 180]);
function y_connector_pos(params) = create_placement_dict([-22, -13, -43], [0, 0, y_wall_angle(params)-45]);
function y_cable_verticies(out) = let(
    final_z = out ? -35 : -5
 ) [[0, -10, 45], [-22, -13, 45], [-22, -13, final_z]];

function z_motor_pos() = create_placement_dict([0, 20, 0], [0, 0, 180]);
function z_connector_pos() = create_placement_dict([-27, 3, -86], [0, 0, -15]);
function z_cable_verticies(out) = let(
    final_z = out ? -80 : -50
 ) [[0, -10, 3], [-27, 0, 3], [-27, 3, final_z]];

function x_connector_pos_board(params) = create_placement_dict([2, -17, -53], y_wall_angle(params)-45);
function y_connector_pos_board(params) = create_placement_dict([49.5, -71, -53], -y_wall_angle(params)+135);
function z_connector_pos_board(params) = create_placement_dict([-47, 7.5, -102.5], [z_actuator_tilt(params),0,0], [0, 0, -y_wall_angle(params)]);

function x_connector_pos_board_out(params, slide_dist) = let(
    a = -y_wall_angle(params)+45,
    tr = slide_dist*[-cos(a), sin(a),0]
) translate_pos(x_connector_pos_board(params), tr);

function y_connector_pos_board_out(params, slide_dist) = let(
    a = y_wall_angle(params)-135,
    tr = slide_dist*[-cos(a), sin(a),0]
) translate_pos(y_connector_pos_board(params), tr);

function z_connector_pos_board_out(params, slide_dist) = let(
    a = y_wall_angle(params),
    az = z_actuator_tilt(params),
    tr = slide_dist*[-cos(a), sin(a)*cos(az), -sin(az)],
    fiddle = [0, 0, -4.5]
) translate_pos(z_connector_pos_board(params), tr+fiddle);

// Note that this only is the correct translation for the sample clips
// if you first run `leg_frame(params, 45)`
function sample_clip_position(params, extra_z=0) = let(
    sample_z = key_lookup("sample_z", params)
)  create_placement_dict(translation=[0, -stage_hole_inset(), sample_z],
                         rotation1=[0, 0, 120],
                         init_translation = [0, 0, extra_z]);