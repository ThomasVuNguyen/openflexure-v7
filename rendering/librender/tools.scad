use <../../openscad/libs/utilities.scad>
use <render_utils.scad>

allen_key_2_5();

module allen_key_2_5(angle=0, clockwise_arrow=false, anticlockwise_arrow=false){
    //Divide distance accross hexagon by 0.866 to get diameter
    // to produce the hexagon with $fn=6
    diameter = 2.5/0.866;
    rotate_y(angle){
        translate([-3.5, 107, 0]){
            coloured_render("#404040"){
                rotate_extrude(angle=90, $fn=60){
                    translate_x(3.5){
                        circle(d=diameter, $fn=6);
                    }
                }
                translate_y(3.5){
                    rotate_y(-90){
                        rotate_z(30){
                            cylinder(d=diameter, h=14, $fn=6);
                        }
                    }
                }
                translate_x(3.5){
                    rotate_x(90){
                        cylinder(d=diameter, h=104, $fn=6);
                    }
                }
                translate([3.5, -107, 0]){
                    allen_ball(diameter);
                }
            }
        }
    }
    if (clockwise_arrow){
        translate_y(112){
            rotate_x(-90){
                turn_clockwise(20, 5);
            }
        }
    }
    if (anticlockwise_arrow){
        translate_y(112){
            rotate_x(-90){
                turn_anticlockwise(20, 5);
            }
        }
    }
}

module allen_ball(diameter){
    hull(){
        for (angle = [0, 60, 120]){
            rotate_y(angle){
                rotate_extrude($fn=60){
                    difference(){
                        circle(d=diameter, $fn=6);
                        translate([-10,-5]){
                            square([10,10]);
                        }
                    }
                }
            }
        }
    }
    sequential_hull(){
        translate_y(0.8){
            rotate_x(90){
                cylinder(d=diameter, h=.8, $fn=6);
            }
        }
        translate_y(1.6){
            rotate_x(90){
                cylinder(d=diameter/1.5, h=.1, $fn=6);
            }
        }
        translate_y(3){
            rotate_x(90){
                cylinder(d=diameter, h=.1, $fn=6);
            }
        }
    }
}

module oil_bottle(){
    bottle_size = [50, 25, 60];
    nozzle_height = 22;
    neck_d=15;
    translate_z(-bottle_size.z-nozzle_height){
        coloured_render("DarkGreen"){
            outer_oil_bottle(bottle_size, neck_d=neck_d);
        }
        coloured_render("Red"){
            translate_z(bottle_size.z-tiny()){
                cylinder(d1=neck_d-1, d2=neck_d-2, h=5);
                cylinder(d1=4.5, d2=3, h=nozzle_height);
            }
        }
        rotate_z(180){
            coloured_render("White"){
                translate([0, -bottle_size.y/2-tiny(), bottle_size.z*.4]){
                    rotate_x(90){
                        linear_extrude(2*tiny()){
                            text("OIL",
                                size=10,
                                font="Sans",
                                halign="center",
                                valign="bottom");
                        }
                    }
                }
            }
        }
    }
}

module outer_oil_bottle(size, rad = 5, neck_d=15){
    abs_x_tr = size.x/2-rad;
    x_trs = [-abs_x_tr, abs_x_tr];
    abs_y_tr = size.y/2-rad;
    y_trs = [-abs_y_tr, abs_y_tr];
    hull(){
        for (x_tr = x_trs, y_tr = y_trs){
            translate([x_tr, y_tr, 0]){
                cylinder(r=rad, h=size.z-5, $fn=12);
            }
            
        }
        cylinder(d=neck_d, h=size.z, $fn=30);
    }
}