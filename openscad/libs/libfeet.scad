/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope Feet                         *
*                                                                 *
* This file generates the feet for the microscope                 *
*                                                                 *
* Each foot sits under one actuator column, and clips in with     *
* lugs either side.  They have hooks in the bottom to hold the    *
* elastic bands and stops to limit the lower travel of the stage. *
*                                                                 *
* (c) Richard Bowman, January 2017                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
* http://www.github.com/rwb27/openflexure_microscope              *
* http://www.docubricks.com/projects/openflexure-microscope       *
* http://www.waterscope.org                                       *
*                                                                 *
******************************************************************/

use <./microscope_parameters.scad>
use <./utilities.scad>
use <./libdict.scad>
use <./compact_nut_seat.scad>

module foot_ground_plane(tilt=0, top=0, bottom=-999){
    //This represents where the ground would be, given that the
    //foot is usually printed tilted, pivoting around it's +y edge
    //As printed, the ground plane is the print bed, i.e. z=0
    //However, the foot is used in a different orientation, tilted
    //around the outer edge (so the microscope sits on the outer
    //edges of the feet).
    //NB top and bottom refer to distances in the model frame, so
    //they will be slightly smaller Z shifts in the printer frame.
    //top or bottom=0 places the plane on the print bed, which is
    // z=l/2*tan(tilt) in the foot frame (as it's tilted about one
    // corner).
    translate_z(bottom){
        skew_flat(tilt, true){
            cylinder(r=999,h=top-bottom,$fn=8);
        }
    }
}
module skew_flat(tilt, shift=false){
    // This transformation skews a plane so it's parallel to the print bed, in
    // the foot (which has been rotated by an angle `tilt`).  Z coordinates are
    // unchanged by this transform; it's a skew **not** a rotation.
    // if shift is true, move things up so that z=0 corresponds to the print
    // bed.  Otherwise, z=0 is below the bottom of the foot (because z=0 is
    // touched by the edge of the foot in the unskewed frame - and the skew will
    // move that side of the model downwards.  It's all because we rotate the
    // model about the corner, rather than the centre...
    l = actuator_housing_xy_size().y;
    z_shift = shift ? l/2*tan(tilt) : 0;

    skew_matrix = [[1, 0, 0, 0],
                   [0, 1, 0, 0],
                   [0, tan(-tilt), 1, z_shift],
                   [0, 0, 0, 1]];

    multmatrix(skew_matrix){
        children();
    }
}


module filleted_bridge(gap, roc_xy=2, roc_xz=2){
    // This can be subtracted from a structure of width gap.x to form
    // a hole in the bottom of the object with rounded edges.
    // It's used here to smooth the band anchor to avoid damaging the bands.
    w = gap.x;
    b = gap.y;
    h = gap.z;
    x1 = w/2 - roc_xy;
    x2 = w/2 - roc_xz;
    y1 = b/2 + roc_xy;
    difference(){
        translate(-zero_z(gap)/2 -[0,roc_xy,999]){
            cube(gap + [0,2*roc_xy,roc_xz] + [0,0,999]);
        }
        reflect_y(){
            sequential_hull(){
                reflect_x(){
                    translate([x1, y1, -999]){
                        cylinder(r=roc_xy, h=tiny());
                    }
                }
                reflect_x(){
                    translate([x1, y1, 0]){
                        cylinder(r=roc_xy, h=h+roc_xz);
                    }
                }
                reflect_x(){
                    translate([x2, b/2, h+roc_xz]){
                        rotate_x(-90){
                            cylinder(r=roc_xz, h=tiny());
                        }
                    }
                }
                reflect_x(){
                    translate([x2, -2*tiny(), h+roc_xz]){
                        rotate_x(90){
                            cylinder(r=roc_xz ,h=tiny());
                        }
                    }
                }
            }
        }
    }
}

// This is used to create long tilted extrusions.
// The direction of extrusion can be at an angle that is not perpendicular to
// the section.
// The end faces of the extrusion can be tilted with respect to the xy plane
//
// This is used in the creation of the feet
//
// This module takes a child module, cuts it a tiny bit above z=0.
// This cut is extruded along the extrusion angle
// Only a section of this is returned which extends from the input
// `z` up by a height h. The angle this section is cut
// can be tilted independently  by `section_angle`.
module angled_extrude(extrude_angle=0, //the angle of extrusion relative to the Z axis
                      section_angle=0, //the angle between the end faces and the XY plane
                      offset=0,        //grow the section by this much in XY plane
                      h=tiny(),        //thickness
                      z=0){
    assert(h<=999, "Maximum h for foot section is 999");
    intersection(){
        translate_z(z){
            rotate_x(section_angle){
                cube([999,999,h],center=true);
            }
        }
        rotate_x(extrude_angle){
            // This is set to 1000 so that numbers up to 999 can be put into h
            offset_thick_section(h=1000, center=true, offset=offset){
                children();
            }
        }
    }
}

module foot_letter(letter="", actuator_tilt=0, h=10, base_cleareance=2){
    //To add a letter to the side of the foot.
    //For letters that got below the line, base clearance may need increasing

    //Calculate the y and z position in the tilted frame
    y_tr_tilted_frame = actuator_housing_xy_size().y/2-.5;
    z_tr_tilted_frame = -y_tr_tilted_frame*tan(actuator_tilt) + h/2 + base_cleareance;

    // y and z position in the untilted frame
    y_tr = y_tr_tilted_frame*cos(actuator_tilt)-z_tr_tilted_frame*sin(actuator_tilt);
    z_tr = y_tr_tilted_frame*sin(actuator_tilt)+z_tr_tilted_frame*cos(actuator_tilt);

    translate([0, y_tr, z_tr]){
        rotate_x(actuator_tilt){
            rotate_z(180){
                rotate_x(90){
                    translate([-h/2,-h/2,0]){
                        linear_extrude(1){
                            text(letter,10);
                        }
                    }
                }
            }
        }
    }
}

module foot(params,
            travel=5,       // how far into the foot the actuator can move down
            bottom_tilt=0,  // the angle of the bottom of the foot
            hover=0,        // distance between the foot and the ground
            actuator_tilt=0,// the angle of the top of the foot
            lie_flat=true,
            letter=""){
    $fn=32;
    // The feet sit at the bottoms of the actuator columns.  Their main
    // function is to anchor the Viton bands and provide downward force.

    w = actuator_housing_xy_size().x; //size of the outside of the screw seat column
    l = actuator_housing_xy_size().y;
    cw = column_core_size().x; //size of the inside of the screw seat column
    wall_t = (w-cw)/2; //thickness of the wall
    foot_height = key_lookup("foot_height", params);
    h = foot_height - hover; //defined in parameters.scad, set hover=2 to not touch ground, useful for the middle foot.
    tilt = bottom_tilt - actuator_tilt; //the angle of the ground relative to the axis of the foot
    // The following transforms will either make the foot "in place" (i.e. the top is z=0) or
    // printable (i.e. with the bottom on z=0).

    y_tr_flat = l/2*tan(tilt)*sin(actuator_tilt);
    y_tr_tilted = h*tan(actuator_tilt);
    y_tr = lie_flat ? y_tr_flat : y_tr_tilted;
    translate_y(y_tr){
        //the foot base may be tilted, lie_flat makes this z=0
        rotate_x(lie_flat ? tilt : 0){
            //makes the bottom z=0
            translate_z(lie_flat ? -l/2*tan(tilt) : -h){
                union(){
                    difference(){
                        union(){
                            angled_extrude(actuator_tilt, 0, h=2*h){
                                //main part of foot
                                screw_seat_shell();
                            }
                            angled_extrude(actuator_tilt, 0, h=2*h+3){
                                //lugs on top
                                nut_seat_void();
                            }
                        }
                        //hollow out the inside
                        difference(){
                            //the core tapers at the top to support the lugs
                            sequential_hull(){
                                angled_extrude(actuator_tilt, 0, z=-99){
                                    nut_seat_void();
                                }
                                angled_extrude(actuator_tilt, 0, z=h-4){
                                    nut_seat_void();
                                }
                                angled_extrude(actuator_tilt, 0, offset=-wall_t, z=h){
                                    nut_seat_void();
                                }
                                angled_extrude(actuator_tilt, 0, offset=-wall_t, z=99){
                                    nut_seat_void();
                                }
                            }
                            //we double-subtract the anchor for the bands at the bottom, so that it
                            //doesn't protrude outside the part.
                            cube([2*column_base_radius()+1.5, 999, 2*(h-travel-0.5)],center=true);
                        }
                        //cut out the core again, without tapering, in the middle to make four lugs,
                        //two on either side - rather than a ring around the top. The gap between the lugs allows
                        //the band tool to spread to give more space for the band. 
                        intersection(){
                            rotate_x(actuator_tilt){
                                cube([cw-5*2, 999, 999], center=true);
                                cube([999,6.5,999], center=true);
                            }
                            angled_extrude(actuator_tilt, 0, h=99, z=99/2+h-travel-0.5){
                                nut_seat_void();
                            }
                        }

                        //cut out the shell close to the microscope centre to allow the actuator
                        //to protrude below the bottom of the body
                        difference(){
                            rotate_x(actuator_tilt){
                                translate([0,-l/2,h-travel-0.5]){
                                    cube([actuator_entry_width(), wall_t*3, 999], center=true);
                                }
                            }
                            //NOTE: We do not cut all the way through the foot. This is to keep the foot strong.
                            foot_ground_plane(tilt=0, top=h-travel-0.5);
                        }


                        //round the edges of the above slot, and make an actual hole (i.e. no adhesion
                        //layer) for the elastic bands to sit in.  Rounded edges should help strength
                        //and avoid damaging the bands.
                        //NOTE: width should match the band anchor above,
                        //and height/span should match the slot above.
                        skew_flat(bottom_tilt){
                            rotate_x(actuator_tilt){
                                translate_z(h-travel-4-2){
                                    filleted_bridge([2*column_base_radius()+1.5, 4, 2], roc_xy=4, roc_xz=3);
                                }
                            }
                        }
                        //cut off the foot below the "ground plane" (i.e. print bed)
                        foot_ground_plane(tilt, top=0);

                    }
                    foot_letter(letter,actuator_tilt);
                }
            }
        }
    }
}


module middle_foot(params, lie_flat=false,letter="Z"){
        foot(params,
             travel=z_actuator_travel(params),
             bottom_tilt=0,
             actuator_tilt=z_actuator_tilt(params),
             hover=2,
             lie_flat=lie_flat,
             letter=letter);
}

module outer_foot(params, lie_flat=false,letter=""){
    foot(params,
         travel=xy_actuator_travel(params),
         bottom_tilt=15,
         lie_flat=lie_flat,
         letter=letter);
}


module foot_cap(){
    $fn=32;
    radius = actuator_housing_xy_size().y/2;
    sep = actuator_housing_xy_size().x - 2*radius - 0.1;
    clip_radius = radius-actuator_wall_t()-0.05;

    // Body of the cap
    hull(){
        for (x_tr = [-sep/2, sep/2]){
            translate_x(x_tr){
                cylinder(r=radius, h=1);
                cylinder(r=radius-2, h=3);
            }
        }
    }
    // Clips
    reflect_x(){
        translate([-sep/2, 0, -3]){
            difference(){
                // Create a cylinder
                cylinder(r=clip_radius, h=4);
                // Cut cylinder into a pie wedge shape
                reflect_y(){
                    rotate_z(-60){
                        translate_y(25){
                            cube([50, 50, 50], center=true);
                        }
                    }
                }
                // Cut pie wedge into a pie crust
                cylinder(r=clip_radius-1, h=10, center=true);
                cube([50,5,10], center=true);
            }
        }
    }
}