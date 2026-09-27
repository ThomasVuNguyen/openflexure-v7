

// This is modifed from involute_gears.scad in MCAD
// Licensed under the Creative Commons - GNU LGPL 2.1 license.
// © 2010 by GregFrost, thingiverse.com/Amp
// http://www.thingiverse.com/thing:3575 and http://www.thingiverse.com/thing:3752
// This was modifed from the tag: openscad-2019.05 of repo https://github.com/openscad/MCAD/
//
// Updated by Julian Stirling in 2020 to remove depreciated child and assign
//     usage
// Updated by Julian Stirling in 2020 to remove excess functions unused by the
//     OpenFlexure Project. And to unify code style somewhat.


/**
* Calculate the outer radius for a gear from pitch radius and number of teeth
*/
function gear_outer_radius(pitch_r, n_teeth) = pitch_r*(1 + 2/n_teeth);

/**
* Calculate the pitch radius for a gear the circular pitch and the number of teeth
* The pitch radius is the ditance from the centre of gear to the meshing point.
* This is calcualted as:
*    pitch radius = Nteeth * circular_pitch / 360
*/
function gear_pitch_radius(circular_pitch, n_teeth) = n_teeth*circular_pitch/360;


module gear(number_of_teeth=15,
            circular_pitch=false,
            diametral_pitch=false,
            pressure_angle=28,
            clearance = 0.2,
            gear_thickness=5,
            rim_thickness=8,
            rim_width=5,
            hub_thickness=10,
            hub_diameter=15,
            bore_diameter=5,
            circles=0,
            backlash=0,
            twist=0,
            involute_facets=0,
            flat=false){

    assert(!(circular_pitch==false && diametral_pitch==false),
           "MCAD ERROR: gear module needs either a diametral_pitch or circular_pitch");
    assert(circular_pitch==false || diametral_pitch==false,
           "MCAD ERROR: cannot specify diametral_pitch and circular_pitch");

    //Convert diametrial pitch to our native circular pitch
    circ_pitch = circular_pitch!=false ? circular_pitch : 180/diametral_pitch;

    // Pitch diameter: Diameter of pitch circle.
    pitch_diameter  =  number_of_teeth * circ_pitch / 180;
    pitch_radius = pitch_diameter/2;


    // Base Circle
    base_radius = pitch_radius*cos(pressure_angle);

    // Diametrial pitch: Number of teeth per unit length.
    pitch_diametrial = number_of_teeth / pitch_diameter;

    // Addendum: Radial distance from pitch circle to outside circle.
    addendum = 1/pitch_diametrial;

    //Outer Circle
    outer_radius = pitch_radius+addendum;

    // Dedendum: Radial distance from pitch circle to root diameter
    dedendum = addendum + clearance;

    // Root diameter: Diameter of bottom of tooth spaces.
    root_radius = pitch_radius-dedendum;
    backlash_angle = backlash / pitch_radius * 180 / PI;
    half_thick_angle = (360 / number_of_teeth - backlash_angle) / 4;

    // Variables controlling the rim.
    rim_radius = root_radius - rim_width;

    // Variables controlling the circular holes in the gear.
    circle_orbit_diameter=hub_diameter/2+rim_radius;
    circle_orbit_curcumference=PI*circle_orbit_diameter;

    // Limit the circle size to 90% of the gear face.
    circle_diameter = min(0.70*circle_orbit_curcumference/circles,
                          (rim_radius-hub_diameter/2)*0.9);

    difference(){
        union(){
            difference(){
                linear_exturde_flat_option(flat=flat, height=rim_thickness, convexity=10, twist=twist){
                    gear_shape(number_of_teeth,
                               pitch_radius = pitch_radius,
                               root_radius = root_radius,
                               base_radius = base_radius,
                               outer_radius = outer_radius,
                               half_thick_angle = half_thick_angle,
                               involute_facets=involute_facets);
                }

                if(gear_thickness < rim_thickness){
                    translate([0, 0, gear_thickness]){
                        cylinder(r=rim_radius,h=rim_thickness-gear_thickness+1);
                    }
                }
            }
            if(gear_thickness > rim_thickness){
                linear_exturde_flat_option(flat=flat, height=gear_thickness){
                    circle(r=rim_radius);
                }
            }
            if(flat == false && hub_thickness > gear_thickness){
                translate([0, 0, gear_thickness]){
                    linear_exturde_flat_option(flat=flat, height=hub_thickness-gear_thickness){
                        circle(r=hub_diameter/2);
                    }
                }
            }
        }
        if (bore_diameter>0){
            translate([0, 0, -1]){
                bore_h = 2+max(rim_thickness,hub_thickness,gear_thickness);
                linear_exturde_flat_option(flat =flat, height=bore_h){
                    circle(r=bore_diameter/2);
                }
            }
        }
        if(circles>0){
            for(i=[0:circles-1]){
                rotate([0, 0, i*360/circles]){
                    translate([circle_orbit_diameter/2,0,-1]){
                        linear_exturde_flat_option(flat =flat, height=max(gear_thickness,rim_thickness)+3){
                            circle(r=circle_diameter/2);
                        }
                    }
                }
            }
        }
    }
}

module linear_exturde_flat_option(flat =false, height = 10, center = false, convexity = 2, twist = 0){
    if(flat==false){
        linear_extrude(height = height, center = center, convexity = convexity, twist= twist){
            children(0);
        }
    }
    else{
        children(0);
    }
}

module gear_shape(number_of_teeth,
                  pitch_radius,
                  root_radius,
                  base_radius,
                  outer_radius,
                  half_thick_angle,
                  involute_facets){
    union(){
        rotate(half_thick_angle){
            circle($fn=number_of_teeth*2, r=root_radius);
        }

        for(i = [1:number_of_teeth]){
            rotate([0, 0, i*360/number_of_teeth]){
                involute_gear_tooth(pitch_radius = pitch_radius,
                                    root_radius = root_radius,
                                    base_radius = base_radius,
                                    outer_radius = outer_radius,
                                    half_thick_angle = half_thick_angle,
                                    involute_facets=involute_facets);
            }
        }
    }
}

module involute_gear_tooth(pitch_radius,
                           root_radius,
                           base_radius,
                           outer_radius,
                           half_thick_angle,
                           involute_facets){
    min_radius = max(base_radius,root_radius);

    pitch_point = involute(base_radius, involute_intersect_angle(base_radius, pitch_radius));
    pitch_angle = atan2(pitch_point[1], pitch_point[0]);
    centre_angle = pitch_angle + half_thick_angle;

    start_angle = involute_intersect_angle(base_radius, min_radius);
    stop_angle = involute_intersect_angle(base_radius, outer_radius);

    res=(involute_facets!=0)?involute_facets:($fn==0)?5:$fn/4;

    union()
    {
        for(i=[1:res])
        {
            point1=involute(base_radius,start_angle+(stop_angle - start_angle)*(i-1)/res);
            point2=involute(base_radius,start_angle+(stop_angle - start_angle)*i/res);
            side1_point1=rotate_point(centre_angle, point1);
            side1_point2=rotate_point(centre_angle, point2);
            side2_point1=mirror_point(rotate_point(centre_angle, point1));
            side2_point2=mirror_point(rotate_point(centre_angle, point2));

            points = [[0, 0], side1_point1, side1_point2, side2_point2, side2_point1];
            polygon(points=points, paths=[[0,1,2,3,4,0]]);
        }
    }
}

// Mathematical Functions
//===============

// Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
//source: http://www.mathhelpforum.com/math-help/geometry/136011-circle-involute-solving-y-any-given-x.html

function involute_intersect_angle(base_radius, radius) = sqrt(pow(radius/base_radius, 2) - 1) * 180 / PI;

// Calculate the involute position for a given base radius and involute angle.

function rotated_involute(rotate, base_radius, involute_angle) = let(
    unrotated_involute = involute(base_radius, involute_angle)
)
[
    cos(rotate) * unrotated_involute.x + sin(rotate) * unrotated_involute.y,
    cos(rotate) * unrotated_involute.y - sin(rotate) * unrotated_involute.x
];

function mirror_point(coord) =
[coord.x, -coord.y];

function rotate_point(rotate, coord) =
[
    cos(rotate) * coord.x + sin(rotate) * coord.y,
    cos(rotate) * coord.y - sin(rotate) * coord.x
];

function involute(base_radius, involute_angle) = let(
    angle_radian = involute_angle*PI/180
)
[
    base_radius*(cos(involute_angle) + angle_radian*sin(involute_angle)),
    base_radius*(sin(involute_angle) - angle_radian*cos(involute_angle))
];

