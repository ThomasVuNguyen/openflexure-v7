// The module provides functionality for creating threads.
// The threads are profile is highly spcified allowing thread profiles
// such as trapezoidal thrads to be created.


/*
This part of the OpenFlexure Microscope
(c) Richard Bowman 2020
Released under the CERN Open Hardware License

This file was put together by Graham Gibson, as a derivative of
https://github.com/ZhuangLab/3D-printing/tree/master/nikon_filter_cube
by Hazen Babcock
ZhuangLab/3D-printing is CERN OHL 1.2 licensed.
(c)  Hazen Babcock 2015
*/

use <./utilities.scad>

$fn = 200;

// This creates a slightly truncated trianglular prism with angled end faces
module reverse_trapezoid(points){
    faces = [[0,1,2,3],
             [0,4,5,1],
             [0,3,7,4],
             [6,5,4,7],
             [6,2,1,5],
             [6,7,3,2]];
     polyhedron(points=points, faces=faces);
}

//simple functions to avoid repeat defintions
function cylinder_radius(radius, thread_height) = radius + thread_height;
function z_step(pitch, number_divisions) = pitch/number_divisions;
function angle_step(number_divisions) = 360.0/number_divisions;

//Calculates the points of the trapezeod that makes up the thread section
function thread_points(inner,
                       radius,
                       thread_height,
                       thread_base_width,
                       thread_top_width,
                       pitch,
                       overlap,
                       number_divisions) = let(
    //see outer_thread for input definitions
    cylinder_radius = cylinder_radius(radius, thread_height),
    angle_step = angle_step(number_divisions),
    z_step = z_step(pitch, number_divisions),
    // This is the angle that each section overlaps by
    angular_overlap = angle_step * overlap,
    angular_disp = 0.5 * (angle_step + angular_overlap),
    outer_width = inner ? thread_base_width : thread_top_width,
    inner_width = inner ? thread_top_width : thread_base_width,
    p0 = [cylinder_radius * cos(-angular_disp),
          cylinder_radius * sin(-angular_disp),
          -0.5 * outer_width],
    p1 = [radius * cos(-angular_disp),
          radius * sin(-angular_disp),
          -0.5 * inner_width],
    p2 = [radius * cos(-angular_disp),
          radius * sin(-angular_disp),
          0.5 * inner_width],
    p3 = [cylinder_radius * cos(-angular_disp),
          cylinder_radius * sin(-angular_disp),
          0.5 * outer_width],
    p4 = [cylinder_radius * cos(angular_disp),
          cylinder_radius * sin(angular_disp),
          -0.5 * outer_width + z_step],
    p5 = [radius * cos(angular_disp),
          radius * sin(angular_disp),
          -0.5 * inner_width + z_step],
    p6 = [radius * cos(angular_disp),
          radius * sin(angular_disp),
          0.5 * inner_width + z_step],
    p7 = [cylinder_radius * cos(angular_disp),
          cylinder_radius * sin(angular_disp),
          0.5 * outer_width + z_step]
) inner ? [p0, p1, p2, p3, p4, p5, p6, p7] : [p1, p0, p3, p2, p5, p4, p7, p6];


module base_thread(inner,
                   radius,
                   thread_height,
                   thread_base_width,
                   thread_top_width,
                   thread_length,
                   pitch,
                   extra,
                   overlap,
                   number_divisions){

    //This is a highly specified base thread module
    // inner = boolean for an inner or outher thread
    // radius - minor radius of the thread - the inner radius of that the "base" of the thread sits on
    // thread_height - height of the thread profile. e.g. the extra radius to the top of the thread
    // thread_base_width - the width of the triangular base of the profile at r=radius
    // thread_top_width - the truncated width at the at the tip of the profile at r=radius+thread_height
    // thread_length - length of thread in mm
    // pitch - pitch in mm
    // extra - number of extra rotation of thead to create these will be truncated to length. This
    //         should not need changeing
    // overlap - fractional overlap of each trapezoidal segment
    cylinder_radius = cylinder_radius(radius, thread_height);
    overshoot =  extra * number_divisions;
    turns = thread_length/pitch;
    angle_step = angle_step(number_divisions);
    z_step = z_step(pitch, number_divisions);
    points = thread_points(inner=inner,
                           radius=radius,
                           thread_height=thread_height,
                           thread_base_width=thread_base_width,
                           thread_top_width=thread_top_width,
                           pitch=pitch,
                           overlap=overlap,
                           number_divisions=number_divisions);
    difference(){
         union(){
            for(i = [-overshoot:(turns*number_divisions+overshoot)]){
                rotate_z(i*angle_step){
                    translate_z(i*z_step){
                        reverse_trapezoid(points);
                    }
                }
            }
        }
        translate_z(-2){
            cylinder(r = cylinder_radius+0.1, h = 2);
        }
        translate_z(thread_length){
            cylinder(r = cylinder_radius+0.1, h = 2);
        }
    }
}

module inner_thread(radius=12.9,
                    thread_height=0.45,
                    thread_base_width=0.6,
                    thread_top_width=0.05,
                    thread_length=6.5,
                    pitch=0.635,
                    extra=-0.5,
                    overlap=0,
                    number_divisions=60){
    // This is a highly specified thread module for inner threads.
    // See base_thread for parameter definitions
    base_thread(inner = true,
                radius=radius,
                thread_height=thread_height,
                thread_base_width=thread_base_width,
                thread_top_width=thread_top_width,
                thread_length=thread_length,
                pitch=pitch,
                extra=extra,
                overlap=overlap,
                number_divisions=number_divisions);
}


module outer_thread(radius=12.9,
                    thread_height=0.45,
                    thread_base_width=0.6,
                    thread_top_width=0.05,
                    thread_length=6.5,
                    pitch=0.635,
                    extra=-0.5,
                    overlap=0,
                    number_divisions=60){
    // This is a highly specified thread module for outer threads.
    // See base_thread for parameter definitions
    base_thread(inner = false,
                radius=radius,
                thread_height=thread_height,
                thread_base_width=thread_base_width,
                thread_top_width=thread_top_width,
                thread_length=thread_length,
                pitch=pitch,
                extra=extra,
                overlap=overlap,
                number_divisions=number_divisions);
}