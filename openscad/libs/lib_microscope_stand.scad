
use <./utilities.scad>
use <./microscope_parameters.scad>
use <./compact_nut_seat.scad>
use <./main_body_transforms.scad>
use <./main_body_structure.scad>
use <./wall.scad>
use <./z_axis.scad>
use <./libdict.scad>


function stand_wall_thickness() = 2.5;
function stand_base_thickness() = 2;
function stand_inner_offset_r() = 1.5;
function stand_outer_offset_r() = stand_inner_offset_r() + stand_wall_thickness();
function microscope_depth() = 3;
function microscope_stand_height(stand_params) = microscope_stand_vert_height(stand_params) + 31;
function microscope_stand_vert_height(stand_params) = let(
    inc_drawer = key_lookup("include_pi_tray_hole", stand_params),
    drawer_h = inc_drawer ? key_lookup("electronics_drawer_h", stand_params) : 8,
    extra_h = key_lookup("extra_height", stand_params)
) drawer_h + extra_h;

function default_stand_params(tall=false, no_pi=false, pi_version=4, sanga_version="stack_8.5mm") =
    assert(pi_version==3 || pi_version==4, "pi_version must be 3 or 4")
    assert(sanga_version=="v0.3" || sanga_version=="stack_8.5mm" || sanga_version=="stack_11mm", "sanga_version must be \"v0.3\", \"stack_8.5mm\" or \"stack_11mm\"")
    [["electronics_drawer_h", 47], //The height of the tray the pi sits in.
     ["include_pi_tray_hole", !no_pi], //Whether the stand has a hole for the raspberry pi tray
     ["extra_height", tall ? 17 : 0], //extra height above the raspberry pi_tray
     ["block_usb", true],
     ["sanga_version", sanga_version],
     ["pi_version", pi_version],
    ];

module foot_footprint(tilt=0){
    // the footprint of one foot/actuator column
    flatten(){
	screw_seat_shell(tilt=tilt);
    }
}

module hull_from(){
    // take the convex hull betwen one object and all subsequent objects
    for(i=[1:$children-1]){
        hull(){
            children(0);
            children(i);
        }
    }
}

module microscope_bottom(params, enlarge_legs=1.5, lugs=true, feet=true, legs=true){
    // a 2D representation of the bottom of the microscope
    hull(){
	flatten(){
	    wall_inside_xy_stage(params);
        }
    }

    hull(){
        reflect_x(){
	    flatten(){
		wall_outside_xy_actuators(params);
		wall_between_actuators(params);
            }
        }
    }

    flatten(){
	z_axis_casing(params);
	reflect_x(){
	    hull(){
		side_housing(params);
	    }
	}
    }

    if(feet){
        each_actuator(params){
            translate([0, actuating_nut_r(params)]){
                foot_footprint();
            }
        }
        translate([0, z_nut_y(params)]){
            foot_footprint(tilt=z_actuator_tilt(params));
        }
    }

    if(lugs){
	flatten(){
	    mounting_hole_lugs(params, holes=false);
        }
    }

    if(legs){
        offset(enlarge_legs){
            microscope_legs(params);
        }
    }
}

module microscope_legs(params){
    difference(){
        each_leg(params){
            union(){
		flatten(){
		    leg(params);
                }
                projection(cut=true){
                    translate([0,-5,-tiny()]){
                        leg(params);
                    }
                }
            }
        }
        translate([-999,0]){
            square(999*2);
        }
    }
}


module thick_bottom_section(params, h, offset_r, center=false){
    hull(){
        linear_extrude(h, center=center){
            offset(offset_r){
                microscope_bottom(params, feet=true);
            }
        }
    }
}

function microscope_stand_lug_height() = 20;
function microscope_stand_lug_z(stand_params) = microscope_stand_height(stand_params)-microscope_stand_lug_height()-microscope_depth();

module stand_lugs(params, stand_params){

    lug_body_h = 9;
    lug_h = microscope_stand_lug_height();
    lug_z = microscope_stand_lug_z(stand_params);

    hole_pos = base_mounting_holes(params);
    for (n = [0:len(hole_pos)-1]){
        hole = hole_pos[n];
        angle = lug_angles(params)[n];
        translate_z(lug_z){
            difference(){
                hull(){
                    intersection(){
                        translate(hole+[0,0,lug_h/2]){
                            rotate(angle){
                                cube([10,50,lug_h], center=true);
                            }
                        }
                        translate_z(-lug_z){
                            microscope_stand_shell(params, stand_params);
                        }
                    }

                    translate(hole + [0, 0, lug_h-lug_body_h]){
                        cylinder(r=5, h=lug_body_h);
                    }
                }
                extra_bore = 2.2; // maximum depth before breaking out from the lugs
                translate(hole+[0,0,lug_h-9]){
                    m3_nut_trap_with_shaft(slot_angle=(angle+180),tilt=0,deep_shaft=extra_bore,chamfer_offset=4);
                }
            }
        }
    }
}

module footprint(params){
    microscope_stand_base_section(params, stand_outer_offset_r());
}

module footprint_2d(){
    flatten(){
        footprint(default_params());
    }
}

//The outer shell of the microscope stand
module microscope_stand_shell(params, stand_params){
    h = microscope_stand_height(stand_params);
    vert_h = microscope_stand_vert_height(stand_params);

    assert(h-vert_h-10>15, "Stand is too short to print. Either increase height or reduce height of the electronics drawer");

    difference(){
        sequential_hull(){
            microscope_stand_base_section(params, stand_outer_offset_r());

            translate_z(vert_h+5){
                microscope_stand_base_section(params, stand_outer_offset_r());
            }
            translate_z(vert_h+10){
                thick_bottom_section(params, h-vert_h-10, stand_outer_offset_r());
            }
        }

        sequential_hull(){
            translate_z(stand_base_thickness()){
                microscope_stand_base_section(params, stand_inner_offset_r());
            }

            translate_z(vert_h+5){
                microscope_stand_base_section(params, stand_inner_offset_r());
            }
            translate_z(vert_h+10+tiny()){
                thick_bottom_section(params, h-vert_h-10, stand_inner_offset_r());
            }
        }
    }

}


module electronics_drawer_frame_xy(params, for_base_section=false, slide_dist=0){
    initial_pos = for_base_section ? [0,0,0] : [5,0,2];
    translate([34, -38, 0]){
        rotate(-y_wall_angle(params)){
            translate(initial_pos + slide_dist*[1, 0, 0]){
                children();
            }
        }
    }
}


module microscope_stand_base_section(params, ex_rad=3){
    pi_base_size = electronics_drawer_base_size();
    pi_block_size = [pi_base_size.x, electronics_drawer_front_width(), tiny()];
    extra_front_space = 2;
    extra_back_space = 6;
    extra_x_space = extra_front_space + extra_back_space;
    block_size = pi_block_size + [extra_x_space, 8, 0];
    minkowski(){
        hull(){
            reflect_x(){
                electronics_drawer_frame_xy(params, for_base_section=true){
                    translate_x(-extra_back_space){
                        cube(block_size);
                    }
                }
            }
        }
        cylinder(r=ex_rad, h=tiny());
    }
}

module base_microscope_stand(params, stand_params){
    stand_lugs(params, stand_params);
    difference(){
        microscope_stand_shell(params, stand_params);
        reflection_cutout_h = microscope_stand_height(stand_params) - microscope_depth();
        translate_z(reflection_cutout_h){
            extra_depth = key_lookup("extra_height", stand_params);
            reflection_illuminator_cutout(extra_depth);
        }
    }
}


// The microscope stand.
// The boolean parameter `supports` can be used to turn on or off
// the printing supports that support the long bridges over the
// cutouts for accessing the electronics drawer.
module microscope_stand(params, stand_params, supports=true){
    inc_drawer = key_lookup("include_pi_tray_hole", stand_params);
    if (inc_drawer){
        difference(){
            base_microscope_stand(params, stand_params);
            pi_drawer_cutout(params, stand_params);

        }
        pi_drawer_runner_and_mount(params);
        if (supports){
            stand_supports(params, stand_params);
        }
    }
    else{
        base_microscope_stand(params, stand_params);
    }
}

function side_connector_cutout_pos() = [5, -50, 2];
function side_connector_cutout_dims() = [60, 100, 40];

module pi_drawer_cutout(params, stand_params){
    electronics_drawer_h = key_lookup("electronics_drawer_h", stand_params);
    pi_base_size = electronics_drawer_base_size();
    extra_space = [1, 1, 1.5];
    tr_for_extra_space = [-extra_space.x/2, -extra_space.y/2, 0];
    pi_space = [pi_base_size.x, pi_base_size.y, electronics_drawer_h];
    front_wall_space = [pi_base_size.x, electronics_drawer_front_width(), electronics_drawer_h];
    //Cut out a further 99mm in x to make hole in front
    pi_cutout_size = pi_space + extra_space + [99, 0, 0];
    front_wall_cutout_size = front_wall_space + extra_space + [99, 0, 0];
    electronics_drawer_frame_xy(params){
        translate(tr_for_extra_space){
            cube(pi_cutout_size);
            translate(electronics_drawer_front_pos()){
                cube(front_wall_cutout_size);
            }
        }
        //Cutout for the side connectors
        translate(side_connector_cutout_pos()){
            cube(side_connector_cutout_dims());
        }
        translate(electronics_drawer_side_screw_pos()){
            rotate_x(90){
                m3_cap_counterbore(10, 10);
            }
        }
    }
}

// These are the supports over the long bridges for access
// to the electronics drawer
module stand_supports(params, stand_params){
    front_stand_supports(params, stand_params);
    side_stand_supports(params, stand_params);
}

// The radius for the base of the stand
function stand_support_base_radius() = 5;
// This is then "squeezed" into an eliptical base.
function stand_support_base_squeeze() = 0.7;

//given i (suport number) and j (sub suport number) return the fraction
//along the span to place the top of the support
function support_fraction_for_top(i, j, n_sup, n_sub_sup) = let(
    base_fraction = 1/(n_sup*n_sub_sup+1)
) base_fraction*((i-1)*n_sub_sup+j);

//given i (suport number) return the fraction
//along the span to place the base of the support
function support_fraction_base(i, n_sup, n_sub_sup) = let(
    base_fraction = 1/(n_sup*n_sub_sup+1)
) base_fraction*((i-1)*n_sub_sup+(n_sub_sup+1)/2);


// Supports for the long bridge over the space where the electronics drawer
// enters the stand
module front_stand_supports(params, stand_params, n_sup=2, n_sub_sup=2){
    electronics_drawer_h = key_lookup("electronics_drawer_h", stand_params);
    // x translates to the front of the drawer
    x_sup_pos = electronics_drawer_base_size().x + electronics_drawer_wall_t()+3.5;

    sup_rad = stand_support_base_radius();
    sup_squeeze = stand_support_base_squeeze();

    module top_of_support(i,j){
        fraction = support_fraction_for_top(i, j, n_sup, n_sub_sup);
        intersection(){
            base_microscope_stand(params, stand_params);
            electronics_drawer_frame_xy(params){
                translate_y(electronics_drawer_front_width()*fraction-0.5){
                    translate(electronics_drawer_front_pos()){
                        translate_z(electronics_drawer_h){
                            cube([x_sup_pos,1,1.5]);
                        }
                    }
                }
            }
        }
    }
    module center_of_support(i){
        fraction = support_fraction_base(i, n_sup, n_sub_sup);
        electronics_drawer_frame_xy(params, for_base_section=true){
            translate_y(electronics_drawer_front_width()*fraction){
                translate_x(x_sup_pos){
                    translate_z(.7*electronics_drawer_h){
                        cylinder(r=sup_rad*.4, h=1);
                    }
                }
            }
        }
    }
    module base_of_support(i, brim=false){
        fraction = support_fraction_base(i, n_sup, n_sub_sup);
        base_r = sup_rad + (brim ? 2 : 0);
        electronics_drawer_frame_xy(params, for_base_section=true){
            translate_y(electronics_drawer_front_width()*fraction){
                translate_x(x_sup_pos+base_r*sup_squeeze+1){
                    scale([sup_squeeze, 1, 1]){
                        cylinder(r=base_r, h=.2);
                    }
                }
            }
        }
    }
    for (i=[1:n_sup]){
        base_of_support(i, brim=true);
        hull(){
            center_of_support(i);
            base_of_support(i);
        }
        for (j=[1:n_sub_sup]){
            hull(){
                center_of_support(i);
                top_of_support(i,j);
            }
        }
    }
}

// Supports for the long bridge over the space to access side connectors on
// the electronics drawer (HDMI etc)
module side_stand_supports(params, stand_params, n_sup=2, n_sub_sup=2){
    y_sup_pos = -4;
    sup_rad = stand_support_base_radius();
    sup_squeeze = stand_support_base_squeeze();
    cut_pos = side_connector_cutout_pos();
    cut_dims = side_connector_cutout_dims();

    module top_of_support(i,j){
        fraction = support_fraction_for_top(i, j, n_sup, n_sub_sup);
        intersection(){
            base_microscope_stand(params, stand_params);
            electronics_drawer_frame_xy(params){
                translate_x(cut_dims.x*fraction-0.5){
                    translate(cut_pos){
                        translate_z(cut_dims.z-1.5){
                            cube([1, 99, 1.5]);
                        }
                    }
                }
            }
        }
    }

    module center_of_support(i){
        fraction = support_fraction_base(i, n_sup, n_sub_sup);
        electronics_drawer_frame_xy(params, for_base_section=true){
            translate_x(cut_dims.x*fraction){
                translate([cut_pos.x+5, y_sup_pos, .7*cut_dims.z]){
                    cylinder(r=.4*sup_rad, h=1);
                }
            }
        }
    }

    module base_of_support(i, brim=false){
        fraction = support_fraction_base(i, n_sup, n_sub_sup);
        base_r = sup_rad + (brim ? 2 : 0);
        electronics_drawer_frame_xy(params, for_base_section=true){
            translate_x(cut_dims.x*fraction){
                translate([cut_pos.x+5, y_sup_pos-base_r*sup_squeeze-1]){
                    scale([1, sup_squeeze, 1]){
                        cylinder(r=base_r, h=.2);
                    }
                }
            }
        }
    }
    for (i=[1:n_sup]){
        base_of_support(i, brim=true);
        hull(){
            center_of_support(i);
            base_of_support(i);
        }
        for (j=[1:n_sub_sup]){
            hull(){
                center_of_support(i);
                top_of_support(i,j);
            }
        }
    }
}


module pi_drawer_runner_and_mount(params){
    electronics_drawer_frame_xy(params){
        stand_base_size = electronics_drawer_base_size();
        stand_block_size = electronics_drawer_mount_block_size();
        position = electronics_drawer_mount_block_pos() + [0, 1, 0];
        side_len = stand_base_size.x-stand_block_size.x;
        difference(){
            union(){
                translate(position){
                    translate_x(-10){
                        cube([10, stand_block_size.y-1, 10]);
                    }
                    translate_x(-side_len){
                        cube([side_len, 2, 5]);
                    }
                }
            }
            translate(electronics_drawer_front_screw_pos()){
                rotate_y(90){
                    m3_cap_counterbore(10, 99);
                }
            }
            translate(electronics_drawer_front_nut_trap_pos()){
                hull(){
                    for(z_tr = [0, 20]){
                        translate_z(z_tr){
                            rotate_y(90){
                                m3_nut_hole();
                            }
                        }
                    }
                }
            }
        }
    }
}

function pi_board_dims() = [85, 56, 1.5];
function electronics_drawer_board_inset() = [3, 3, 0];
function electronics_drawer_wall_t() = electronics_drawer_board_inset().x - 0.5;
function electronics_drawer_thickness() = 2;
function electronics_drawer_base_size() = let(
    t = electronics_drawer_thickness(),
    board_size = [pi_board_dims().x, pi_board_dims().y, t]
) board_size + 2 * electronics_drawer_board_inset();
function electronics_drawer_front_width() = electronics_drawer_base_size().y+10;

//Position in the frame of the electronics_drawer
function electronics_drawer_front_pos() = let(
    x_tr = electronics_drawer_base_size().x - electronics_drawer_wall_t()
) [x_tr, 0, 0];

function sanga_stand_height(sanga_version="stack_8.5mm") = let(
    extra_h = (sanga_version=="stack_8.5mm") ?
                12.5 :
                (sanga_version=="stack_11mm") ?
                15 :
                27  // otherwise Sangaboard v0.3
) electronics_drawer_standoff_h() + extra_h;

function electronics_drawer_mount_block_size() = let(
    height = sanga_stand_height("stack_11mm"),
    width = electronics_drawer_front_width()-electronics_drawer_base_size().y
) [10, width, height];

function electronics_drawer_mount_block_pos() = let(
    block_depth = electronics_drawer_wall_t()-electronics_drawer_mount_block_size().x
) electronics_drawer_front_pos() + [block_depth, electronics_drawer_base_size().y, 0];

function electronics_drawer_front_screw_pos() = let(
    block_pos = electronics_drawer_mount_block_pos()
) [block_pos.x+3, block_pos.y+6, 5];

function electronics_drawer_front_nut_trap_pos() = electronics_drawer_front_screw_pos() - [7, 0, 0];

function electronics_drawer_side_screw_pos() = [-1, -3, 35];

function electronics_drawer_nut_block_depth() = 5;

function electronics_drawer_side_nut_trap_pos() = let(
    wall_t = electronics_drawer_wall_t(),
    nut_block_depth = electronics_drawer_nut_block_depth(),
    side_screw_pos = electronics_drawer_side_screw_pos()
) [side_screw_pos.x, wall_t+nut_block_depth/2 ,side_screw_pos.z];

function electronics_drawer_block_hole_pos() = let(
    block_pos = electronics_drawer_mount_block_pos(),
    block_size = electronics_drawer_mount_block_size(),
    wall_size = [electronics_drawer_wall_t(), 0, 0],
    block_cent = block_pos + block_size/2 - wall_size/2
) [block_cent.x, block_cent.y, block_size.z-6];

function electronics_drawer_standoff_h() = 5.5;

module electronics_drawer(stand_params){
    electronics_drawer_base(stand_params);
    electronics_drawer_walls(stand_params);
}

function pi_hole_pos(inset_for_stand=false) = let(
    hole_inset = [3.5, 3.5, 0],
    board_inset = inset_for_stand ?  electronics_drawer_board_inset() : [0, 0, 0],
    h1 = [0, 0, 0]+hole_inset+board_inset,
    h2 = [58, 0, 0]+hole_inset+board_inset,
    h3 = [0, 49, 0]+hole_inset+board_inset,
    h4 = [58, 49, 0]+hole_inset+board_inset
) [h1, h2, h3, h4];

module pi_tap_holes(connector_side=true, inside=true){
    all_holes = pi_hole_pos(true);
    connector_holes = connector_side ? [0, 1] : [];
    inside_holes = inside ? [2, 3] : [];
    //only create tap holes for selected holes
    tap_holes = concat(connector_holes, inside_holes);
    for (hole_num = tap_holes){
        hole = all_holes[hole_num];
        translate(hole){
            no2_selftap_hole(h=99, center=true);
        }
    }
}

module electronics_drawer_base(stand_params){
    pi_version = key_lookup("pi_version", stand_params);
    sanga_version = key_lookup("sanga_version", stand_params);
    standoff_h = electronics_drawer_standoff_h();
    base_size = electronics_drawer_base_size();
    hole_pos = pi_hole_pos(true);
    difference(){
        union(){
            cube(base_size);
            for (hole = hole_pos){
                translate(hole){
                    cylinder(d=5.5, h=standoff_h, $fn=12);
                }
            }
        }
        pi_tap_holes(connector_side=false);
        translate_y(base_size.y/2){
            cube(25, center=true);
        }
        text_height = 5;
        version_string_p = str("Pi ", pi_version,"B");
        version_string_s = str("Sanga ",sanga_version);
        translate([20, (base_size.y/2 + text_height*0.5), base_size.z-0.5]){
            linear_extrude(10){
                text(version_string_p,text_height);
            }
        }
        translate([20, (base_size.y/2 - text_height), base_size.z-0.5]){
            linear_extrude(10){
                text(version_string_s,text_height);
            }
        }
    }
}


module electronics_drawer_walls(stand_params){
    electronics_drawer_h = key_lookup("electronics_drawer_h", stand_params);
    block_usb = key_lookup("block_usb", stand_params);
    pi_version = key_lookup("pi_version", stand_params);
    sanga_version = key_lookup("sanga_version", stand_params);
    base_size = electronics_drawer_base_size();
    wall_t = electronics_drawer_wall_t();
    extra_wall_length = 5.5; // to accommodate a mounting lug for nano convertor plate

    difference(){
        union(){
            translate_x(-extra_wall_length){
                cube([(base_size.x + extra_wall_length), wall_t, electronics_drawer_h]);
            }
            translate(electronics_drawer_front_pos()){
                cube([wall_t, electronics_drawer_front_width(), electronics_drawer_h]);
            }
            translate(electronics_drawer_mount_block_pos()){
                cube(electronics_drawer_mount_block_size());
            }
            electronics_drawer_nut_trap();
            sanga_lugs(sanga_version);
        }

        pi_connector_holes(pi_version);
        sanga_connector_holes(sanga_version);

        translate(electronics_drawer_front_screw_pos()){
            rotate_y(90){
                m3_cap_counterbore(999, 999);
            }
        }
        translate(electronics_drawer_side_screw_pos()){
            rotate_x(90){
                //Change to through holes
                m3_cap_counterbore(1, 999);
            }
        }
        translate(electronics_drawer_block_hole_pos()){
            no2_selftap_hole(h=99);
        }

    }
    if (pi_version==4 && block_usb){
        usb_c_blocker();
    }
    if (pi_version==3 && block_usb){
        micro_usb_blocker();
    }
}

function sanga_connector_x(sanga_version) = (sanga_version=="stack_8.5mm" || sanga_version=="stack_11mm") ?
                                                11.2 :
                                                23.7;


function sanga_v0_3_board_dims() = [65, 55, 1.5];

function sanga_v0_3_holes() = let(
    sb_x = sanga_v0_3_board_dims().x,
    sb_y = sanga_v0_3_board_dims().y,
    offset_x = pi_board_dims().x-sb_x,
    inset = electronics_drawer_board_inset() + [offset_x, 0, 0]
) [[4, 4, 0] + inset,
   [sb_x-4, 4, 0] + inset,
   [sb_x-4, sb_y-4, 0] + inset,
   [4, sb_y-4, 0] + inset
  ];

module sanga_connector_holes(sanga_version){
    v0_3_offset_x = pi_board_dims().x-sanga_v0_3_board_dims().x;
    board_inset = (sanga_version=="stack_8.5mm" || sanga_version=="stack_11mm") ?
        electronics_drawer_board_inset() :
        electronics_drawer_board_inset() + [v0_3_offset_x, 0, 0];

    wall_t = electronics_drawer_wall_t();
    connector_extra_z = (sanga_version=="stack_8.5mm" || sanga_version=="stack_11mm") ?
                            3 :
                            3.75;
    connector_z = sanga_stand_height(sanga_version) + tiny() + connector_extra_z;
    connector_x = sanga_connector_x(sanga_version) + board_inset.x;
    sanga_connector_pos = [connector_x, 0, connector_z];
    translate(sanga_connector_pos){
        translate_y((wall_t-10)/2){
            cube([12, 10, 8], center=true);
            cube([10, 200, 4.5], center=true);
        }
    }
    if (sanga_version=="v0.3"){
        x_dim = 2*electronics_drawer_base_size().x+1;
        translate([0, board_inset.y, sanga_stand_height(sanga_version)]){
            translate([0, 32.5, 2+8/2]){
                cube([x_dim, 15, 8], center=true);
            }
            translate([0, 18, 2+4.5/2]){
                cube([x_dim, 9, 4.5], center=true);
            }
        }
    }
}

module no2_selftap_lug(hole_pos, wall_pos, wall_angle){
    translate_z(-5){
        difference(){
            hull(){
                translate(hole_pos){
                    cylinder(d=5.5, h=5, $fn=12);
                }
                // make the lug at consistent slope, about 30 deg above horizontal, by setting the 
                // z height of the bottom of the lug slope at a bit less than the distance from the wall
                z_for_angle = 0.75 * sqrt((hole_pos.y - wall_pos.y)^2 + (hole_pos.x - wall_pos.x)^2);
                translate([(wall_pos.x), wall_pos.y, (hole_pos.z - z_for_angle)]){
                    rotate_z(wall_angle){
                        translate_x(-5.5/2){
                            cube([5.5, 0.1, 5+z_for_angle], center=false);
                        }
                    }
                }
            }
            translate(hole_pos){
                no2_selftap_hole(h=99, center=true);
            }
        }
    }
}

// offset from pi_hole_pos()[0] for a third mounting hole for the nano convertor plate, 
function nano_conv_plate_third_screw_ofst() = [-8, 3, 0];

module sanga_lugs(sanga_version){

    side_lugs = (sanga_version=="stack_11mm")?
        [pi_hole_pos(true)[0], pi_hole_pos(true)[1], (pi_hole_pos(true)[0]+ nano_conv_plate_third_screw_ofst())] :
        (sanga_version=="stack_8.5mm") ?
            [pi_hole_pos(true)[0], pi_hole_pos(true)[1]] :
            [sanga_v0_3_holes()[0], sanga_v0_3_holes()[1]];
    front_lugs = (sanga_version=="stack_8.5mm" || sanga_version=="stack_11mm") ?
        [] :
        [sanga_v0_3_holes()[2]];
    translate_z(sanga_stand_height(sanga_version)){
        for (hole_pos = side_lugs){
            no2_selftap_lug(hole_pos, [hole_pos.x, 0.1, 0], 0);
        }
        for (hole_pos = front_lugs){
            front_x = electronics_drawer_base_size().x-0.1;
            no2_selftap_lug(hole_pos, [front_x, hole_pos.y, 0], 90);
        }
    }
}

module electronics_drawer_nut_trap(){

    nut_block_depth = electronics_drawer_nut_block_depth();
    nut_tr_pos = electronics_drawer_side_nut_trap_pos();
    translate(nut_tr_pos){
        difference(){
            hull(){
                cube([8, nut_block_depth+tiny(), 6], center=true);
                translate([0, -nut_block_depth/2, -nut_block_depth]){
                    cube([8, tiny(), 6], center=true);
                }
            }
            hull(){
                for(z_tr = [0, 20]){
                    translate([0, 0.1, z_tr]){
                        rotate_z(-90){
                            rotate_y(90){
                                m3_nut_hole();
                            }
                        }
                    }
                }
            }
        }
    }
}

module pi_connector_holes(pi_version){
    board_inset = electronics_drawer_board_inset();
    standoff_h = electronics_drawer_standoff_h();

    translate(board_inset + [0, 0, standoff_h+1]){
        translate_x(electronics_drawer_base_size().x-10){
            pi_front_connectors(pi_version);
        }

        translate_y(-board_inset.y-tiny()){
            pi_side_connectors(pi_version);
        }
        hull(){
            translate_y(-(board_inset.y-1.5)){
                pi_side_connectors(pi_version);
            }
        }
    }
}

module pi_front_connectors(pi_version){

    if (pi_version==4){
        translate_y(45.75-17/2){
            cube([200, 17, 14.5]);
        }
        translate_y(27-15.5/2){
            cube([200, 15.5, 17]);
        }
        translate_y(9-15.5/2){
            cube([200, 15.5, 17]);
        }
    }
    else{
        translate_y(10.25-17/2){
            cube([200, 17, 14.5]);
        }
        translate_y(29-15.5/2){
            cube([200, 15.5, 17]);
        }
        translate_y(47-15.5/2){
            cube([200, 15.5, 17]);
        }
    }
}

module pi_side_connectors(pi_version){
    if (pi_version==4){
        translate_x(11.2-10/2){
            cube([10, 200, 4.5]);
        }
        translate_x(26-8/2){
            cube([8, 200, 4.5]);
        }
        translate_x(39.5-8/2){
            cube([8, 200, 4.5]);
        }
    }
    else{
        // Micro USB power
        translate_x(10.6-9/2){
            cube([9, 200, 4.5]);
        }
        // Full size HDMI
        translate_x(32-17/2){
            cube([17, 200, 7]);
        }

    }

    headphone_x = (pi_version==4) ? 54 : 53.5;

    translate_x(headphone_x-7/2){
        translate([3.5, 0, 3.5]){
            rotate_x(-90){
                cylinder(d1=7, d2=8, h=5);
            }
        }
    }

}

module usb_c_blocker(){
    standoff_h = electronics_drawer_standoff_h();
    usb_c_x_pos = 11.2 + electronics_drawer_board_inset().x;
    //Translate to bottom centre of hole
    translate([usb_c_x_pos, 0, standoff_h+1]){
        translate([-8/2, 0, .75]){
            cube([8, 1, 3]);
        }
        translate([-12/2, 0, .75]){
            cube([12, 1, 1]);
        }
        translate([-12/2, 0, 2.75]){
            cube([12, 1, 1]);
        }
    }
}

module micro_usb_blocker(){
    standoff_h = electronics_drawer_standoff_h();
    micro_usb_x_pos = 10.6 + electronics_drawer_board_inset().x;
    //Translate to bottom centre of hole
    translate([micro_usb_x_pos, 0, standoff_h+1]){
        translate([-7/2, 0, .75]){
            cube([7, 1, 3]);
        }
        translate([-12/2, 0, .75]){
            cube([12, 1, 1]);
        }
        translate([-12/2, 0, 2.75]){
            cube([12, 1, 1]);
        }
    }
}
