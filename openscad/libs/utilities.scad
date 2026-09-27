/*A collection of utilities developed for the OpenFlexure Microscope.*/

// SPDX-License-Identifier: CERN-OHL-S-2.0
// For copyright and authorship information, see the Git history at:
// https://gitlab.com/openflexure/openflexure-microscope

/* Return a tiny offset distance used to avoid zero-overlap or geometry issues.

This is useful for shifting geometry slightly to ensure proper unions or
to avoid degenerate cases in OpenSCAD operations.

`tiny()` was formerly known as `d`, but this caused confusion with diameters.

:return: A small constant distance (currently 0.05)
*/
function tiny() = 0.05;

/* Return a copy of a 3D vector with the z component set to 0.

:param size: A 3-element vector

:return: A new vector with the same x and y components, and z set to 0
*/
function zero_z(size) = [size.x, size.y, 0]; //set the z component of a 3-vector to 0

/* Return the argument if defined, otherwise return the default.

:param argument: The value to check
:param default: The fallback value if `argument` is undefined

:return: Either `argument` or `default`, depending on whether the argument is defined
*/
function if_undefined_set_default(argument, default) = is_undef(argument) ? default : argument;


/* Translate geometry along the x-axis.

Equivalent to `translate([dist, 0, 0])`.

:param x_tr: Distance to translate in the x-direction
*/
module translate_x(x_tr){
    translate([x_tr, 0, 0]){
        children();
    }
}

/* Translate geometry along the y-axis.

Equivalent to `translate([0, dist, 0])`.

:param y_tr: Distance to translate in the y-direction
*/
module translate_y(y_tr){
    translate([0, y_tr, 0]){
        children();
    }
}

/* Translate geometry along the z-axis.

Equivalent to `translate([0, 0, dist])`.

:param z_tr: Distance to translate in the z-direction
*/
module translate_z(z_tr){
    translate([0, 0, z_tr]){
        children();
    }
}

/* Rotate geometry about the x-axis.

Equivalent to `rotate([angle, 0, 0])`.

:param x_angle: Rotation angle in degrees around the x-axis
*/
module rotate_x(x_angle){
    rotate([x_angle, 0, 0]){
        children();
    }
}

/* Rotate geometry about the y-axis.

Equivalent to `rotate([0, angle, 0])`.

:param y_angle: Rotation angle in degrees around the y-axis
*/
module rotate_y(y_angle){
    rotate([0, y_angle, 0]){
        children();
    }
}

/* Rotate geometry about the z-axis.

Equivalent to `rotate([0, 0, angle])`.

:param z_angle: Rotation angle in degrees around the z-axis
*/
module rotate_z(z_angle){
    rotate([0, 0, z_angle]){
        children();
    }
}

/* Reflect geometry across input axis, keeping both original and mirrored objects.

Duplicate the children of this module, once unmodified and once mirrored
about the specified axis. Equivalent to `mirror(axis) children()`.

Convenience modules `reflect_x`, `reflect_y`, and `reflect_z` reflect about
the X, Y, and Z axes respectively.

:param axis: A 2D or 3D vector specifying the axis to reflect in

### Example
```example
reflect([1, 0, 0]){
    translate([10, 0, 0]){
        cube(10);
    }
}
```
*/
module reflect(axis){
    children();
    mirror(axis){
        children();
    }
}

/* Reflect geometry across the x-axis, keeping both original and mirrored objects.

Equivalent to `reflect([1, 0, 0])`
*/
module reflect_x(){
    reflect([1, 0, 0]){
        children();
    }
}

/* Reflect geometry across the y-axis, keeping both original and mirrored objects.

Equivalent to `reflect([0, 1, 0])`
*/
module reflect_y(){
    reflect([0, 1, 0]){
        children();
    }
}

/* Reflect geometry across the z-axis, keeping both original and mirrored objects.

Equivalent to `reflect([0, 0, `])`
*/
module reflect_z(){
    reflect([0, 0, 1]){
        children();
    }
}

/* Return a vector mirrored across the x-axis.

:param vec: The vector to mirror

:return: A new vector with its x-component inverted
*/
function vector_mirror_x(vec) = _vector_mirror_axis(vec, 0);

/* Return a vector mirrored across the y-axis.

:param vec: The vector to mirror

:return: A new vector with its y-component inverted
*/
function vector_mirror_y(vec) = _vector_mirror_axis(vec, 1);

/* Return a vector mirrored across the z-axis.

:param vec: The vector to mirror

:return: A new vector with its z-component inverted
*/
function vector_mirror_z(vec) = _vector_mirror_axis(vec, 2);

/* Internal utility to mirror a vector across one axis.

:param vec: The input vector
:param axis_index: Index of the axis to invert (0 = x, 1 = y, 2 = z)

:return: A new vector mirrored across the given axis
*/
function _vector_mirror_axis(vec, axis_index) = [
    for (i = [0:len(vec)-1])
        if (i==axis_index)
            -vec[i]
        else
            vec[i]
];

/* Create a linear array of repeated geometry.

Generate `N` copies of the children, spaced by `delta`. When `center` is true,
copies are distributed symmetrically about the origin.

:param delta: Vector specifying the displacement between adjacent copies  
:param N: Total number of copies  
:param center: Whether to centre the array on the origin

### Example 1
```example
repeat([10, 0, 0], 4){
    cube(5);
}
```

### Example 2
```example
repeat([10, 0, 0], 4, center=true){
    cube(5, center=true);
}
```
*/
module repeat(delta, N, center=false){
    //repeat children along a regular array
    center_tr = (center ?  -(N-1)/2 : 0) * delta;
    translate(center_tr){
        for(i=[0:1:(N-1)]){
            translate(i*delta){
                children();
            }
        }
    }
}

/* Slice out geometry intersecting the xz-plane.

Keeps only the part of the geometry that lies in the xz-plane by
intersecting with a very thin slab at `y`.

:param y: Height of the slice along the y-axis
*/
module xz_slice(y=0){
    intersection(){
        translate_y(y){
            cube([999,2*tiny(),999],center=true);
        }
        children();
    }
}

/* Create a hollow tube by subtracting an inner cylinder from an outer cylinder.

:param ri: Inner radius  
:param ro: Outer radius  
:param h: Height of the tube  
:param center: Whether the tube is centred on the z-axis
*/
module tube(ri, ro, h, center=false){
    difference(){
        cylinder(r=ro, h=h, center=center);
        if (center){
            cylinder(r=ri, h=h+1, center=true);
        }
        else {
            translate_z(-1){
                cylinder(r=ri, h=h+2, center=false);
            }
        }
    }
}

/* Create a hole for an M4 machine screw to self-tap into.

This produces a triangular cross-section hole suitable for machine screws to self tap.
These are no longer recommended. Nut traps are preferable.

:param h: Depth of the hole  
:param center: Whether the hole is centred on the z-axis
*/
module m4_selftap_hole(h=10, center=false){
    // r and flat calculated from the trylinder selftap function used for years.
    // Moving to explicit tested number rather than arbitrary calculations.
    trylinder(r=1.3, flat=1.73, h=h, center=center);
}

/* Create a hole for a No2 self-tapping screw.

This produces a triangular cross-section hole (if used in a `difference()` operation)
suitable for No2 self-tap screws.

:param h: Depth of the hole  
:param center: Whether the hole is centred on the z-axis
*/
module no2_selftap_hole(h=10, center=false){
    //This value for r came from test prints. ranging r from 0.3 to 0.5.
    trylinder(r=.3, flat=1.73, h=h, center=center);
}

/* Create a clearance hole for a No2 self-tapping screw.

:param h: Depth of the hole  
:param center: Whether the hole is centred on the z-axis
*/
module no2_selftap_clearancehole(h=10, center=false){
    cylinder(d=2.5, h=h, center=center);
}

/* Create a counterbore for a No2 self-tapping screw.

:param bore_h: Height of the counterbore  
:param hole_h: Height of the clearance hole  
:param flip_z: Flip the counterbore along the z-axis  
:param tight: If true, use a tighter bore diameter  
*/
module no2_selftap_counterbore(bore_h=999, hole_h=999, flip_z=false, tight=false){
    $fn = 14;
    bore_d = tight ? 4.8 : 5.6;
    generic_counterbore(bore_d=bore_d, bore_h=bore_h, hole_d=2.5, hole_h=hole_h, flip_z=flip_z);
}

/* Create a hole for a No1 self-tapping screw.

This produces a triangular cross-section hole (if used in a `difference()` operation)
suitable for No1 self-tap screws.

:param h: Depth of the hole  
:param center: Whether the hole is centred on the z-axis
*/
module no1_selftap_hole(h=10, center=false){
    //This value for flat came from scaling the No2 hole.
    trylinder(r=.3, flat=1.23, h=h, center=center);
}

/* Counterbored through hole for an M3 cap screw.

The counterbore is above z=0, and the through hole is below z=0.  

If `flip_z` is set to true, the hole is flipped along the z-axis and designed to print
properly upside down.

:param bore_h: Height of the counterbore  
:param hole_h: Height of the through hole  
:param flip_z: Flip the hole along the z-axis  
*/
module m3_cap_counterbore(bore_h=999, hole_h=999, flip_z=false){
    $fn = 14;
    generic_counterbore(bore_d=6.5, bore_h=bore_h, hole_d=3.5, hole_h=hole_h, flip_z=flip_z);
}

/* Create a generic counterbored hole.

Use this to create specific counterbore functions for specifice screw types.

Creates a counterbore with specified bore diameter and height, and a through hole with
given diameter and height.

If `flip_z` is true, the hole is flipped along the z-axis for upside-down printing.

:param bore_d: Diameter of the counterbore  
:param bore_h: Height of the counterbore  
:param hole_d: Diameter of the through hole  
:param hole_h: Height of the through hole  
:param flip_z: Flip the hole along the z-axis (default false)  
*/
module generic_counterbore(bore_d, bore_h, hole_d, hole_h, flip_z=false){
    if (flip_z){
        intersection(){
            hole_from_bottom(r=hole_d/2, h=hole_h, base_w=bore_d*2, big_bottom=false);
            cylinder(d=bore_d, h=3*hole_h, center=true);
        }
        translate_z(-(bore_h-tiny())){
            cylinder(d=bore_d, h=bore_h+tiny());
        }
    }
    else{
        translate_z(-hole_h){
            cylinder(d=hole_d, h=hole_h+tiny());
        }
        cylinder(d=bore_d, h=bore_h);
    }
}


/* Create a hole to fit an M3 nut.

Creates a shape that, when subtracted from an object, forms a trap for an M3 nut.  
The trap size and clearance follow ISO 4032 specifications and practical 3D printing
tolerances.

:param h: Height of the nut trap (default 2.6 mm)  
:param center: Center the hole along the z-axis (default false)  
:param tight: Set to true for a tighter nut trap (default false)  
:param shaft: Include a long cylinder for the bolt shaft (default false)  
*/
module m3_nut_hole(h=undef,center=false, tight=false ,shaft=false){

    // Note 2.6mm is the standard height giving 0.2mm clearance over the maximum
    // m3 nut height (2.4mm) as specified in ISO 4032
    height = if_undefined_set_default(h, 2.6);

    // According too ISO 4032 maximum flat-to-flat distance of an m3 nut is
    // 5.5mm (minimum is 5.32mm). As the corners are rounder the minimum width
    // across corners is specified as 6.01mm.
    //
    // As 3D printers slightly undersize small holes 5.7mm is chosen as the standard
    // nut trap width. giving 0.2mm clearance and still 0.31mm interference.
    //
    // Tight traps are 0.1mm smaller. They are used in locations where it is easy
    // to pull the nut (or hex bolt head) into the trap (such as on the gears)
    width = tight ? 5.6 : 5.7;

    // diameter of  circumcribed circule
    trap_diameter = width/sin(60);

    // clearance factor determined empirically over many years
    shaft_diameter = 3*1.16;

    union(){
        cylinder(d=trap_diameter, h=height, center=center, $fn=6);
        if(shaft){
            cylinder(d=shaft_diameter, h=999, center=true, $fn=16);
        }
    }
}

/* Create a hole for an M3 nut oriented in the vertical plane.

This differs from `m3_nut_hole` as it not only changes the nut rotation but also
creates extra space above the nut to compensate for print drooping. This extra space
is unnecessary if the nut is inserted from the top.

:param h: Height of the nut trap (default 2.6 mm)  
:param center: Center the hole along the z-axis (default false)  
:param extra_height: Extra vertical clearance above the nut (default 0.1 mm)  
:param shaft_length: Length of the bolt shaft hole (default 0)  
:param nut_angle: Rotation angle of the nut around the vertical axis; 0 means flat side
    down (default 0)  
*/
module m3_nut_hole_y(h=undef, center=false, extra_height=0.1, shaft_length=0, nut_angle=0){
    
    // See module `m3_nut_hole` for explanation of these sizes
    height = if_undefined_set_default(h, 2.6);
    width = 5.7;
    // diameter of  circumcribed circule
    trap_diameter = width/sin(60);
    // clearance factor determined empirically over many years
    shaft_diameter = 3*1.16;

    union(){
        rotate([-90, 0, 0]){
            rotate_z(nut_angle){
                cylinder(d=trap_diameter, h=height, center=center, $fn=6);
            }
        }

        if(shaft_length > 0){
            translate_y(height/2){
                printable_horizontal_hole(h=2*shaft_length,
                                          r=shaft_diameter/2,
                                          extra_height=extra_height,
                                          center=true,
                                          $fn=16);
            }
        }

        if (nut_angle==0){
            // extra space on top of nut, only makes sense if the nut is flat down/up
            center_y = center ? -height/2 : 0;

            //Note: The cirumscribed radius of a hexagon is the same as the face length.
            translate([-trap_diameter/4, center_y ,0]){
                cube([trap_diameter/2, height, width/2+extra_height]);
            }
        }
    }
}

/* Create an elongated cylinder used to make a slot for a screw.

The slot is oriented in the y-direction.

:param r: radius of the slot
:param h: height of the slot
:param dy: length of the slot (centre to centre on circles). Total length is `dy + 2*r`
:param center: if true, the shape is centred on all axes (default false)

### Example
```example
cyl_slot(r=2, h=10, dy=20);
```
*/
module cyl_slot(r=1, h=1, dy=2, center=false){

    hull(){
        repeat([0, dy, 0], 2, center=true){
            cylinder(r=r, h=h, center=center);
        }
    }
}


/* Create a keyhole shaped prism. The main lobe is centred at (x,y) = (0,0).

The slot runs in the y direction.

:param h: height of the keyhole shape
:param r_hole: radius of the larger hole
:param r_slot: radius of the slot
:param l_slot: length of the slot (y-direction), from centre of hole to centre of circle at top of slot
:param center: whether the shape is centred in z (default false)

### Example
```example
keyhole(10, 2.5, 1.6, 5, center=false);
```
*/
module keyhole(h, r_hole, r_slot, l_slot, center=false){
    translate_y(l_slot/2){
        cyl_slot(r=r_slot, h=h, dy=l_slot, center=center);
    }
    cylinder(r=r_hole, h=h, center=center);
}


/* Undo a rotation previously applied with `rotate()`.

Since `rotate()` applies three rotations in order, `unrotate()` reverses this
by applying the rotations in reverse order.


:param rotation: vector of rotation angles [x, y, z] in degrees

### Example
```example
angles = [30, 60, 45];
unrotate(angles){
    rotate(angles){
        cylinder(r=2, h=10);
    }
}
```

Note that `rotate(-rotation)` does not undo a previous `rotate(rotation)` due to the
order of rotation application:

### Counter example
```example
angles = [30, 60, 45];
rotate(-angles){
    rotate(angles){
        cylinder(r=2, h=10);
    }
}
```
*/
module unrotate(rotation){
    //undo a previous rotation
    //Note: this is not the same as rotate(-rotation) due to ordering.
    rotate_x(-rotation.x){
        rotate_y(-rotation.y){
            rotate_z(-rotation.z){
                children();
            }
        }
    }
}

/* Apply a sparse matrix transformation to children.

This module lets you specify individual elements of a 4x4 matrix, defaulting
unspecified elements to the identity matrix. This is useful as many transformations
are quite close to the identity matrix.

:param xx: Matrix element at row 0, col 0 (default 1)  
:param yy: Matrix element at row 1, col 1 (default 1)  
:param zz: Matrix element at row 2, col 2 (default 1)  
:param xy: Matrix element at row 0, col 1 (default 0)  
:param xz: Matrix element at row 0, col 2 (default 0)  
:param yx: Matrix element at row 1, col 0 (default 0)  
:param yz: Matrix element at row 1, col 2 (default 0)  
:param zx: Matrix element at row 2, col 0 (default 0)  
:param zy: Matrix element at row 2, col 1 (default 0)  
:param xt: Matrix element at row 0, col 3 (translation x) (default 0)  
:param yt: Matrix element at row 1, col 3 (translation y) (default 0)  
:param zt: Matrix element at row 2, col 3 (translation z) (default 0)  

The final matrix is:
```scad
[[xx, xy, xz, xt],
 [yx, yy, yz, yt],
 [zx, zy, zz, zt],
 [0,  0,  0,  1]];
```

### Example 1
```example
sparse_matrix_transform(yz=0.5){
    cylinder(r=5, h=20);
}
```

### Example 2
```example
sparse_matrix_transform(zy=0.5){
    cylinder(r=5, h=20);
}
```
*/
module sparse_matrix_transform(xx=1, yy=1, zz=1, xy=0, xz=0, yx=0, yz=0, zx=0, zy=0, xt=0, yt=0, zt=0){
    //Apply a matrix transformation, specifying the matrix sparsely
    //This is useful because most helpful matrices are close to the identity.
    matrix = [[xx, xy, xz, xt],
              [yx, yy, yz, yt],
              [zx, zy, zz, zt],
              [0,  0,  0,  1]];
    multmatrix(matrix){
        children();
    }
}

/* Hull each adjacent pair of children in sequence.
 
This allows the construction of relatively complicated shapes, by "hulling" between
pairs of objects.  It must have at least two child modules, though it becomes useful
when you have more.

### Example 1
```example
// Using it in conjunction with a sequence of spheres, for example, will
// create a wire that passes each point.
sequential_hull(){
    $fn=8;
    translate([0, 0, 0]) sphere(2);
    translate([0, 0, 15]) sphere(2);
    translate([15, 0, 15]) sphere(2);
    translate([0, 15, 15]) sphere(2);
}
```

### Example 2
```example
sequential_hull(){
    translate([0, 0, 0]) cylinder(r=2, h=tiny());
    translate([0, 0, 5]) cylinder(r=4, h=tiny());
    translate([0, 0, 7]) cylinder(r=2, h=tiny());
    translate([0, 0, 10]) cylinder(r=6, h=3);
    translate([0, 0, 20]) cylinder(r=2, h=tiny());
}
```
*/
module sequential_hull(){
    //given a sequence of >2 children, take the convex hull between each pair - a helpful, general extrusion technique.
    for(i=[0:$children-2]){
        hull(){
            children(i);
            children(i+1);
        }
    }
}

/* Round off external corners of 2D geometry.

Applies a positive-radius offset followed by a negative one, smoothing
convex (outer) corners of the shape.

:param r: Fillet radius, must be positive
*/
module convex_fillet(r){
    offset(r){
        offset(-r){
            children();
        }
    }
}

/* Round off internal corners of 2D geometry.

Applies a negative-radius offset followed by a positive one, smoothing
concave (inner) corners of the shape.

:param r: Fillet radius, must be positive
*/
module concave_fillet(r){
    offset(-r){
        offset(r){
            children();
        }
    }
}

/* Create a solid 3D section by projecting and extruding child geometry.

Projects the child geometry onto the xy-plane and linearly extrudes it by a
small thickness `h`. Useful for generating a printable "cross-section"
from geometry that intersects z=0.

:param h: Height of the resulting section (default: `tiny()`)  
:param center: If true, the resulting section is centred in z  
:param shift: If true the projection is a tiny distance above z=0

### Example
```example
thick_section(h=1){
    rotate([90, 0, 0]){
        cylinder(r=5, h=10);
    }
}
```
*/
module thick_section(h=tiny(), center=false, shift=true){
    offset_thick_section(h=h, center=center, shift=shift){
        children();
    }
}

/* Create an offset, extruded 3D projection of child geometry.

Projects the child geometry onto the xy-plane, optionally applies an offset
to enlarge or shrink the result, and extrudes to give a solid section.

If `shift` is true, geometry is slightly lowered before projection to ensure
a clean intersection with z=0.

:param h: Height of the extrusion (default: `tiny()`)  
:param offset: Offset radius applied to the projection (positive or negative)  
:param center: If true, extrusion is centred on the z-axis  
:param shift: If true, geometry is shifted below z=0 before projection so the cut is
    a tiny distance above z=0

### Example
```example
offset_thick_section(h=1, offset=0.5){
    rotate([90, 0, 0]){
        cylinder(r=5, h=10);
    }
}
```
*/
module offset_thick_section(h=tiny(), offset=0, center=false, shift=true){
    linear_extrude(h, center=center){
        offset(r=offset){
            flatten(shift){
		children();
            }
        }
    }
}

/* Create a printable horizontal hole with a sloped overhang.

Generates a horizontal cylindrical hole with a top block that forms a
45 degree printable slope. This shape is designed to be subtracted from
solids to create holes that print cleanly without support.

:param h: length of the hole along its axis  
:param r: radius of the cylindrical hole  
:param center: whether to centre the hole on its axis  
:param extra_height: extra height for the printable roof above the hole

### Example
```example
difference(){
    cube([20, 10, 10], center=true);
    translate([0, 0, 0]){
        printable_horizontal_hole(h=20, r=3);
    }
}
```
*/
module printable_horizontal_hole(h,r,center=false,extra_height=0.7){
    top_block_dims = [2*sin(45/2)*r, 2*tiny(), h];
    top_block_z = center ? 0 : h/2;
    top_block_tr = [0, r-tiny(), top_block_z];
    union(){
        rotate([90,0,180]){
            hull(){
                cylinder(h=h,r=r,center=center);
                translate(top_block_tr){
                    cube(top_block_dims, center=true);
                }
            }
            translate(top_block_tr){
                cube(top_block_dims + [0, 2*extra_height, 0], center=true);
            }
        }
    }
}

/* Create a stepped transition from square to circle.

Builds a stack of cylinders with increasing facet counts, starting from a
square cross-section and ending in a near-circle. An optional top cylinder
can be added to cap the structure.

:param r: radius of the resulting circular top  
:param h: total height of the transition (excluding top cylinder)  
:param layers: number of transition layers.  Each layer will have a height of `h/layers`
:param top_cylinder: height of optional final circular cylinder. The top cylinder will
    have the same number of facets as the final layer, and the whole structure will
    have a height of `h + top_cylinder`.
*/ 
module square_to_circle(r, h, layers=4, top_cylinder=0){
    // A stack of thin shapes, starting as a square and
    // gradually gaining sides to turn into a cylinder
    sides=[4,8,16,32,64,128,256]; //number of sides
    for(i=[0:(layers-1)]){
        rotate(180/sides[i]){
            translate_z(i*h/layers){
                cylinder(r=r/cos(180/sides[i]),h=h/layers+tiny(),$fn=sides[i]);
            }
        }
    }

    if(top_cylinder>0){
        translate_z(tiny()){
            cylinder(r=r,h=h+top_cylinder, $fn=sides[layers-1]);
        }
    }
}

/* Create a cylinder gradually formed from a slot or square at the base.

This module creates a hole starting with a bridging slot at the bottom,
progressing to a square, then gradually filling corners to form a cylinder.

It helps remove the need for support when printing holes through the roof over a void.

The first layer is crucial. This should be a slot, spanning the full width of the void.
Slicers will be able to correctly bridge across the void, parallel to the slot. 

Once the void is bridged with a slot for the hole, the next layer will leave a square
hole. This should mean the printer bridges over the slot in the layer(s) below,
perpendicular to the edges. Subsequent layers will then fill in the corners, until 
the hole is cylindrical.

`base_w` is the width of th initial slot, it can be carefully calculated so the geometry
can just be subtract this from the "roof" over a void. However, it is often easier to
set `base_w=999` and `big_bottom=true`, then take the intersection with the void to be
bridged to trim the slot to size (see example).

:param r: Radius of the cylinder  
:param h: Height of the cylinder  
:param base_w: Width of the slot at the bottom; defaults to `2*r` if left at `-1` 
:param delta_z: Thickness of each intermediate layer  
:param layers: Number of steps between square and cylinder  
:param big_bottom: If true, adds a large volume below z=0 for easy intersection  

### Example 1: A cutaway
```example render
difference(){
    translate([-10, -10, 0]){
        cube(20);  // Base structure
    }

    intersection(){
        cylinder(r=8, h=999, center=true);  // The void

        // Position hole_from_bottom to set void height
        translate([0,0,10]){
            hole_from_bottom(r=2, h=999, base_w=999, big_bottom=true);
        }
    }

    // Cut through structure to see inside
    rotate(225){
        translate([-99, 0, -1]){
            cube(999);
        }
    }
}
```

### Example 2: 2D slices
```example render
module example_1(){
    difference(){
        translate([-10, -10, 0]){
            cube(20);
        }

        intersection(){
            cylinder(r=8, h=999, center=true);
            translate([0,0,10]){
                hole_from_bottom(r=2, h=999, base_w=999, big_bottom=true);
            }
        }
    }
}

// Render slices through example_1
for(i = [0:3]){
    z = 9.75 + 0.5*i;
    translate([i*25, 0, 0]){
        projection(cut=true){
            translate([0,0,-z]){
                example_1();
            }
        }
    }
}
```

### Example 3: no big bottom
```example
hole_from_bottom(r=2, h=10, base_w=10, big_bottom=false);
```

### Example 4: with big bottom
```example
// Set viewport for example
$vpt = [-5,11,-5];
$vpr = [60,0,30];
$vpd = 70;
hole_from_bottom(r=2, h=10, big_bottom=true);
```

See also: `square_to_circle()`
*/
module hole_from_bottom(r, h, base_w=-1, delta_z=0.5, layers=4, big_bottom=true){

    base = base_w>0 ? [base_w,2*r,2*delta_z] : [2*r,2*r,tiny()];
    union(){
        cube(base,center=true);
        translate_z(base.z/2-tiny()){
            square_to_circle(r, delta_z*4, layers, h-delta_z*5+tiny());
        }
        if(big_bottom){
            mirror([0,0,1]){
                cylinder(r=999,h=999,$fn=8);
            }
        }
    }
}


/* Determine the number of fragments (points) around a circle.

Reproduces OpenSCAD's behaviour of setting the number of points
based on these special variables:

- `$fa`: minimum angle per fragment (degrees)  
- `$fs`: minimum fragment length  
- `$fn`: exact number of fragments (overrides others if > 0)  

Logic based on OpenSCAD docs:
https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Other_Language_Features#Special_variables

:param r: Radius of the circle  
:return: Number of points to use around the circle  
*/
function determine_number_of_fragments(r) = let(
    n_points_from_fa = ceil(360/$fa),
    n_points_from_fs = ceil(r*2*PI/$fs),
    default_n_points = max(min(n_points_from_fa, n_points_from_fs),5), // use minimum size or maximum angle
    n_points = max($fn>0?$fn:default_n_points, 3) // $fn takes precedence, with minimum of 3
) n_points;

/* Create a triangular prism with filleted corners.

One side is parallel to the x-axis.

The largest cylinder that fits inside has radius `r + flat/(2*sqrt(3))`.

:param r: Radius of the fillet cylinders
:param flat: Length of the flat sides of the prism
:param h: Height of the prism (default tiny())
:param center: Whether the prism is centered along the height axis
*/
module trylinder(r=1, flat=1, h=tiny(), center=false){
    hull(){
        for(a=[0,120,240]){
            rotate(a){
                translate_y(flat/sqrt(3)){
                    cylinder(r=r, h=h, center=center);
                }
            }
        }
    }
}

/* Create a trylinder suitable for self-tapping machine screws.

The size is intentionally oversized for small holes to compensate for
inaccuracies in 3D printing.

## This module is deprecated.

Use explicitly defined holes such as m4_selftap_hole for screws M4 and above. However,
M4 will be deprecated soon too.

Consider using nut traps or self tapping screws rather than tapping machine screws into
trylinder holes.

:param nominal_d: Nominal screw diameter
:param h: Height of the trylinder
:param center: Whether to center the shape along the height axis
*/
module trylinder_selftap(nominal_d=3, h=10, center=false){
    // Make a trylinder that you can self-tap a machine screw into.
    // The size is deliberately a bit big for small holes, so that
    // it compensates for splodgy printing
    echo("Warning: `trylinder_selftap` is no longer recommended for use.");
    echo("Use explicitly defined holes such as `m4_selftap_hole` for screw sizes M4 and above.");
    echo("Use explicit holes for self tap screws, such as `no2_selftap_hole`");
    echo("For machine screws smaller than M4 use nut traps to avoid thread stripping.");
    r = max(nominal_d*0.8/2 + 0.2, nominal_d/2 - 0.2);
    dr = 0.5;
    flat = dr * 2 * sqrt(3);
    trylinder(r=r - dr, flat=flat, h=h, center=center);
}

/* Create a tapering, distorted hollow cylinder for gripping small cylindrical or spherical objects.

The gripping zone is at grip_h above the base, flaring out above and below this zone.

:param inner_r: Radius of the cylinder to grip
:param h: Overall height of the gripper
:param grip_h: Height at which the gripper contacts the cylinder
:param base_r: Radius of the bottom cylinder (if negative, defaults to `inner_r + 1 + t`)
:param t: Wall thickness
:param squeeze: Amount of wall distortion to fit the cylinder
:param flare: How much larger the top is compared to the gripping part
:param solid: If true, produce a solid outline of the gripper
*/
module trylinder_gripper(inner_r=10,h=6,grip_h=3.5,base_r=-1,t=0.65,squeeze=1,flare=0.8,solid=false){
    $fn=48;
    bottom_r=base_r>0?base_r:inner_r+1+t;

    //TODO: reduce repition
    difference(){
        sequential_hull(){
            cylinder(r=bottom_r,h=tiny());
            translate_z(grip_h-0.5){
                trylinder(r=inner_r-squeeze+t,flat=2.5*squeeze,h=tiny());
            }
            translate_z(grip_h+0.5){
                trylinder(r=inner_r-squeeze+t,flat=2.5*squeeze,h=tiny());
            }
            translate_z(h-tiny()){
                trylinder(r=inner_r-squeeze+flare+t,flat=2.5*squeeze,h=tiny());
            }
        }
        if(solid==false){
            sequential_hull(){
                translate_z(-tiny()){
                    cylinder(r=bottom_r-t,h=tiny());
                }
                translate_z(grip_h-0.5){
                    trylinder(r=inner_r-squeeze,flat=2.5*squeeze,h=tiny());
                }
                translate_z(grip_h+0.5){
                    trylinder(r=inner_r-squeeze,flat=2.5*squeeze,h=tiny());
                }
                translate_z(h){
                    trylinder(r=inner_r-squeeze+flare,flat=2.5*squeeze,h=tiny());
                }
            }
        }
    }
}

/* Create a cylinder with feathered edges to make a slightly deformable hole.

The shape is built from stacked layers combining a cylinder and a trylinder
for feathered edges.

:param r1: Inner radius  
:param r2: Outer radius  
:param h: Height of the cylinder  
:param corner_roc: Radius of curvature of the trylinder edges (optional)  
:param delta_z: Thickness of each layer  
:param center: Center the shape vertically (default false)  
*/
module deformable_hole_trylinder(r1, r2, h=99, corner_roc=undef, delta_z=0.5, center=false){
    n = floor(h/(2*delta_z)); //number of layers in the structure
    flat_l = 2*sqrt(r2*r2 - r1*r1);
    default_corner_radius = r1 - flat_l/(2*sqrt(3));
    corner_radius = if_undefined_set_default(corner_roc, default_corner_radius);
    repeat([0,0,2*delta_z], n, center=center){
        union(){
            cylinder(r=r2, h=delta_z+tiny());
            translate_z(center ? -delta_z : delta_z){
                trylinder(r=corner_radius, flat=flat_l, h=delta_z+tiny());
            }
        }
    }
}

/* Add a brim around the outside of an object *only*, preserving holes.

The brim is created by offsetting and then inset operations, so it
does *not* go into tight internal corners. This is important for
delicate shapes where preserving internal detail is needed.

:param r: Brim width  
:param h: Brim height  
:param brim_only: If true, only render the brim, not the original object  
:param smooth_r: Smoothing radius for the brim edges (defaults to r)  

*/
module exterior_brim(r=4, h=0.2, brim_only=false, smooth_r=undef){
    // Add a "brim" around the outside of an object *only*, preserving holes in the object
    // brim width r and the smoothing smooth_r can be defined separately, but default to equal

    _smooth_r = is_undef(smooth_r) ? r : smooth_r;

    if (!brim_only){
        children();
    }

    if(r > 0){
        linear_extrude(h){
            difference(){
                offset(r){
                    offset(-_smooth_r){
                        offset(_smooth_r){
                            flatten(){
                                children();
                            }
                        }
                    }
                }
                offset(-_smooth_r+tiny()){
                    offset(_smooth_r){
                        flatten(){
                            children();
                        }
                    }
                }
            }
        }
    }
}

/* Apply both convex and concave fillets to round all corners.

:param r: Radius of the fillet
*/
module fillet_2d(r=3)
{
    convex_fillet(r=r){
        concave_fillet(r=r){
            children();
        }
    }
}

/* Create a column smoothly transitioning from a circular base to a square top.

This allows a circular base for better bed adhesion, transitioning into a square
column over a specified height. The size can be defined by diameter `d` or radius `r`.
The transition height can be set independently of the column height; if undefined,
the transition spans almost the entire height.

:param d: Diameter of the base circle and side length of the square top.
    Takes precedence over `r` if both are defined.
:param r: Radius of the base circle (half the side length of the square top).
    Ignored if `d` is defined.
:param h: Overall height of the column.
:param transition: Height over which the transition from circle to square happens.
    Defaults to nearly the full height.
*/
module cylinder_to_square_column(d=undef, r=undef, h=undef, transition=undef){
    _r = if_undefined_set_default(r, 0.5);
    _d = if_undefined_set_default(d, 2*_r);
    _h = if_undefined_set_default(h, 1);
    _transition = if_undefined_set_default(transition, _h-0.01);
    assert(_transition<_h,"Transition length must be shorter than the column height");
    _thin = _h - _transition ;
    hull(){
        cylinder(d=_d,h=_thin);
        translate([-_d/2,-_d/2,_h-_thin]){
            cube([_d,_d,_thin]);
        }
    }
}

/* Create a cube that is rounded on top and flat on the bottom

:param dimensions: `[x, y, z]` dimensions of cube
:param rounding_radius: The corner radius.
:param center: If `true` places at center in xy, but still the base is at z=0
*/
module round_top_cube(dimensions, rounding_radius, center=false){
    corner_x = dimensions.x/2 - rounding_radius;
    corner_y = dimensions.y/2 - rounding_radius;
    height = dimensions.z - rounding_radius;
    corners = [
        [corner_x, corner_y, 0],
        [-corner_x, corner_y, 0],
        [corner_x, -corner_y, 0],
        [-corner_x, -corner_y, 0]
    ];
    trans = (center)? [0,0,0] : [dimensions.x/2, dimensions.y/2, 0];
    translate(trans){
        hull(){
            for (i = [0:3]){
                translate(corners[i]){
                    cylinder(r=rounding_radius, h=height);
                    translate_z(height){
                        sphere(r=rounding_radius);
                    }
                }
            }
        }
    }
}

/* Create a 2D projection-cut through z=0 or very slightly above.

:param shift: If `true` the object is shifted down by `tiny()` before cutting at z=0
*/
module flatten(shift=true){
    projection(cut=true){
        translate_z(shift ? -tiny() : 0){
            children();
        }
    }
}
