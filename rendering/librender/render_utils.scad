use <../../openscad/libs/microscope_parameters.scad>
use <../../openscad/libs/libdict.scad>
use <../../openscad/libs/utilities.scad>

module construction_line(p1, p2, width=0.1, line_color="Black", arrow=false){
    //draws a construction line between two points. Inputs can be x,y,z list or placement dictionary

    //If placment dictionaries are used then recall using vector
    p1_dict = valid_dict(p1) ? p1 : create_placement_dict(p1);
    p2_dict = valid_dict(p2) ? p2 : create_placement_dict(p2);
    
    color(line_color){
        hull(){
            place_part(p1){
                cube([width, width, width], center=true);
            }
            place_part(p2){
                cube([width, width, width], center=true);
            }
        }
        if (arrow){
            place_part(p2){
                cylinder(d1=11*width, d2=tiny(), h=16*width, center=true);
            }
        }
    }
}

module construction_line_dashed(p1, p2, width=0.1, line_color="Black", dash_period=5){
    vec = p2 - p1;
    vec_length = norm(vec);
    unit_vec = vec / vec_length;
    n = floor(vec_length/dash_period);
    dash_length = dash_period * 0.6;
    translate(p1){
        for (i=[0:n-1]){
            translate(unit_vec*dash_period*i){
                construction_line([0,0,0], unit_vec*dash_length, width=width, line_color=line_color, arrow=false);
            }
        }
    }
    extra = vec_length - (n * dash_period);
    translate(p2){
        construction_line([0,0,0], -unit_vec*extra, width=width, line_color=line_color, arrow=false);
    }
}

module turn_anticlockwise(rad = 5, head = 2.5, line_w=0.1){
    color("black"){
        rotate_extrude(angle=270, $fn=80){
            translate_x(rad){
                circle(r = line_w);
            }
        }
        translate_y(-rad){
            rotate_y(90){
                cylinder(d1=head*2/3, d2=0.01, h=head, $fn=80);
            }
        }
    }
}

module circle_label(rad = 5, line_w=0.1, line_color="red"){
    color(line_color){
        rotate_extrude(angle=360, $fn=80){
            translate_x(rad){
                circle(r = line_w);
            }
        }
    }
}

module turn_clockwise(rad = 5, head = 2.5, line_w=0.1){
    mirror([0, 1, 0]){
        turn_anticlockwise(rad, head, line_w);
    }
}


function create_placement_dict(translation=[0,0,0],
                               rotation3=[0,0,0],
                               rotation2=[0,0,0],
                               rotation1=[0,0,0],
                               init_translation=[0,0,0]) = [["translation", translation],
                                                            ["rotation3", rotation3],
                                                            ["rotation2", rotation2],
                                                            ["rotation1", rotation1],
                                                            ["init_translation", init_translation]];

function translate_pos(placement_dict, translation) = let(
    tr = key_lookup("translation", placement_dict) + translation
) replace_value("translation", tr, placement_dict);

module place_part(position){
    if (valid_dict(position)){
        // Places part in 3D space
        // input is a dictionary with keys translation, rotation3, rotation2, rotation1, translation
        // These will be applied in order allowing full ridgidbody rotation before translation
        tr = key_lookup("translation", position);
        r1 = key_lookup("rotation1", position);
        r2 = key_lookup("rotation2", position);
        r3 = key_lookup("rotation3", position);
        init_tr = key_lookup("init_translation", position);
        translate(tr){
            rotate(r3){
                rotate(r2){
                    rotate(r1){
                        translate(init_tr){
                            children();
                        }
                    }
                }
            }
        }
    }
    else{
        translate(position){
            children();
        }
    }
}

module coloured_render(colour="Red", alpha=1.0, convexity=6){
    color(colour, alpha){
        render(convexity){
            children();
        }
    }
}

module cutaway(dir="+x", colour="Red"){
    if (dir == "none"){
        coloured_render(colour){
            children();
        }
    }
    else{
        rotations = [["x", [0, 90, 0]],
                    ["+x", [0, 90, 0]],
                    ["-x", [0, -90, 0]],
                    ["y", [-90, 0, 0]],
                    ["+y", [-90, 0, 0]],
                    ["-y", [90, 0, 0]],
                    ["+xy", [0,90,135]],
                    ["-xy",[0,90,-45]],
                    ["z", [0, 0, 0]],
                    ["+z", [0, 0, 0]],
                    ["-z", [0, 180, 0]]];
        rotation = key_lookup(dir, rotations);
        coloured_render(colour){
            difference(){
                children();
                rotate(rotation){
                    cylinder(r=999,h=999,$fn=4); //cutaway
                }
            }
        }
    }
}
