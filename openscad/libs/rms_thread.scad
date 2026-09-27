/*
RMS Thread library

Many microscope objectives attach to their microscope using a thread specified by the Royal Microscopical
Society, abbreviated RMS.  This is formalised in ISO 8038-1:1997, though the thread is much older.
This library will cut an RMS thread, suitable for printing as an internal thread.  It is deliberately not a
general purpose thread library, because it aims to be as simple as possible, with the hope that I can more
reliably produce watertight models.

I have relied upon ISO 8038-1:1997, also known as BS 7012-4.1: 1998, for all the definitions, and for the
thread profile (which consists of circular peaks and troughs, joined by a straight flank).

The single useful geometry rendered by this library is a "thread cutter", i.e. a shape that, when 
`difference()`d from a solid block, produces a correctly formed *internal* thread.  The shape is the same
as an external thread, but I have used the dimensions given for the internal thread.  That means what
you render will be slightly incorrect as per the standard if you use it as an external thread.

Some useful references I discovered only after writing this:
* https://www.nablu.com/2020/01/new-approach-to-screw-threads-in.html
* https://github.com/nophead/NopSCADlib#Thread

This library aims to be simple, self-contained (only this file), fast, and watertight.  It currently
appears to fulfil all these aims.

Copyright Richard Bowman, 2022
Released under CERN Open Hardware License CERN-OHL-S-2.0 or later
*/

// Key RMS thread parameters, taken from the standard
function rms_thread_pitch() = 0.706;
// Sometimes it is desirable to make the thread slightly tighter, for printing.  The `tight` parameter
// permits this by shrinking slightly from the nominal size.
function rms_thread_nominal_d() = 20.320;
function rms_thread_angle() = 55;
function rms_thread_fundamental_triangle_h() = (
    rms_thread_pitch() / tan(rms_thread_angle()/2) / 2
);
// The peaks and troughs are curved, such that the actual
// thread height is 2/3 of the fundamental triangle.
// working through the trigonometry, that tells us that
// the centre of the curve must be a distance c from the
// tip of the fundamental triangle, where 
// c=r/sin(thread_angle/2)
// and we know that c = fundamental_triangle_h/6 + r
// this rearranges to:
function rms_thread_peak_radius() = let(
    H = rms_thread_fundamental_triangle_h(),
    ta = rms_thread_angle()
) H / (6 * (1/sin(ta/2) - 1));
// The radius is given in the standard, so let's check my maths:
assert(
    abs(rms_thread_peak_radius() - 0.097) < 0.001,
    "Calculated radius does not match the standard!"
);

// Generate a point on a circle with a given centre
// (used in rms_thread_profile_section_points)
function circle_point(angle, radius, centre) = let(
    unit_vector = [cos(angle), sin(angle)]
) centre + unit_vector*radius;

// Generate a list of points along the profile of a thread
// This list of 2D points defines the profile of one groove, and is
// used internally by `rms_thread_cutter()`.
// To see the shape, you can try rendering:
// `polygon([each rms_thread_profile_section_points(), [0,0]]);`
function rms_thread_profile_section_points(d_offset=0, peak_points=5) = let(
    pitch = rms_thread_pitch(),
    nominal_diameter = rms_thread_nominal_d() + d_offset,
    thread_angle = rms_thread_angle(),
    fundamental_triangle_h = rms_thread_fundamental_triangle_h(),
    radius = rms_thread_peak_radius(),

    // We can define the actual thread depth too
    thread_depth = fundamental_triangle_h * 2/3,

    // We'll define the thread profile in the XY plane.  It will
    // be swept around the Y axis when we extrude, so X becomes
    // the radial coordinate.

    // As per the standard, the thread has straight flanks, with
    // radiused peaks and troughs.  The troughs are the furthest
    // points from the origin, at `nominal_diameter/2`.
    // The centre of the curve defining the trough is:
    trough_circle_centre = [nominal_diameter/2 - radius, 0],
    // Points on the curved part of the trough can be found by
    // displacing by one radius, at a particular angle:

    // The flank will start at:
    //circle_point(90 - thread_angle/2, radius, trough_circle_centre)

    // Similarly, points on the peak will lie on a circle centred
    // on:
    upper_peak_circle_centre = [nominal_diameter/2 - thread_depth + radius, pitch/2],
    lower_peak_circle_centre = [nominal_diameter/2 - thread_depth + radius, -pitch/2],

    // Render the thread profile, centred on one groove (i.e. trough of the internal thread)
    N = peak_points,
    curve_angle = 90 - thread_angle/2
)   [
    // We start just above the lower peak of the thread, and work upwards

    // Curve round to the flank
    // NB the 1:N which means we start just above the peak - to 
    // avoid duplicating the point at the bottom of the next thread.
    for(i = [1:N]) circle_point(
        180 - i/N*curve_angle,
        radius,
        lower_peak_circle_centre
    ),

    // The flank is defined implicitly by the last point of the peak 
    // and the first point of the trough.

    // Curve from lower to upper flank, i.e. the trough
    for(i = [-N:N]) circle_point(
        i/N*curve_angle,
        radius,
        trough_circle_centre
    ),

    // The flank is, again, defined implicitly by the trough and upper peak

    // Upper peak, finishing at the peak (i.e. the vertical surface)
    for(i = [N:-1:0]) circle_point(
        180 + i/N*curve_angle,
        radius,
        upper_peak_circle_centre
    )
];

// Cut an RMS internal thread
// This module renders a 3D shape that can be subtracted from
// a solid object to make an RMS thread, defined as per
// ISO 8038-1.
//
// Parameters:
// * `h` sets the height.  This is defined as the height from the
//   centre of the lowest trough to the centre of the highest one.
//   the height of the shape generated will exceed `h` by one pitch,
//   as it starts at (`-pitch/2`) and finishes at (`h+pitch/2`).
//   We recommend you always include at least an extra pitch/2 to
//   allow for the start/stop of the thread.
// * `d_offset` is added to the nominal diameter to give a tighter 
//   fit, and was determined empirically.
// * `$fn` has its usual meaning, i.e. the number of points around 
//   the circumference.
//
// The shape rendered here should be subtracted from a solid
// block to form the **internal** thread.
// That means it looks like the thread you'd find on an 
// objective, but it is slightly larger, because the standard
// defines the two threads with a slight space between them.
module rms_thread_cutter(h=5, d_offset=0.6, peak_points=2, $fn=64){
    pitch = rms_thread_pitch();
    offset_per_point = [0, 0, pitch/$fn];
    angle_per_point = 360/$fn;
    N_sections = floor(h/pitch*$fn);
    assert(N_sections > $fn, "Cannot render a thread shorter than one pitch.");  // We must have at least one full thread
    profile = rms_thread_profile_section_points(d_offset=d_offset, peak_points=peak_points);
    Np = len(profile);
    bottom_i = (N_sections+1)*Np;
    top_i = (N_sections+1)*Np + 1;
    function reverse(items) = [for(i=[len(items)-1:-1:0]) items[i]];  // reverse a list
    // Convert from (2d) polar to cartesian coordinates
    function polar_point(angle, radius) = [cos(angle), sin(angle)] * radius;
    // Convert from cylindrical polars to cartesian coordinates
    // The first argument is an array of (r, z) points, the second
    // is a single polar angle, and the third is an optional cartesian
    // offset.
    function rz_to_xyz(rz_points, theta, offset=[0,0,0]) = [
        for(p = rz_points) [each polar_point(theta, p[0]), p[1]] + offset
        // NB p[0] is r, p[1] is z
    ];
    polyhedron(
        points=[
            for(i=[0:N_sections]) each rz_to_xyz(profile, angle_per_point*i, offset=offset_per_point*i),
            // This doesn't have any points in the middle - i.e. we're only rendering the outside of the thread
            // that will not be watertight.

            // Manually add top and bottom points
            [0,0,-pitch/2], // index will be (N_sections+1)*Np
            [0,0,h+pitch/2]
        ],
        faces=[
            // The start and end faces are vertical, so they include all the points along one profile, 
            // plus a point at the centre of the top/bottom of the shape (x=y=0).
            reverse([   // vertical face at the start (bottom) of the thread
                for(j=[0:Np-1]) j, // all the way around one profile
                Np*$fn,            // first point of the profile above
                bottom_i           // centre of the shape
            ]),
            [   // vertical face at the end (top) of the thread
                Np*(N_sections - $fn) - 1,                // last point of the profile below the last one
                for(j=[0:Np-1]) Np*(N_sections - 1) + j,    // the last profile
                top_i                                       // centre of the top surface
            ],

            // the outer surface will connect each section to the next one along the thread
            // NB these are quadrilaterals, which will be split into two triangles automatically
            for(i=[0:N_sections-2]) for(j=[0:Np-2]) [i*Np+j, i*Np+j+1, (i+1)*Np + j+1, (i+1)*Np+j],

            // we also join the bottom of each spiral to the top of the previous one - starting from 
            // the second row.  Again, this is done using quadrilaterals to keep the code simple.
            for(i=[$fn:N_sections-2]) [(i-$fn)*Np+(Np-1), i*Np, (i+1)*Np, (i-$fn+1)*Np+(Np-1)],

            // The base, i.e. triangles between the bottom edge of each segment and the centre
            for(i=[0:$fn-1]) [i*Np, (i+1)*Np, bottom_i],
            // The top - note that winding order needs to be reversed so normals point outwards
            //[for(i=[1:$fn]) (N_sections - i - 1)*Np + (Np-1), N_sections*Np - 1]
            for(i=[N_sections-$fn:N_sections-1]) reverse([i*Np - 1, (i+1)*Np -1, top_i]),
        ]
    );
}

rms_thread_cutter(h=5, $fn=64);
