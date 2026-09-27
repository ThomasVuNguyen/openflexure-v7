/*

Some sketches to work towards a nicer dovetail mechanism in OpenSCAD.

(c) Richard Bowman 2021, released under CERN-OHL-W v2

*/

/*
Conversion notes:

I swapped from lookup functions to regular dicts with a regex
p\("([a-z_]+)"\)
replace with
key_lookup("$1", p)

 functions renamed to old names
ofu_ -> ""
*/

use <./libdict.scad>
use <./utilities.scad>

function dovetail_default_params() = [
    ["depth", 4],            // y distance between outer flat surface and tip
    ["angle", 60],           // angle of sloping part
    ["outer_flat", 6],       // width of outer flat parts
    ["overall_width", 30],   // width of whole structure
    ["overall_height", 16],  // height of whole structure
    ["block_depth", 12],     // y size of mounting block
    ["fillet_r", 0.5],       // fillet radius for rounded corners
    ["relief_r", 0.7],       // fillet radius for rounded corners
    ["lever", 8],            // distance from flat surface to pivot of clamp
    ["flex_l", 4],           // length of clamp flexure
    ["flex_t", 1.6],         // thickness of above
    ["clamp_t", 9],          // thickness of clamping flange, in the direction of the bolt
    ["top_t", 2],            // thickness of the top solid layer
    ["bottom_t", 2],         // thickness of the bottom solid layer
    ["vertical_gap", 1],     // gap between clamp and top/bottom layers
    ["clamp_support_t", 0.5],// thickness of internal bridge support for clamp
    ["clamp_angle", 7],      // angle through which we allow the clamp to bend
    ["pinch_bolt_inset", 2], // distance from centre of clamping bolt to female point
    ["taper_block", false],  // set this to true to taper the block parallel to the flanges
    ["nut_slot_slope", "up"] // set the nut slot to slope up from the nut. The other allowed value is "down"
];

function dovetail_params(
    // This is an experiment in how to handle the commonly-changed parameters more nicely
    overall_height=16,
    overall_width=30,
    block_depth=12,
    taper_block=false,
    nut_slot_slope = "up",
    depth=4
) = replace_multiple_values(
    [
        ["overall_height", overall_height],
        ["overall_width", overall_width],
        ["block_depth", block_depth],
        ["taper_block", taper_block],
        ["nut_slot_slope", nut_slot_slope],
        ["depth", depth]
    ],
    dovetail_default_params()
);

function dovetail_back_width(p) = let(
    w = key_lookup("overall_width", p),
    depth = key_lookup("block_depth", p),
    angle = key_lookup("angle", p),
    taper_block = key_lookup("taper_block", p),
    tapered_width = w - 2*tan(90-angle)*depth
) taper_block ? tapered_width : w;


module block_sharp(p){
    // the block to which we attach the male dovetail
    // or from which we cut the female one

    w = key_lookup("overall_width", p);
    depth = key_lookup("block_depth", p);
    back_w = dovetail_back_width(p);
    polygon([
        [     -w/2,      0],
        [      w/2,      0],
        [ back_w/2, -depth],
        [-back_w/2, -depth],
    ]);
}
module back_of_block_2d(p){
    // the back of the block to which we attach the male dovetail
    // or from which we cut the female one

    depth = key_lookup("block_depth", p);
    angle = key_lookup("angle", p);
    back_w = dovetail_back_width(p);
    fillet_r = key_lookup("fillet_r", p);

    hull(){
        reflect_x(){
            x_tr = back_w/2 - fillet_r*tan(angle/2);
            y_tr = -depth + fillet_r;
            translate([x_tr, y_tr]){
                circle(r=fillet_r);
            }
        }
    }
}

module flange_r(p, width=tiny()){
    // the angled part of a male dovetail

    shiftx = [-width, 0];
    // we extend the parallelogram into the block slightly,
    // at the same angle.
    shift_in = tiny()*[-cos(key_lookup("angle", p)), -sin(key_lookup("angle", p))];

    polygon([
        female_point(p) + shift_in,
        male_point(p),
        male_point(p) + shiftx,
        female_point(p) + shiftx + shift_in
    ]);
}

function male_point(p) = let(
    w = key_lookup("overall_width", p),
    flat = key_lookup("outer_flat", p),
    depth = key_lookup("depth", p),
    angle = key_lookup("angle", p)
) [w/2 - flat + depth/tan(angle), depth];

function female_point(p) = let(
    w = key_lookup("overall_width", p),
    flat = key_lookup("outer_flat", p)
) [w/2 - flat, 0];

module dovetail_section_m_sharp(p){
    // A male dovetail, before any filleting of the corners
    difference(){
        union(){
            block_sharp(p);

            hull(){
                reflect([1, 0]){
                    flange_r(p);
                }
            }
        }

        // relieve internal corners
        reflect([1, 0]){
            translate(female_point(p)){
                circle(key_lookup("relief_r", p));
            }
        }
    }
}

module solid_male_dovetail(p, height=undef){
    // Cut this shape out of a block with a face at y=0 to make
    // a dovetail
    h = is_undef(height) ? key_lookup("overall_height", p) : height;
    linear_extrude(h){
        // The male dovetail
        male_dovetail_2d(p);
    }
}


module male_dovetail_2d(p){
    // Used to create the female cut out. Can also be used on its own
    // for a non-locking dovetail
    hull(){
        reflect([1, 0]){
            mirror([0,1]){
                flange_r(p);
            }
        }
    }
}

module dovetail_section_f_sharp_cutout(p){
    // We cut this shape out of a block to make the female cutout

    // The male dovetail
    male_dovetail_2d(p);

    // relieve internal corners
    hull(){
        reflect([1, 0]){
            translate(-male_point(p)){
                circle(key_lookup("relief_r", p));
            }
        }
    }
}

module dovetail_section_f_sharp(p){
    // A female dovetail, before any filleting of the corners
    difference(){
        block_sharp(p);
        dovetail_section_f_sharp_cutout(p);
    }
}

module rotate_repeat(angle){
    union(){
        children();
        rotate(angle){
            children();
        }
    }
}

module clamp_frame(p){
    // place the origin at the pivot point of the clamp
    // and align y axis with the dovetail angle
    translate(female_point(p)){
        rotate(key_lookup("angle", p) - 90){
            translate([0, -key_lookup("lever", p)]){
                children();
            }
        }
    }
}

module clamp_cutout_2d(p){
    // 2D cutout to make a male dovetail clamp
    fillet_r = key_lookup("fillet_r", p);
    lever = key_lookup("lever", p);
    flex_l = key_lookup("flex_l", p);
    flex_t = key_lookup("flex_t", p);
    clamp_t = key_lookup("clamp_t", p);
    clamp_angle = key_lookup("clamp_angle", p);
    $fn=16;
    clamp_frame(p){
        // between nut and screw
        hull(){
            translate([0, fillet_r + flex_t/2]){
                circle(fillet_r);
            }
            translate([0, lever]){
                circle(fillet_r);
            }
        }
        // next to flexure
        hull(){
            reflect([1,0]){
                translate([flex_l/2, fillet_r + flex_t/2]){
                    circle(fillet_r);
                }
            }
        }
        // behind clamp
        sequential_hull(){
            // start next to the flexure
            translate([flex_l/2, -fillet_r - flex_t/2]){
                circle(fillet_r);
            }
            // duplicate the corner point to allow it to bend
            rotate_repeat(clamp_angle){
                translate([-clamp_t, -fillet_r - flex_t/2]){
                    circle(fillet_r);
                }
            }
            // don't use the second corner point, to avoid shortening the clamping part
            // because of cosine error
            translate([-clamp_t, -fillet_r - flex_t/2]){
                circle(fillet_r);
            }
            // a far-away, wider point, so the opening is wedge-shaped.
            rotate_repeat(clamp_angle){
                translate([-clamp_t, 99]){
                    circle(fillet_r);
                }
            }
        }
    }
}
module clamp_cutout_empty_2d(p){
    // 2D cutout to make a male dovetail clamp
    union(){
        clamp_cutout_2d(p);

        // take the hull of just the internal part
        hull(){
            intersection(){
                clamp_cutout_2d(p);
                hull(){
                    repeat([-99, 0], 2, center=false){
                        clamp_frame(p){
                            reflect([0, 1]){
                                translate([0, key_lookup("lever", p)]){
                                    circle(key_lookup("relief_r", p));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

module clamp_cutout_base_2d(p){
    // 2D cutout to separate the point of the clamp from the base
    relief_r = key_lookup("relief_r", p);

    union(){
        // separate the flange from the block
        hull(){
            translate(female_point(p)){
                circle(relief_r);
                clamp_t = key_lookup("clamp_t", p);
                angle = key_lookup("angle", p);
                translate([-clamp_t/sin(angle), 0]){
                    circle(relief_r);
                }
            }
        }

        // take the hull of just the external part
        intersection(){
            clamp_cutout_2d(p);
            hull(){
                reflect([1, 0]){
                    translate(female_point(p)){
                        circle(key_lookup("relief_r", p));
                        translate([0, 99]){
                            circle(key_lookup("relief_r", p));
                        }
                    }
                }
            }
        }
    }
}
module clamp_back_2d(p, extra_left=0, extra_right=0, extra_top=0){
    // back of the internal part of the clamp
    // extra_l and extra_r add additional length on
    // the left/right respectively.  By default (0),
    // the part matches the size of the external part
    // of the clamp (i.e. it's in line with female_point)
    length = (
        key_lookup("clamp_t", p) -
        key_lookup("fillet_r", p) +
        extra_left +
        extra_right
    );
    clamp_frame(p){
        translate([-length + extra_right, -key_lookup("flex_t", p)/2]){
            square([length, key_lookup("flex_t", p) + extra_top]);
        }
    }
}

module clamping_flange_2d(p){
    // 2D shape of the part of the flange that moves
    dovetail_convex_fillet(p){
        difference(){
            union(){
                hull(){
                    // Note: this is defined in x, not in the clamp_frame.
                    clamp_t = key_lookup("clamp_t", p);
                    fillet_r = key_lookup("fillet_r", p);
                    angle = key_lookup("angle", p);
                    flange_width = (clamp_t - fillet_r)/sin(angle);
                    // external end
                    flange_r(p, width= flange_width);
                    // internal end
                    clamp_back_2d(p); // NB this gets cut by clamp_cutout_2d
                }

                extra_right=key_lookup("flex_l", p)/2 + key_lookup("fillet_r", p);
                // to avoid fouling the fillet
                extra_left=-key_lookup("fillet_r", p);
                // add the flexure to join to the block.
                clamp_back_2d(p, extra_right=extra_right, extra_left=extra_left);
            }

            clamp_cutout_2d(p);
        }
    }
}

module clamping_flange(p){
    // The moving part that makes the right hand flange
    // clamp the female dovetail
    gap = key_lookup("vertical_gap", p);
    bottom = key_lookup("bottom_t", p) + gap + key_lookup("clamp_support_t", p);
    top = key_lookup("overall_height", p) - gap - key_lookup("top_t", p);
    translate_z(bottom){
        linear_extrude(top - bottom){
            clamping_flange_2d(p);
        }
    }
}

module clamping_bolt_and_nut(p){
    // The counterbored screw and nut that clamp the dovetail
    h = key_lookup("overall_height", p);
    // Place the clamping bolt relative to the female point
    clamp_y = key_lookup("lever", p) - key_lookup("pinch_bolt_inset", p);
    fillet_r = key_lookup("fillet_r", p);
    clamp_t = key_lookup("clamp_t", p);
    // Boolean, true of block is tapered to have a face perpendicular to the screw.
    // if not it needs a counterbore.
    tapered = key_lookup("taper_block", p);
    // The nut slot should slope up from the nut in use, so that the nut does not 
    // slip out when the screw is removed, nut_slot_slope set to 'up'. If the 
    // dovetail is inverted after printing for use set nut_slot_slope to 'down' 
    nut_rotation = key_lookup("nut_slot_slope",p) == "down"?
                                        120:
                                        60;
    // We place everything relative to
    clamp_frame(p){
        translate([0, clamp_y, h/2]){
            $fn = 16;
            // Hole for screw (in solid block)
            rotate_y(90){
                cylinder(d=3*1.2, h=99);
                // If not tapered, add counterbore large enough for an M3 washer
                if (!tapered){
                    translate([0,0,fillet_r + 4]){
                        cylinder(d=7.5, h=99);
                    }
                }
            }
            // Nut trap, with angled entry (in the clamp)
            rotate_y(-90){
                cylinder(d=3*1.2, h=clamp_t); //shaft of the screw
                translate_z( fillet_r + 2){
                    // The rotation below means the nut slides in at an angle, rather 
                    // than horizontally.  This is important: it ensures that the nut
                    // is retained by a ring of plastic within one layer, rather than
                    // relying on inter-layer adhesion (which is weaker).
                    // The entry slot should not be made horizontal without testing
                    // carefully for strength.
                    rotate_z(nut_rotation){
                        sequential_hull(){
                            m3_nut_hole(h=3.2, shaft=false);
                            translate_x(99){
                                m3_nut_hole(h=3.2, shaft=false);
                            }
                        }
                    }
                }
            }
        }
    }
}

module clamp_support(p){
    // a bridge to support the internal part of the clamp
    gap = key_lookup("vertical_gap", p);
    bottom = key_lookup("bottom_t", p) + gap;
    support_t = key_lookup("clamp_support_t", p);
    fillet_r = key_lookup("fillet_r", p);

    // bridge the bottom of the flexure right across the gap
    translate_z(bottom){
        linear_extrude(support_t){
            // a bridge to support the internal part of the clamp
            // this sits underneath the back of the clamp
            extra_left=3*key_lookup("fillet_r", p);
            extra_right=key_lookup("flex_l", p)/2 + tiny();
            clamp_back_2d(p, extra_left=extra_left, extra_right=extra_right);
        }
    }

    // bridge the bottom layer of the cut-out next to the flexure
    translate_z(bottom + support_t){
        linear_extrude(support_t){
            // a bridge to support the internal part of the clamp
            // this sits underneath the back of the clamp
            clamp_back_2d(p, extra_left=-fillet_r, extra_right=-fillet_r, extra_top=3*fillet_r);
        }
    }
}

module dovetail_convex_fillet(p){
    // smooth the convex corners
    $fn=12;

    convex_fillet(key_lookup("fillet_r", p)){
        children();
    }
}

module dovetail_concave_fillet(p){
    // smooth the concave corners
    $fn=12;
    concave_fillet(key_lookup("fillet_r", p)){
        children();
    }
}


module dovetail_section_m(p, relief=true){
    dovetail_convex_fillet(p){
        dovetail_section_m_sharp(p, relief=relief);
    }
}

module undercut_male_dovetail(p){
    // Chamfer the bottom of the mating faces to avoid
    // wonkiness due to "elephant's foot" issues
    minkowski(){
        mirror([0,1,0]){
            linear_extrude(tiny()){
                dovetail_section_f_sharp(p);
            }
        }

        cylinder(r1=2, r2=tiny(), h=2, $fn=16, center=true);
    }
}

module dovetail_clamp_m(p){
    // male dovetail with clamping arm
    //
    // NOTE: The clamp is designed with internal bridging that 
    // only works when printed in the orientation
    // given here.
    // There is an undercut on the mating surfaces to make sure that 
    // overextrusion or remnants of brim do not foul the mating surface
    // If the clamp is used the other way up after printing, then 
    // in set nut_slot_slope to 'down' the parameter dictionary p. 
    h = key_lookup("overall_height", p);
    difference(){
        union(){
            difference(){
                linear_extrude(h){
                    dovetail_convex_fillet(p){
                        difference(){
                            dovetail_section_m_sharp(p);
                            clamp_cutout_base_2d(p);
                        }
                    }
                }

                // void for clamp
                translate_z(2){
                    linear_extrude(h-4){
                        dovetail_concave_fillet(p){
                            clamp_cutout_empty_2d(p);
                        }
                    }
                }
            }

            // clamping flange
            clamping_flange(p);
            clamp_support(p);
        }
        clamping_bolt_and_nut(p);

        // work around "elephant's foot"/brim on mating faces
        undercut_male_dovetail(p);
    }
}



module dovetail_f(p, height=undef){
    // A female dovetail, existing in y<0 with mating face at y=0
    h = is_undef(height) ? key_lookup("overall_height", p) : height;
    linear_extrude(h){
        dovetail_convex_fillet(p){
            dovetail_section_f_sharp(p);
        }
    }
}

module dovetail_f_cutout(p, height=undef){
    // Cut this shape out of a block with a face at y=0 to make
    // a dovetail
    h = is_undef(height) ? key_lookup("overall_height", p) : height;
    w = key_lookup("overall_width", p);
    linear_extrude(h){
        dovetail_concave_fillet(p){
            union(){
                dovetail_section_f_sharp_cutout(p);
                translate([-w/2, tiny()]){
                    square([w, 99]);
                }
            }
        }
    }
}

module dovetail_block(p, height=undef){
    // A 3D block, filleted as the dovetail would be
    h = is_undef(height) ? key_lookup("overall_height", p) : height;
    linear_extrude(h){
        dovetail_convex_fillet(p){
            block_sharp(p);
        }
    }
}
