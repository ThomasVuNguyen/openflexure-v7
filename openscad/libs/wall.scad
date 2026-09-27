/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Microscope body wall                    *
*                                                                 *
* This defines utility functions to create the "wall" around the  *
* main body of the microscope.                                    *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/
use <./utilities.scad>
use <./main_body_transforms.scad>
use <./compact_nut_seat.scad>
use <./microscope_parameters.scad>
use <./libdict.scad>

module add_hull_base(h=1){
    // Take the convex hull of some objects, and add it in as a
    // thin layer at the bottom
    union(){
        intersection(){
            hull(){
                children();
            }
            cylinder(r=999, $fn=8, h=h); //make the base thin
        }
        children();
    }
}
module add_roof(inner_h){
    // Take the convex hull of some objects, and add the top
    // of it as a roof.  NB you must specify the height of
    // the underside of the roof - finding it automatically
    // would be too much work...
    union(){
        difference(){
            hull(){
                children();
            }
            cylinder(r=999, $fn=8, h=inner_h);
        }
        children();
    }
}
module wall_vertex(r=undef, h=undef, x_tilt=0, y_tilt=0){
    // A cylinder, rotated by the given angles about X and Y,
    // but with the top and bottom kept in the XY plane
    // (i.e. it's sheared rather than tilted).    These form the
    // stiffening "wall" that runs around the base of
    // the legs
    radius = if_undefined_set_default(r, microscope_wall_t()/2);
    height = if_undefined_set_default(h, actuator_wall_h());
    sparse_matrix_transform(xz=tan(y_tilt), yz=-tan(x_tilt)){
        cylinder(r=radius, h=height, $fn=8);
    }
}

module inner_wall_vertex(params, leg_angle, x, h, thick=false){
    // A thin cylinder, close to one of the legs.  It
    // tilts inwards to clear the leg.  These form the
    // corners of the stiffening "wall" that runs around
    // the base of the legs

    // leg_angle specifies which leg the wall is for
    // (the legs are at +/-45 and +/-150 deg)
    // x is the X position before rotation through leg_angle
    // h is the wall height.
    // If thick = true then the wall is double thickness.

    // unless specified, tilt the leg so the wall at the
    // edge is vertical (i.e. the bit at 45 degrees to
    // the leg frame)
    y_tilt = x>0?6:-6;
    r = thick ? microscope_wall_t() : microscope_wall_t()/2;
    y=-flex_dims().y-r;

    leg_frame(params, leg_angle){
        translate([x,y,0]){
            wall_vertex(r=r,h=h,x_tilt=6,y_tilt=y_tilt);
        }
    }
}

module inner_wall_base_corner(params, leg_angle, x, y_inset){
    // This is a 2D circle at the base of the angled cylinders that 
    // are defined by inner_wall_vertex().
    // It is used to define the central optics cut-out under the stage.

    // leg_angle specifies which leg the wall is for
    // (the legs are at +/-45 and +/-150 deg)
    // x is the X position before rotation through leg_angle
    // h is the wall height.
    // If thick = true then the wall is double thickness.
    r = microscope_wall_t()/2;
    leg_r = key_lookup("leg_r", params);
    rotate_z(leg_angle){
        translate([x, leg_r-y_inset, 0]){
            circle(r=r, $fn=6);
        }
    }
}

module z_bridge_wall_vertex(params){
    // This is the vertex of the "inner wall" nearest the
    // new (cantilevered) Z axis.
    inner_wall_vertex(params, 45, leg_outer_w(params)/2+microscope_wall_t()/2, inner_wall_h(params));
}

function mounting_lug_wall_vertex_position(params) = [-back_lug_x_pos(params)-microscope_wall_t()/2, -microscope_wall_t()/2, 0];

function outer_wall_tilt(params) = atan(microscope_wall_t()/inner_wall_h(params));

module mounting_lug_wall_vertex(params){
    // This is the vertex of the supporting wall nearest
    // to the Z anchor - it doesn't make sense to use the
    // function above as it's got the wrong symmetry.
    // We also use this in a few places so it's worth saving
    //this is on the y_side it is reflected for the z_side
    translate(mounting_lug_wall_vertex_position(params)){
        wall_vertex(h=inner_wall_h(params), y_tilt=outer_wall_tilt(params));
    }
}


function y_actuator_wall_vertex_position(params, inside=true) = let(
    tansverse_distance = actuator_housing_xy_size().x/2 - microscope_wall_t()/2,
    x_sign = inside? 1 : -1
) y_actuator_pos(params) + [x_sign, x_sign, 0]*tansverse_distance/sqrt(2);

module y_actuator_wall_vertex(params, inside=true){
    // A wall vertex for the y actuator.  x=-1,1 picks the side
    // of the actuator where the vertex is placed.
    y_tilt = inside ? 0 : outer_wall_tilt(params);
    translate(y_actuator_wall_vertex_position(params, inside)){
        wall_vertex(y_tilt=y_tilt);
    }
}

module z_actuator_wall_vertex(params, front=true){
    if (front){
        y_tr = z_nut_y(params)+actuator_housing_xy_size().y/2-microscope_wall_t()/2;
        translate_y(y_tr){
            wall_vertex();
        }
    }
    else{
        x_tr = -(z_anchor_w()/2+microscope_wall_t()/2+1);
        y_tr = z_anchor_y() + 1;
        translate([x_tr, y_tr, 0]){
            wall_vertex();
        }
    }
}

// The "wall" that forms most of the microscope's structure
module wall_inside_xy_stage(params){

    // First, go around the inside of the legs, under the stage.
    // This starts at the Z nut seat.  I've split it into two
    // blocks, because the shape is not convex so the base
    // would be bigger than the walls otherwise.
    reflect_x(){
        sequential_hull(){
            mirror([1,0,0]){
                z_bridge_wall_vertex(params);
            }
            wall_h = inner_wall_h(params);
            //radius on which wall sits.
            wall_rad = leg_outer_w(params)/2;
            wall_rad_thick = leg_outer_w(params)/2-microscope_wall_t()/2;
            z_bridge_wall_vertex(params);
            inner_wall_vertex(params, 45, -wall_rad, wall_h);
            mounting_lug_wall_vertex(params);
            inner_wall_vertex(params, 135, wall_rad, wall_h);
            //The wall that has the reflection illumination cut-out is double
            //thickness to improve stiffness
            inner_wall_vertex(params, 135, -wall_rad_thick, wall_h, thick=true);
            inner_wall_vertex(params, -135, wall_rad_thick, wall_h, thick=true);
        }
    }
}

module wall_outside_xy_actuators(params){
    // Add the wall from the XY actuator column to the middle
    sequential_hull(){
        mounting_lug_wall_vertex(params);
        // anchor at the same angle on the actuator
        // NOTE: the base of the wall is outside the base of the
        // actuator housing
        y_actuator_wall_vertex(params, inside=false);
    }
}

module wall_inside_xy_actuators(params){
    // Connect the Z anchor to the XY actuators
    hull(){
        z_actuator_wall_vertex(params, front=false);
        y_actuator_wall_vertex(params);
    }
}

module wall_between_actuators(params, y_actuator=true){
    // link the actuators together
    if (y_actuator){
        hull(){
            y_actuator_wall_vertex(params);
            z_actuator_wall_vertex(params, front=true);
        }
    }
    else{
        //for the x actuator wall mirror the same function
        mirror([1,0,0]){
            wall_between_actuators(params);
        }
    }
}

module central_optics_cut_out_projection(params) {
    // A 2D shape for the central cut-out for the optics. 
    // The form is based on wall_inside_xy_stage(), stepped in to leave a strengthening flange

    // First, go around the inside of the legs, under the stage.
    // This starts at the Z nut seat. 

    // A 'zero' inset is needed to get from the position of the inner corners of the legs to just inside the walls.
    inset_zero = flex_dims().y + microscope_wall_t()*2;
    // a small flange inset from the wall by the z-axis, to make it clear the optics dovetail
    inset_at_z = inset_zero + 1;
    // a larger flange inset at the sides for strength
    flange_side = 5;
    inset_sides = inset_zero + flange_side;
    // even larger flange at the reflection optics cut-out
    inset_opposite = inset_zero + 6;
    hull(){
        reflect_x(){
            // A small correction translation to match the shape by the z-dovetail in versions up to v7.0.0-beta4
            // This is needed because the central optics cutout determines the shape of the z-dovetail body on the actuator side
            correction_1 = [1.175, -0.157, 0];
            translate(correction_1){
                inner_wall_base_corner(params, 45, leg_outer_w(params)/2+microscope_wall_t()/2, y_inset=inset_at_z);
            }
            //radius on which wall sits.
            wall_rad = leg_outer_w(params)/2;
            wall_rad_thick = leg_outer_w(params)/2-microscope_wall_t()/2;
            inner_wall_base_corner(params, 45, x=-wall_rad, y_inset=inset_sides);
            // mounting_lug_wall_vertex_position(params) is negative
            mounting_lug_cutout_vertex_position = (-mounting_lug_wall_vertex_position(params).x) - microscope_wall_t()/2 - flange_side;
            translate_x(mounting_lug_cutout_vertex_position){
                circle(r=microscope_wall_t()/2, $fn=6);
            }
            inner_wall_base_corner(params, 135, x=wall_rad, y_inset=inset_sides);
            // A small correction translation to match the shape by the reflection optics cutout in versions up to v7.0.0-beta4, for compatibility
            correction_2 = [-2.05, 1.76, 0];
            translate(correction_2){
                //More offset near the reflection optics cut out to improve stiffness
                inner_wall_base_corner(params, 135, x=-wall_rad_thick, y_inset=inset_opposite);
            }
        }
    }
}

//wall angle about the motor lug
function y_wall_angle(params) = let(
    wall_start = mounting_lug_wall_vertex_position(params),
    wall_end = y_actuator_wall_vertex_position(params, inside=false),
    wall_disp = wall_end - wall_start
) atan(wall_disp.y/wall_disp.x);

//default housing height
//height of the housing is 0.8mm higher than the motor screw due to the thickness
// of the lug on the motor
function side_housing_h(params) = y_motor_z_pos(params) + motor_bracket_h();
function housing_size(h) = [motor_connector_size().x+4+2,motor_connector_size().y+4+2+15.5, h];


module side_housing_placement(params){
    translate(y_actuator_wall_vertex_position(params, inside=false)){
        rotate_z(y_wall_angle(params)-90){
            children();
        }
    }
}

module side_housing(params, h=undef, cavity_h=undef, attach=true, screw_hole_type="none"){
    //attach: whether the housing it attached to the wall
    actuator_h = key_lookup("actuator_h", params);



    wall_h = is_undef(cavity_h) ? side_housing_h(params) : h;
    c_h = is_undef(cavity_h) ? wall_h+1 : cavity_h;
    shaft_z = motor_shaft_pos(actuator_h+xy_actuator_travel(params)).z;

    outer_r = 6;
    inner_r = 1;
    outer_x_pos = housing_size(wall_h).x - outer_r;
    difference(){
        hull(){
            side_housing_placement(params){
                translate([outer_x_pos, outer_r+1.5, 0]){
                    cylinder(r=outer_r,h=wall_h);
                }
                translate([outer_x_pos, housing_size(wall_h).y-outer_r, 0]){
                    cylinder(r=outer_r,h=wall_h);
                }
                cylinder(r=inner_r,h=wall_h);
                translate_y(housing_size(wall_h).y){
                    cylinder(r=inner_r,h=wall_h);
                }
            }
            if(attach){
                mounting_lug_wall_vertex(params);
                y_actuator_wall_vertex(params, inside=false);
            }
        }
        side_housing_cutout(params, h=c_h, screw_hole_type=screw_hole_type);
        translate(y_actuator_pos(params) + [0, 0, shaft_z-1.5]){
            cylinder(d=30, h=80);
        }
    }
}

function side_housing_cut_pos() = [2, 6, 0];

function side_housing_cut_size(h) = [motor_connector_size().x+2, motor_connector_size().y+2, h];

function side_housing_screw_pos() = let(
    screw_hole_offset = 7.5,
    housing_cut_size = side_housing_cut_size(h=0),
    screw_location = [housing_cut_size.x/2, housing_cut_size.y + screw_hole_offset, 0]
) screw_location;

module side_housing_cutout(params, h, screw_hole_type="none"){
    housing_cut_size = side_housing_cut_size(h=h+1);
    screw_hole_depth = 6.5;
    screw_location = side_housing_screw_pos();

    side_housing_placement(params){
        translate(side_housing_cut_pos()){
            translate_z(-1){
                cube(housing_cut_size);
            }
            // Cut holes for no 2 self tap screws
            if (screw_hole_type == "pilot"){
                translate(screw_location){
                    translate_z(h-screw_hole_depth){
                        no2_selftap_hole(h=screw_hole_depth+tiny());
                    }
                }
            }
            else if (screw_hole_type == "counterbore"){
                translate(screw_location){
                    translate_z(1.5){
                        no2_selftap_counterbore(tight=true);
                    }
                }
            }
        }
    }
}

module place_on_wall(params, is_y=true, housing=true){
    // The wall runs from the outside y actuator wall vertex to the
    // mounting lug wall vertex
    y_wall_start = mounting_lug_wall_vertex_position(params);

    wall_start = is_y ? y_wall_start : [-y_wall_start.x, y_wall_start.y, y_wall_start.z];
    wall_angle = is_y ? y_wall_angle(params) : - y_wall_angle(params);

    wall_tr_y = housing ? -housing_size(0).x : -microscope_wall_t()/2;
    wall_tilt = housing ? 0 : outer_wall_tilt(params);

    // pivot about the starting corner of the wall so X is along it
    translate(wall_start){
        rotate(wall_angle){
            // move out to the surface (the above are centres of cylinders)
            translate_y(wall_tr_y){
                // and then align y with the vertical axis of the wall
                rotate_x(90-wall_tilt){
                    // now X and Y are in the plane of the wall, and z=0 is its surface.
                    children();
                }
            }
        }
    }
}
