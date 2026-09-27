
use <../../openscad/libs/utilities.scad>
use <../../openscad/libs/logo.scad>
use <../../openscad/libs/lib_microscope_stand.scad>
use <../../openscad/libs/cameras/logitech_c270.scad>
use <../electronics/led_board.scad>
use <render_utils.scad>

$fn = 12;


module illumination_board(){
    rotate([180, 0, -90]){
        sangaboard_v0_5_cc_led_board();
    }
}

function illumination_board_connector_offset() = [0, 2.7 + 4.84, 3.5/2];

function sangaboard_v0_4_dims() = [65, 57, 1.6];

module sangaboard_v0_4(){
    sangaboard_v0_4_board();
    sangaboard_v0_4_connectors();
    sangaboard_v0_4_chip();
}

module sangaboard_v0_4_chip(){
    size = sangaboard_v0_4_dims();
    translate_z(size.z){
        chip(24, 30, 10, 10, 1);
        chip(37, 17, 10, 4, 2);
        chip(37, 28, 10, 4, 2);
        chip(38.5, 44, 5, 4, 2);
    }
}

module sangaboard_v0_4_connectors(){
    size = sangaboard_v0_4_dims();

    translate([54, 26.7, size.z]){
        for (i = [-1:1]){
            translate_y(i*8.7){
                rotate_z(180){
                    motor_jst_socket();
                }
            }
        }
    }

    translate([11.2, 0, size.z]){
        micro_usb_socket();
    }

    translate([0, 45, size.z]){
        rotate_z(-90){
            micro_usb_socket();
        }
    }

    translate(pi_header_pin_xy() + [0, 0, size.z]){
        translate_x(6*2.54){
            double_header_pins(1);
        }
        translate_x(8*2.54){
            double_header_pins(3);
        }
        translate_y(-8){
            translate_x(3*2.54){
                double_header_pins(2);
            }
            translate_x(6*2.54){
                double_header_pins(2);
            }
            translate_x(9*2.54){
                double_header_pins(1);
            }
        }
    }

    translate([46.5, size.y-2.7, size.z]){
        rotate(-90){
            double_header_pins(3);
        }
    }
    translate([52.5, size.y-2.7, size.z]){
        rotate(-90){
            double_header_pins(6);
        }
    }
    translate([size.x-14.8, 11.3, size.z]){
        rotate(-90){
            double_header_pins(4);
        }
    }
    translate([size.x-6.5, 11.3, size.z]){
        rotate(-90){
            double_header_pins(2);
        }
    }
    
    mirror([0, 0, 1]){
        translate(pi_header_pin_xy()){
            female_double_headers(5);
            translate_x(12*2.54){
                female_double_headers(2);
            }
        }
    }
}

module sangaboard_v0_4_board(){
    size = sangaboard_v0_4_dims();
    coloured_render("green"){
        difference(){
            linear_extrude(size.z){
                //Fillet must be less that 1mm to not close pi-slot hole!
                fillet_2d(r=.9){
                    difference(){
                        fillet_2d(r=2){
                            square([size.x, size.y]);
                        }
                        translate([44, -1]){
                            square([2, 21]);
                        }
                        translate_y(size.y/2){
                            square([10, 17], center=true);
                        }
                    }
                }
            }
            for (hole = pi_hole_pos()){
                translate(hole){
                    cylinder(d=2.7, h=10, center=true);
                }
            }
        }
    }
}

function pi_header_pin_xy() = [8.3, pi_board_dims().y-3, 0];


module rpi_4b(){
    rpi_4b_board();
    rpi_4b_ports();
    rpi_4b_top_chips();
}

module rpi_4b_top_chips(){
    translate_z(pi_board_dims().z){
        chip(12, 42, 10.7, 13, 1, "Silver");
        chip(29, 32.5, 15, 15, 1, "Silver");
        chip(29, 32.5, 13, 13, 1.5, "Silver");
        chip(44, 32.5, 10, 15, 1.5);
        chip(60, 24, 8, 8, .5);
        chip(59, 38, 6, 6, .5);
        chip(68.5, 34, 3.5, 7, 2);
    }
}

module rpi_4b_ports(){
    size = pi_board_dims();
    translate([2, size.y/2, size.z]){
        csi_port(vertical=true);
    }
    translate([45, 11, size.z]){
        csi_port(vertical=true);
    }
    translate([11.2, 0, size.z]){
        usb_c_socket();
    }
    translate([26, 0, size.z]){
        mini_hdmi_socket();
    }
    translate([39.5, 0, size.z]){
        mini_hdmi_socket();
    }
    translate([54, 0, size.z]){
        audio_jack_socket();
    }
    translate([size.x, 9, size.z]){
        rotate_z(90){
            dual_usb_socket();
        }
    }
    translate([size.x, 27, size.z]){
        rotate_z(90){
            dual_usb_socket(usb3=true);
        }
    }
    translate([size.x, 46, size.z]){
        rotate_z(90){
            ethernet_socket();
        }
    }
    translate(pi_header_pin_xy() + [0, 0, size.z]){
        double_header_pins(20);
    }
    translate([61.5, 45.3, size.z]){
        rotate_z(90){
            double_header_pins(2);
        }
    }
    mirror([0, 0, 1]){
        translate_y(size.y/2){
            rotate_z(-90){
                micro_sd_slot();
            }
        }
    }
}

module rpi_4b_board(){
    size = pi_board_dims();
    //Translate camera to centre in xy, and board top to z=0
    coloured_render("green"){
        difference(){
            filleted_board(size, r=2);
            for (hole = pi_hole_pos()){
                translate(hole){
                    cylinder(d=6, h=10, center=true);
                }
            }
        }
    }

    coloured_render("darkkhaki"){
        for (hole = pi_hole_pos()){
            translate(hole){
                difference(){
                    cylinder(d=6, h=size.z);
                    cylinder(d=2.8, h=99, center=true);
                }
            }
        }
    }

}



module picamera2(lens=true, connector_open=false){
    $fn = 20;
    picamera2_board();

    picamera2_front();
    picamera2_back(connector_open);

    if (lens){
        translate_z(3){
            picamera2_lens();
        }
    }
}

module picamera2_lens(){
    $fn = 20;
    color("#404040"){
        render(){
            difference(){
                union(){
                    cylinder(d=6, h=2);
                    translate_z(1.95){
                        cylinder(d1=6, d2=4, h=1);
                        cube([5, 1.8, 2],center=true);
                        cube([1.8, 5, 2],center=true);
                    }
                }
                translate_z(-.02){
                    cylinder(d1=4, d2=1, h=3);
                }
            }
        }
    }
    color("PaleTurquoise", .60){
        cylinder(d1=4, d2=1, h=3);
    }
}

module picamera2_front(){
    color("black"){
        cylinder(d=6, h=1);
        translate([8, -3, 0]){
            cube([3, 8, 1]);
        }
    }

    color("DimGray"){
        translate([-8.5/2, -8.5/2, 1]){
            cube([8.5, 8.5, 2]);
        }
        translate_z(3){
            difference(){
                cylinder(d=7.3, h=1.5);
                cylinder(d=6.5, h=99, center=true);
            }
        }
        translate([7.5, -3.5, 1]){
            cube([4, 9, .3]);
        }
        translate([0, -3.5, 1]){
            cube([8, 7, .3]);
        }
    }
    color("DarkSlateBlue"){
        translate([-3/2, -4/2, 2.1]){
            cube([3, 4, 1]);
        }
    }
}

module picamera2_back(connector_open=false){
    translate_z(-1){
        mirror([0,0,1]){
            translate_x(-8){
                csi_port(open=connector_open);
            }

            //chips appox for visual similarity
            chip(6, -8, 1.5, 3, .5);
            chip(6, -3, 1.5, 3, .5);
            chip(10, -5.5, 2.5, 2, .5);

            chip(4, 1, 1.5, 1, .5);
            chip(2, 3, 2, 3, .5);
            chip(-1, 3, 1, 2, 1);
            chip(-1, -6, 1.5, 1.5, .5);
            chip(-1, -3, 1.5, 1.5, .5);
            chip(-1, 0, 1.5, 1.5, .5);

            chip(5, 6, 2, 3, 1);
            chip(7, 6, 1, 3, 1);

            chip(6, 10.5, 3, 2, 1);

        }
    }
}

// Build and place a chip component
// x,y centre of chip
// w,h size of chip in x,y
// t thickness of chip
module chip(x, y, w, h, t, colour="#404040"){
    color(colour){
        translate([x-w/2, y-h/2, 0]){
            cube([w, h, t]);
        }
    }
}

module csi_port(open=false, vertical=false){
    rotation = vertical ? 90 : 0;
    z_tr = vertical ? 4 : 0;
    translate_z(z_tr){
        rotate_y(rotation){
            color("DimGray"){
                translate_x(open ? -1.5 : 0){
                    difference(){
                        union(){
                            translate([-1, -21/2, 0]){
                                cube([1, 21, 2.5]);
                            }
                            translate([-.5, -19.1/2, .5]){
                                cube([5, 19.1, 1.5]);
                            }
                        }
                        cube([20, 16.6, 2], center=true);
                    }
                }
            }
            color("Tan"){
                translate([0, -19/2, 0]){
                    cube([4, 19, 2.5]);
                }
            }
        }
    }
}

module audio_jack_socket(){
    color("DimGray"){
        translate_z(3.5){
            difference(){
                union(){
                    translate_y(6){
                        cube([7, 12, 6], center=true);
                    }
                    
                    rotate_x(90){
                        cylinder(d=6, h=5, center=true);
                    }
                }
                rotate_x(90){
                    cylinder(d=3.5, h=99, center=true);
                }
            }
        }
    }
}

module mini_hdmi_socket(){
    color("Silver"){
        translate_y(-1.8){
            difference(){
                minkowski(){
                    mini_hdmi_shape();
                    rotate_x(-90){
                        cylinder(r=.5, h=tiny());
                    }
                }
                translate_y(-1){
                    mini_hdmi_shape();
                }
                for(x_tr = [2.5, -2.5]){
                    translate_x(x_tr){
                        cube([1, 2, 99], center=true);
                    }
                }
            }
        }
    }
    color("DimGray"){
        translate([-2, 0, 1]){
            cube([4, 4 , 1]);
        }
        translate_y(4){
            mini_hdmi_shape(1);
        }
    }
}

module mini_hdmi_shape(depth=8){
    hull(){
        for(x_tr = [2.5, -2.5]){
            translate([x_tr, 0, 1]){
                rotate_x(-90){
                    cylinder(d=1, h=depth);
                }
            }
        }
        translate([-3, 0, 2.5]){
            cube([6, depth, .5]);
        }
    }
}

module hdmi_socket(){
    color("Silver"){
        translate_y(-1.8){
            difference(){
                minkowski(){
                    hdmi_shape();
                    rotate_x(-90){
                        cylinder(r=.5, h=tiny());
                    }
                }
                translate_y(-1){
                    hdmi_shape();
                }
                for(x_tr = [2.5, -2.5]){
                    translate_x(x_tr){
                        cube([1, 2, 99], center=true);
                    }
                }
            }
        }
    }
    color("DimGray"){
        translate([-5, 0, 3]){
            cube([10, 6 , 1]);
        }
        translate_y(6){
            hdmi_shape(1);
        }
    }
}

module hdmi_shape(depth=12){
    hull(){
        for(x_tr = [5, -5]){
            translate([x_tr, 0, 1]){
                rotate_x(-90){
                    cylinder(d=1, h=depth);
                }
            }
        }
        translate([-7.5, 0, 2.5]){
            cube([15, depth, 4]);
        }
    }
}

module usb_c_socket(){
    color("Silver"){
        translate_y(-1.8){
            difference(){
                minkowski(){
                    usb_c_shape();
                    rotate_x(-90){
                        cylinder(r=.5, h=tiny());
                    }
                }
                translate_y(-1){
                    usb_c_shape();
                }
            }
        }
    }
    color("DimGray"){
        translate([-3, -1.5, 1]){
            cube([6, 7 , 1]);
        }
        translate_y(4){
            usb_c_shape(1.7);
        }
    }
}

module usb_c_shape(depth=7.3){
    hull(){
        for(x_tr = [3, -3]){
            for(z_tr = [1, 2]){
                translate([x_tr, 0, z_tr]){
                    rotate_x(-90){
                        cylinder(d=1, h=depth);
                    }
                }
            }
        }
    }
}


module micro_usb_socket(){
    color("Silver"){
        translate_y(-0.8){
            difference(){
                minkowski(){
                    micro_usb_shape();
                    rotate_x(-90){
                        cylinder(r=.5, h=tiny());
                    }
                }
                translate_y(-1){
                    micro_usb_shape();
                }
            }
        }
    }
    color("DimGray"){
        translate([-3, 0, 1.5]){
            cube([6, 4 , .5]);
        }
        translate_y(2){
            micro_usb_shape(1.7);
        }
    }
}

module micro_usb_shape(depth=5.4){
    hull(){
        for(i = [-1, 1]){
            for(j = [-1, 1]){
                x_tr = 2.5*i + 0.5*i*j;
                z_tr = 1.5 + 0.5*j;
                translate([x_tr, 0, z_tr]){
                    rotate_x(-90){
                        cylinder(d=1, h=depth);
                    }
                }
            }
        }
    }
}


module dual_usb_socket(usb3=false){
    usb_col = usb3 ? "DodgerBlue" : "DimGray";
    usb_zs = [4.5, 12.5];
    translate_y(-3){
        color("Silver"){
            difference(){
                dual_usb_socket_outer();

                for (z_tr = usb_zs){
                    translate_z(z_tr){
                        cube([12, 30, 5], center=true);
                    }
                }
            }
        }
        color(usb_col){
            for (z_tr = usb_zs){
                translate([-11/2, .5, z_tr+.5]){
                    cube([11, 15, 1.5]);
                }
            }
        }
    }
}


module dual_usb_socket_outer(){
    translate([-13/2, 0, 1.5]){
        cube([13, 17.5, 14]);
    }
    for (i = [-1, 1]){
        translate([i*12.5/2 -.25, 9.5, -3]){
            difference(){
                cube([0.5, 8, 6]);
                translate([-tiny(), 2, -2]){
                    cube([1, 4, 6]);
                }
            }
        }
    }
    translate([-15/2, 0, 2.5]){
        cube([15, .5, 12]);
    }
    translate([-11/2, 0, .5]){
        cube([11, .5, 16]);
    }
}

module ethernet_socket(){
    translate_y(-3){
        color("Silver"){
            difference(){
                translate_x(-8){
                    cube([16, 21, 13.3]);
                }
                translate_y(-tiny()){
                    ethernet_socket_cutout(depth=13.5, enlarge=.5);
                }
            }
        }
        color("DimGray"){
            difference(){
                ethernet_socket_cutout(depth=13, enlarge=.5);
                translate_y(-tiny()){
                    ethernet_socket_cutout(depth=13);
                }
            }
        }
        color("Green"){
            translate([-4.75, 0, 2.75]){
                cube([3, 2*tiny(), 1.5], center=true);
            }
        }
        color("Yellow"){
            translate([4.75, 0, 2.75]){
                cube([3, 2*tiny(), 1.5], center=true);
            }
        }
    }
}

module ethernet_socket_cutout(depth, enlarge=0){
    size = [12, depth, 7] + [enlarge, 0, enlarge];
    nub1_size = [6.3, depth, 7] + [enlarge, 0, enlarge];
    nub2_size = [4, depth, 7] + [enlarge, 0, enlarge];
    translate([-size.x/2, 0, 3.7-enlarge/2]){
        cube(size);
    }
    translate([-nub1_size.x/2, 0, 2.2-enlarge/2]){
        cube(nub1_size);
    }
    translate([-nub2_size.x/2, 0, 1-enlarge/2]){
        cube(nub2_size);
    }
}

module micro_sd_slot(){
    
    color("Silver"){
        translate_y(1.5){
            difference(){
                translate_x(-12/2){
                    cube([12 , 11.3, 1.5]);
                }
                translate_z(.75){
                    cube([11.5 , 20, 1], center=true);
                }
                translate([1, 0, 1.5]){
                    cube([8 , 3, 2], center=true);
                }
            }
        }
    }
}

module female_double_headers(rows=20){
    for (row_num = [0:rows-1]){
        translate_x(row_num*2.54){
            female_double_header();
        }
    }
}

module female_double_header(){
    color("DimGray"){
        difference(){
            translate_z(8.6/2){
                cube([2.54, 2.54*2, 8.6], center=true);
            }
            for (y_tr = [2.54/2, -2.54/2]){
                translate([0, y_tr, 6]){
                    cube([1, 1, 10], center=true);
                }
            }
        }
    }
    color("Silver"){
        for (y_tr = [2.54/2, -2.54/2]){
            translate_y(y_tr){
                cube([0.6, 0.6, 6], center=true);
            }
        }
    }
}

module double_header_pins(rows=20){
    for (row_num = [0:rows-1]){
        translate_x(row_num*2.54){
            double_header_pin();
        }
    }
}

module double_header_pin(){
    color("DimGray"){
        hull(){
            for (y_tr = [1.4, -1.4]){
                translate_y(y_tr){
                    cylinder(d=2.54, h=2.3, $fn=6);
                }
            }
        }
    }
    color("Gold"){
        for (y_tr = [2.54/2, -2.54/2]){
            translate([-0.3, -0.3+y_tr, -3]){
                cube([0.6, 0.6, 11.5]);
            }
        }
    }
}

module single_header_pins(rows=20){
    for (row_num = [0:rows-1]){
        translate_x(row_num*2.54){
            single_header_pin();
        }
    }
}

module single_header_pin(){
    color("DimGray"){
        hull(){
            translate([-2/2, -3.5/2, 0]){
                cube([2, 3.5, 2.3]);
            }
            translate([-2.55/2, -.8/2, 0]){
                cube([2.55, .8, 2.3]);
            }
        }
    }
    color("Gold"){
        translate([-0.3, -0.3, -3]){
            cube([0.6, 0.6, 11.5]);
        }
    }
}

module single_angled_header_pins(rows=20){
    for (row_num = [0:rows-1]){
        translate_x(row_num*2.54){
            single_angled_header_pin();
        }
    }
}

// One right-angled header pin.
// NB the connector housing ends at y=2.54+2.3=4.84mm
module single_angled_header_pin(){
    translate_z(3.5/2){
        rotate_x(-90){
            translate_z(2.54){
                color("DimGray"){
                    hull(){
                        translate([-2/2, -3.5/2, 0]){
                            cube([2, 3.5, 2.3]);
                        }
                        translate([-2.55/2, -.8/2, 0]){
                            cube([2.55, .8, 2.3]);
                        }
                    }
                }
                color("Gold"){
                    translate([-0.3, -0.3, -2.54]){
                        cube([0.6, 0.6, 11.5]);
                    }
                }
            }
        }
    }
    color("Gold"){
        translate([-0.3, -0.3, -3]){
            cube([0.6, 0.6, 3+3.5/2]);
        }
        translate_z(3.5/2){
            rotate_y(-90){
                cylinder(d=.6, h=.6, center=true);
            }
        }
    }

}

function picamera2_size() = [23.862, 25, 1];
function picamera2_cam_pos_x() = 9.462;

function picamera2_holes() = let(
    cam_pos_x = picamera2_cam_pos_x(),
    h_y = picamera2_size().y/2-2,
    h_x1 = picamera2_size().x-2-cam_pos_x,
    h_x2 = picamera2_size().x-14.5-cam_pos_x
) [[h_x1, h_y, 0], [h_x1, -h_y, 0], [h_x2, h_y, 0], [h_x2, -h_y, 0]];

module picamera2_board_blank(x, y, t, cam_pos_x){
    //Translate camera to centre in xy, and board top to z=0
    translate([x/2-cam_pos_x, 0 ,-t]){
        filleted_board([x, y, t], r=2, center=true);
    }
}

module picamera2_board(){
    $fn = 20;
    cam_pos_x = picamera2_cam_pos_x();

    x = picamera2_size().x;
    y = picamera2_size().y;
    t = picamera2_size().z;
    // board except with cutout for screw clearance
    color("green"){
        render(){
            difference(){
                picamera2_board_blank(x, y, t, cam_pos_x);
                for (hole = picamera2_holes()){
                    translate(hole + [0, 0, -t]){
                        cylinder(d=5, h=99, center=true);
                    }
                }
            }
        }
    }
    // screw clearance area
    color("darkkhaki"){
        render(){
            intersection(){
                picamera2_board_blank(x, y, t, cam_pos_x);
                for (hole = picamera2_holes()){
                    translate(hole + [0, 0, -t]){
                        difference(){
                            cylinder(d=5, h=t);
                            cylinder(d=2.2, h=99, center=true);
                        }
                    }
                }
            }
        }
    }
}

module picamera2_tool(){
    $fn=30;
    color("#CCCCCC"){
        difference(){
            cylinder(d = 7, h=1.6);
            cylinder(d = 4.8, h=99,center=true);
        }
        translate_z(1.6){
            difference(){
                cylinder(d=22.7,h=7);
                cylinder(d=19,h=99, center=true);
            }
            difference(){
                cylinder(d1 = 7, d2=22.7,h=7);
                translate_z(-0.05){
                    cylinder(d1 = 4.8, d2=19, h=7.1);
                }
            }
        }
    }
}

module picamera_cable(positions){
    coloured_render("WhiteSmoke"){
        ribbon_cable(16, positions);
    }
    place_part(positions[0]){
        picamera_cable_connector();
    }
    place_part(positions[len(positions)-1]){
        rotate_y(180){
            picamera_cable_connector();
        }
    }
}

module picamera_cable_connector(){
    
    coloured_render("WhiteSmoke"){
        translate_x(-5){
            cube([10, 16, 0.5], center=true);
        }
    }
    coloured_render("DodgerBlue"){
        translate([-5, 0, 0.25]){
            cube([10, 16, 0.1], center=true);
        }
    }
    coloured_render("Silver"){
        for (i = [-7 : 7]){
            translate([-7.5, i, -0.25]){
                cube([5, 0.7, 0.1], center=true);
            }
        }
    }
}

module c270_lens(){
    h=6;
    translate_z(-1){
        $fn = 20;
        color("#404040"){
            render(){
                difference(){
                    union(){
                        cylinder(d=8, h=h-.5);
                        translate_z(h-1){
                            cylinder(d=12, h=1);
                        }
                    }
                    translate_z(-tiny()){
                        cylinder(d1=6, d2=1, h=h+2*tiny());
                    }

                    difference(){
                        translate_z(h-.5){
                            cylinder(d1=7, d2=7.5, h=.5+tiny());
                        }
                        translate_z(h-.5-tiny()){
                            cylinder(d1=7.5, d2=.6, h=.5+tiny()*2);
                        }
                    }

                    for (i = [1:12]){
                        r_c=11/2;
                        rotate_z(i*30){
                            hull(){
                                translate_x(r_c){
                                    cylinder(d=1.5, h=2*h);
                                }
                                translate_x(r_c+2){
                                    cylinder(d=1.5, h=2*h);
                                }
                            }
                        }
                    }
                }
            }
        }
        color("PaleTurquoise", .60){
            cylinder(d1=6, d2=1, h=h-.25);
        }
    }
}

function c270_holes() = let(
    screw_x = c270_camera_hole_spacing(),
    third = -c270_near_third_hole_pos()
) [[screw_x, 0, 0] , [-screw_x, 0, 0] , third] ;


module c270_pcb_outer_shape(){
    x=22;
    y=60;
    t=1;
    //cam_pos_y=-17.75;
    //Camera to centre in xy, and board top to z=0
    translate_z(-t){
        linear_extrude(t){
            difference(){
                polygon(points= [
                        [-10.5, 3.2],
                        [-4.85, 13.55],
                        [4.85, 13.55],
                        [10.5, 3.2],
                        [10.5, -34.2],
                        [4.7, -34.2],
                        [4.7, -37.7],
                        [7.8, -37.7],
                        [7.8, -41.6],
                        [6.65, -44.35],
                        [-6.5, -44.35],
                        [-10.5, -36.6]
                        ]
                );
                translate([4.7, -35.95]){
                    circle(d=3.5);
                }
                reflect_x(){
                    translate([10.4, -6]){
                        hull(){
                            circle(d=2);
                            translate_y(-2.5){
                                circle(d=2);
                            }
                        }
                    }
                }
            }
        }
    }
}

module c270_components(){
    c270_front_components();
    c270_back_components();
}

module c270_front_components(){
    // camera sensor
    translate_z(1.5/2){
        color("DimGray"){
            difference(){
                cube([8,7,1.5], center=true);
                translate_z(1){
                    cube([7,6,3], center=true);
                }
            }
        }
        color("darkred", 0.5){
            translate_z(0.5){
                cube([7,6,0.5], center=true);
            }
        }
    }
    chip(-0.5, -24.4, 4, 6, 1);
    chip(5.5, -29, 4.6, 3.6, 1.5, "DimGray");
    chip(3, 11, 1, 2, 0.5);
    chip(0, 11.5, 2, 1, 0.5, "Silver");
    chip(4, -10, 2, 1, 0.5);
    chip(7, -14, 1, 1, 0.5);
    chip(-8, -22, 2, 1.5, 0.5);
    chip(0, -36, 1, 1, 0.5);
    chip(-2, -40, 1, 1, 0.5);
    chip(-4, -38, 1, 1, 0.5);
    chip(-2, -32, 1, 1, 0.5);
    chip(-7, -32, 1, 1, 0.5);
    // microphone pads
    translate([0.75,-12,0]){
        coloured_render("gold"){
            cube([1,1,tiny()], center=true);
        }
    }
    translate([-0.75,-12,0]){
        coloured_render("gold"){
            cylinder(d=1, h=tiny(), center=true);
        }
    }
    translate([2,-40.5,0]){
        coloured_render("gold"){
            cylinder(d=2, h=tiny(), center=true);
        }
    }
    // microphone screenprint
    translate([0,-13,0]){
        coloured_render("white"){
            difference(){
                cylinder(d=5, h=tiny()/2, center=true, $fn=16);
                cylinder(d=4.9, h=tiny(), center=true, $fn=16);
            }
        }
    }
}

module c270_back_components(){
    translate_z(-1){
        mirror([0,0,1]){
            chip(3, -4, 4, 4, 1);
            chip(6, 3, 1, 1, 1);
            chip(4.5, 7, 1, 2, 1);
            chip(1, 7, 1, 2, 1);
            chip(-2.5, 6, 1, 1, 1);
            chip(-6, 3.5, 2, 1, 1);
            chip(-7, -4.5, 2, 1, 1);
            chip(-7, -12.5, 2, 1, 1);
            chip(-7, -16, 2, 2, 1.5);
            chip(-7, -21, 2, 2, 1.5);
            chip(7, -11, 1, 1, 1);
            chip(7, -16.5, 2, 1, 1);

            //solder blobs
            coloured_render("silver"){
                translate([2,-40.5,0]){
                    cylinder(d1=2, d2=.8, h=.8);
                    cylinder(d=.8, h=1.6);
                }
            }
            coloured_render("silver"){
                translate([.75,-12,0]){
                    cylinder(d1=1, d2=.4, h=.4);
                    cylinder(d=.4, h=.8);
                }
                translate([-.75,-12,0]){
                    cylinder(d1=1, d2=.4, h=.4);
                    cylinder(d=.4, h=.8);
                }
            }
            translate([-6,-34,0]){
                camera_jst_socket();
            }
        }
    }
}

module camera_jst_socket(){
    //ZHR-4 male
    coloured_render("Beige"){
        difference(){
            translate_z(2.5/2){
                cube([6.1, 4.3, 2.5], center=true);
            }
            translate_z(2.5/2){
                translate_y(-1){
                cube([6.1-1, 4.3, 2.5-1], center=true);
                }
            }
        }
    }
    coloured_render("Silver"){
        for (pin_num = [-1.5:1.5]){
            x_tr = pin_num*1.5;
            translate([x_tr, 0, 1.5]){
                cube([0.2, 3, .2], center=true);
            }
        }
    }
}

module c270_board(){
    coloured_render("SteelBlue"){
        difference(){
            c270_pcb_outer_shape();
            rotate_z(225){
                at_c270_hole_pattern(){
                    // No1 self tap clearance
                    cylinder(d=1.8, h=5, center=true, $fn=16);
                }
            }
            rotate(180){
                translate(c270_far_third_hole_pos()){
                    // No1 self tap clearance
                    cylinder(d=1.8, h=5, center=true, $fn=16);
                }
            }
            //tiny extra holes
            translate([6, -39.5]){
                cylinder(d=1, h=5, center=true, $fn=8);
            }
            translate([-4, 11]){
                cylinder(d=1, h=5, center=true, $fn=8);
            }
        }
    }
    c270_components();
}

// The 7 inch diplay is used in the field dissection microscope
// It is inculded in the main repo as it might be useful down the line
// for creating an OFM with an integrated screen
module display_7inch_lcd(){
    $fn=16;
    board_dims = [165, 107, 1.5];

    display_7inch_lcd_board(board_dims);
    display_7inch_lcd_screen(board_dims);
    display_7inch_lcd_components(board_dims);
}

module display_7inch_lcd_board(board_dims){
    coloured_render("SteelBlue"){
        difference(){
            union(){
                cube(board_dims);
                for (i=[-0.5, 0.5]*157){
                    hull(){
                        for(j = [-0.5, 0.5]*116){
                            translate([i+board_dims.x/2, j+board_dims.y/2]){
                                cylinder(h= board_dims.z, d=8);
                            }
                        }
                    }
                }
            }
            for (i=[-0.5, 0.5]*157, j = [-0.5, 0.5]*116){
                translate([i+board_dims.x/2, j+board_dims.y/2]){
                    cylinder(h= 3*board_dims.z, d=3, center=true);
                }
            }
        }
    }
}

module display_7inch_lcd_screen(board_dims){
    translate([board_dims.x/2, board_dims.y/2]){
        translate_z(board_dims.z+4/2){
            coloured_render("#404040"){
                difference(){
                    cube([158, 93, 4], center=true);
                    cube([138, 95, 5], center=true);
                }
            }
        }
        translate_z(board_dims.z+4+5.5/2){
            coloured_render("silver"){
                cube([164, 99, 5.5], center=true);
            }
        }
        translate_z(board_dims.z+4+5.5+3/2){
            coloured_render("#404040"){
                cube([164, 99, 3], center=true);
            }
        }
    }
}

module display_7inch_lcd_components(board_dims){
    rotate_y(180){

        chip(-160, 53, 3, 8, 3, "Silver");
        chip(-160, 53, 3.1, 7, 2.5);
        chip(-160, 54, 1.5, 1.5, 5);

        chip(-140, 80, 8, 4, 2, "WhiteSmoke");
        chip(-140, 78, 8, 1, 2.2);
        chip(-140, 73, 4, 12, 1);

        chip(-120, 48, 6.5, 3, 1.5);
        chip(-120, 60, 6.5, 3, 1.5);

        chip(-114, 26, 7, 7, 1.5);

        chip(-128, 29, 3.5, 10, 4, "Silver");

        chip(-95, 74, 20, 14, 1);

        chip(-61, 66, 3.5, 4.5, 1.5);
        chip(-60, 74, 3.5, 4.5, 1.5);

        chip(-48, 79, 2, 4, 2);

        chip(-42, 80, 4, 4, 1.5);
        chip(-32, 80, 4, 4, 1.5);

        chip(-32, 65, 4, 2, 2);
        chip(-32, 68, 4, 2, 2);
        chip(-32, 71, 4, 2, 2);

        chip(-82, 32, 25, 23, 1, "DarkGoldenrod");
        chip(-82, 45, 29, 4, 2, "WhiteSmoke");

        translate([-board_dims.x, board_dims.y]){
            translate_y(-30){
                rotate_z(-90){
                    micro_usb_socket();
                }
            }
            translate_y(-43){
                rotate_z(-90){
                    micro_usb_socket();
                }
            }
            translate_y(-12){
                rotate_z(-90){
                    hdmi_socket();
                }
            }
        }
    }
}

module motor28BYJ48_body(){
    holes = [[17.5, 0, 0], [-17.5, 0, 0]];
    translate_y(8){
        cylinder(d=28, h=19);
        difference(){
            hull(){
                for (hole = holes){
                    translate(hole){
                        cylinder(r=3.5, h=.8);
                    }
                }
            }
            for (hole = holes){
                translate(hole){
                    cylinder(r=2.1, h=3, center=true);
                }
            }
        }
    }
    //centered at height 3 so 1.5mm is exposed
    cylinder(d=9, h=3, center=true);
}

module motor28BYJ48_wo_wire(shaft_angle=0){
    coloured_render("silver"){
        motor28BYJ48_body();
    }
    coloured_render("goldenrod"){
        rotate_z(shaft_angle){
            intersection()
            {
                //centered at height 20 so 10mm is exposed
                cylinder(d=5, h=20, center=true);
                union(){
                    cube([10, 10, 8], center=true);
                    cube([10, 3, 99], center=true);
                }
            }
        }
    }
    coloured_render("RoyalBlue"){
        translate([-14.5/2, 8, 0.1]){
            cube([14.5, 17, 16.5]);
        }
        translate([-17.5/2, 8, 4.1]){
            cube([17.5, 14, 12.5]);
        }
    }
}

module motor_jst_socket(){
    coloured_render("WhiteSmoke"){
        difference(){
            translate_z(7/2){
                cube([15, 5.8, 7], center=true);
            }
            translate_z(7/2+2.5){
                cube([13.4, 4.2, 7], center=true);
            }
            for( x_tr = [-0.5, 0.5]*9.5){
                translate([x_tr, -2, 10/2+ 3]){
                    cube([1.25, 5, 10], center=true);
                }
            }
            translate([0, -2, 10/2+ 4]){
                cube([16, 1, 10], center=true);
            }
        }
    }
    coloured_render("Silver"){
        for (pin_num = [-2:2]){
            x_tr = pin_num*2.54;
            translate([x_tr, -1, 9.5/2-3]){
                cube([0.6, 0.6, 9.5], center=true);
            }
        }
    }
}

// z postion of connector when in socket
function motor_jst_connector_z() = 2.5;

module motor_jst_connector(){
    coloured_render("WhiteSmoke"){
        motor_jst_connector_body();
    }
    coloured_render("gray"){
        for (x_pin = [-2, -1, 0, 1, 2]*2.54){
            translate([x_pin, 0, 3.5]){
                cube([1.2, 3, 6], center=true);
            }
        }
    }
}

module motor_jst_connector_body(){
    difference(){
        union(){
            translate_z(7.7/2){
                cube([13.2, 4, 7.7], center=true);
            }
            translate([0, .7/2, 7.3]){
                cube([14.6, 4.7, 0.8], center=true);
            }
            // the "clip"
            jst_connector_clip();
        }
        translate_y(-1.6){
            cube([99, 4, .6], center=true);
        }
        for (x_pin = [-2, -1, 0, 1, 2]*2.54){
            translate_x(x_pin){
                jst_pin_void();
            }
        }
    }
}

module jst_connector_clip(){
    sequential_hull(){
        //x_gap is the space inside the clip in x
        x_gap = 8.6;
        //note everything is 1.0 in y and centred but it protrudes 0.8mm
        // Need to translate 2.8 in y to get this
        y_tr = -2.8;
        translate([x_gap/2, y_tr, 2]){
            cube([0.6, 1.6, 0.6]);
        }
        translate([x_gap/2, y_tr, 3.5]){
            cube([1.2, 1.6, 0.5]);
        }
        translate([x_gap/2, y_tr, 3.7]){
            cube([0.6, 1.6, 0.5]);
        }
        translate([x_gap/2, y_tr, 7.7-0.6]){
            cube([0.6, 1.6, 0.6]);
        }
        translate([-x_gap/2-0.6, y_tr, 7.7-0.6]){
            cube([0.6, 1.6, 0.6]);
        }
        translate([-x_gap/2-0.6, y_tr, 3.7]){
            cube([0.6, 1.6, 0.5]);
        }
        translate([-x_gap/2-1.2, y_tr, 3.5]){
            cube([1.2, 1.6, 0.5]);
        }
        translate([-x_gap/2-0.6, y_tr, 2]){
            cube([0.6, 1.6, 0.6]);
        }
    }
}

module jst_pin_void(){
        translate_y(2){
            cube([1.2, 2, 6], center=true);
        }
        translate_z(6){
            cube([2, 2.8, 10], center=true);
        }
        translate([0, .5, 6]){
            cube([1.2, 2.8, 10], center=true);
        }
        translate_y(-.7){
            cube([1, 1, 10], center=true);
        }
}


module motor28BYJ48_wire(m_pos, c_pos, m_pin, c_pin, points=[]){
    wire_start_m = [2, 17, 2.5];
    wire_end_m = [2, 27, 2.5];
    wire_pitch_m = [1, 0, 0];
    pin_tr_m = (m_pin-1)*(-wire_pitch_m);

    wire_start_c = [5.08, -.7, 6];
    wire_end_c = [2, -.7, 14];
    wire_pitch_cs = [2.54, 0, 0];
    wire_pitch_ce = [1, 0, 0];
    pin_tr_cs = (c_pin-1)*(-wire_pitch_cs);
    pin_tr_ce = (c_pin-1)*(-wire_pitch_ce);

    //wire near motor
    place_part(m_pos){
        hull(){
            translate(wire_start_m+pin_tr_m){
                sphere(d=1, $fn=10);
            }
            translate(wire_end_m+pin_tr_m){
                sphere(d=1, $fn=10);
            }
        }
    }
    //wire connector motor
    place_part(c_pos){
        hull(){
            translate(wire_start_c+pin_tr_cs){
                sphere(d=1, $fn=10);
            }
            translate(wire_end_c+pin_tr_ce){
                sphere(d=1, $fn=10);
            }
        }
    }
    //the rest of the wire
    //can reduce this block of code if there was a way to create a
    // pacement dictionary where the part is tranlated before the placement is applied
    // This requires function with a lot of algebra
    if (len(points) == 0){
        hull(){
            place_part(m_pos){
                translate(wire_end_m+pin_tr_m){
                    sphere(d=1, $fn=10);
                }
            }
            place_part(c_pos){
                translate(wire_end_c+pin_tr_ce){
                    sphere(d=1, $fn=10);
                }
            }
        }
    }
    else{
        w_points = calc_bundled_wire_points(5, m_pin, points);
        hull(){
            place_part(m_pos){
                translate(wire_end_m+pin_tr_m){
                    sphere(d=1, $fn=10);
                }
            }
            translate(w_points[0]){
                sphere(d=1, $fn=10);
            }
        }
        if (len(w_points) > 1){
            wire(d=1, points=w_points);
        }
        hull(){
            translate(w_points[len(w_points)-1]){
                sphere(d=1, $fn=10);
            }
            place_part(c_pos){
                translate(wire_end_c+pin_tr_ce){
                    sphere(d=1, $fn=10);
                }
            }
        }
    }
}

function calc_bundled_wire_points(n_wires, wire_num, points) = let(
    off_x = cos(360*wire_num/n_wires),
    off_y = sin(360*wire_num/n_wires)
)[
    for (point = points)
        if (len(point)==3)
            point + [off_x, off_y, 0]
        else
            let(
                beta = point[3],
                gamma = point[4],
                x = point[0] + cos(beta)*cos(gamma)*off_x - sin(beta)*off_y,
                y = point[1] + sin(beta)*cos(gamma)*off_x + cos(beta)*off_y,
                z = point[2] + sin(gamma)*off_x
            )  [x, y, z]
];


module motor28BYJ48(motor_pos, connector_pos, wire_points=[], mirror_connector=false, shaft_angle){
    $fn=32;
    m_pos = is_undef(motor_pos) ? create_placement_dict([0, 0, 0]) : motor_pos;
    c_pos = is_undef(connector_pos) ? create_placement_dict([0, 280, 0], [90, 0, 0]) : connector_pos;
    place_part(m_pos){
        motor28BYJ48_wo_wire(shaft_angle=shaft_angle);
    }
    place_part(c_pos){
        if (mirror_connector){
            mirror([0, 1, 0]){
                motor_jst_connector();
            }
        }
        else {
            motor_jst_connector();
        }
    }

    coloured_render("Orange"){
        motor28BYJ48_wire(m_pos, c_pos, 1, 4, wire_points);
    }
    coloured_render("Yellow"){
        motor28BYJ48_wire(m_pos, c_pos, 2, 3, wire_points);
    }
    coloured_render("Red"){
        motor28BYJ48_wire(m_pos, c_pos, 3, 5, wire_points);
    }
    coloured_render("Blue"){
        motor28BYJ48_wire(m_pos, c_pos, 4, 1, wire_points);
    }
    coloured_render("Magenta"){
        motor28BYJ48_wire(m_pos, c_pos, 5, 2, wire_points);
    }
}

//board only ever centres in xy
module filleted_board(size, r=2, center=false){

    x_tr1 = center ? size.x/2-r : r;
    x_tr2 = center ? -(size.x/2-r) : size.x-r;
    y_tr1 = center ? size.y/2-r : r;
    y_tr2 = center ? -(size.y/2-r) : size.y-r;
    hull(){
        translate([x_tr1, y_tr1, 0]){
            cylinder(r=r, h=size.z);
        }
        translate([x_tr1, y_tr2, 0]){
            cylinder(r=r, h=size.z);
        }
        translate([x_tr2, y_tr1, 0]){
            cylinder(r=r, h=size.z);
        }
        translate([x_tr2, y_tr2, 0]){
            cylinder(r=r, h=size.z);
        }
    }
}

module wire(d=1, points=[[0, 0, 0], [10,0,0]]){
    $fn=10;
    for(i=[0:len(points)-2]){
        hull(){
            translate(points[i]){
                sphere(d=d);
            }
            translate(points[i+1]){
                sphere(d=d);
            }
        }
    }
}

// This function takes a list of 3D points, and returns
// an identically-sized list of unit vectors, which are
// orthogonal to the lines joining each point to its
// next and previous points
// i.e. they are normalised cross products of
// (p[i] - p[i-1]) cross (p[i+1] - p[i])
function unit_vectors_perpendicular_to_segments(points, first=undef, last=undef) = let(
    middle_points = [
        for (i=[1:(len(points)-2)])
            let(x=cross(points[i] - points[i-1], points[i+1] - points[i])) 
                x/norm(x)
    ]
) [
    is_undef(first) ? middle_points[0] : first,
    each middle_points,
    is_undef(last) ? middle_points[len(middle_points)-1] : last
];

// This function takes a list of 3D points, and returns
// a list of 3D points, offset in the direction orthogonal 
// to the lines joining each point to its next and previous points.
// The offset distance is set to make ribbon cables with n wires at 
// separation d, for a wire in the ribbon position set by index.
// index is zero-referenced.
// The last point in the list can be separated by a different distance 
// connector_d, to spread the wires out into a connector.
// The connector angle can be set as connector_vector.
function flat_wire_points(d=1, points=[], n=2, index=0, connector_d, connector_vector) = let(
    np=len(points),
    conn_d = is_undef(connector_d)? d : connector_d,
    each_d = [ for (i=[0:(np-2)]) d , conn_d],
    base_unit_vecs = unit_vectors_perpendicular_to_segments(points),
    conn_unit_vec = is_undef(connector_vector)? base_unit_vecs[np-1] : connector_vector,
    units = [ for (i=[0:(np-2)]) base_unit_vecs[i] , conn_unit_vec],
    out_points = [
        for (i=[0:(np-1)])
            let(p=points[i] + (index - (n-1)/2)*each_d[i] * units[i]) 
                p
    ]
 ) out_points;

module ribbon_cable(width, positions){
    
    for (i = [0:len(positions)-2]){
        hull(){
            place_part(positions[i]){
                cube([0.5, width, 0.5], center=true);
            }
            place_part(positions[i+1]){
                cube([0.5, width, 0.5], center=true);
            }
        }
    }
}

// A rough sketch of a dupont-style 2.54mm pitch housing
module dupont_connector_housing(columns=1, rows=1, center=true){
    pitch = 2.54;
    width = columns*pitch;
    height = rows*pitch;
    x = center ? -width/2 : -pitch/2;
    y = center ? -height/2 : -pitch/2;
    coloured_render("DimGray"){
        difference(){
            translate([x, y, 0]){
                cube([width, height, 10]);
            }

            // Roughly cut out holes for the wires
            repeat([pitch, 0, 0], columns, center=center){
                repeat([pitch, 0, 0], rows, center=center){
                    cube([1.2, 1.2, 8], center=true);
                }
            }
        }
    }
}

//Micro SD card
module micro_sd_card(){
    coloured_render("DimGray"){
        micro_sd_card_profile();
        //add ridge
        intersection(){
            translate_z(0.3){
                micro_sd_card_profile();
            }
            translate_y(-(30-1.84)){
                cylinder(r=30, h=2, $fn=64);
            }
        }
    }
    coloured_render("WhiteSmoke"){
        translate([2, 3, 0.61]){
            rotate_z(90){
                linear_extrude(.1){
                    resize([10,0],auto=true){
                        import("logos/MicroSD-Logo.dxf");
                    }
                }
            }
        }
    }
    //contacts
    coloured_render("Gold"){
        translate([-0.7/2, 11, -tiny()]){
            for( i = [0:7]){
                translate_x(1.1*(i-3.5)){
                    y_size = (i==2 || i==4) ? 3.2 : 2.9;
                    cube([0.7, y_size, .1]);
                }
            }
        }
    }
}

//Outer profile of the micro_sd card without the raised rodge at the back
module micro_sd_card_profile(){
    corner_r = 0.8;
    sm_corner_r = 0.2;
    t = 0.7;
    length = 15;
    full_width = 11;
    front_width = 9.7;
    //main rectangle
    hull(){
        for (x_tr = [-.5, .5]*(front_width-2*corner_r)){
            for (y_tr = [corner_r, length-corner_r]){
                translate([x_tr, y_tr]){
                    cylinder(r=corner_r, h=t, $fn=16);
                }
            }
        }
    }
    //bump on side
    difference(){
        hull(){
            translate([0, corner_r]){
                cylinder(r=corner_r, h=t, $fn=8);
            }
            translate([full_width-front_width/2-corner_r, corner_r]){
                cylinder(r=corner_r, h=t, $fn=16);
            }
            translate([full_width-front_width/2-sm_corner_r, 8.6]){
                cylinder(r=sm_corner_r, h=t, $fn=8);
                translate([-3, 3]){
                cylinder(r=sm_corner_r, h=t, $fn=8);
                } 
            }
        }
        // bump cutout
        hull(){
            translate([full_width-front_width/2+sm_corner_r, 7.1-sm_corner_r, -tiny()]){
                cylinder(r=sm_corner_r, h=2*t, $fn=8);
                translate_x(-0.7){
                    cylinder(r=sm_corner_r, h=2*t, $fn=8);
                }
                translate([-0.7, -1.2]){
                    cylinder(r=sm_corner_r, h=2*t, $fn=8);
                    translate([3, -3]){
                        cylinder(r=sm_corner_r, h=2*t, $fn=8);
                    }
                }
            }
        }
    }
}