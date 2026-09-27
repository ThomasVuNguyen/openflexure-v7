/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Dovetail                                *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file deals with the dovetail clips that are used to hold   *
* the objective and illumination, and provide coarse Z adjustment.*
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <./utilities.scad>
$fn=16;


module dovetail_clip_cutout(size,dt=1.5,t=2,slope_front=0,solid_bottom=0){
    // This will form a female dovetail when subtracted from a block.
    // cut this out of a cube (of size "size", with one edge centred along
    // the X axis extending into +y, +z
    //
    // dt sets the size of the 45-degree clips
    // t sets the thickness of the dovetail arms (2mm is good)
    // slope_front cuts off the bottom of the ends of the arms, i.e.
    //   the part that does the gripping starts above Z=0.  This can
    //   avoid the splodginess that comes from the bottom few layers,
    //   and make it print much better - useful if you want to insert
    //   things from the bottom.
    // solid_bottom joins the bottoms of the arms with a thin layer.
    //   this can help it stick to the print bed.
    //
    // I reccommend using ~8-10mm arms for a tight fit.  On all my
    // printers, the ooze of the plastic is enough to keep it tight, so I
    // set the size of the M and F dovetails to be identical.  You might
    // want to make it tighter, either by increasing dt slightly or by
    // decreasing the size slightly (in both cases, of this, the female
    // dovetail).
    // NB that it starts at z=-tiny() and stops at z=size.z+tiny() to make
    // it easy to subtract from a block.

    cutout_bottom = solid_bottom > 0 ? solid_bottom+tiny() : -tiny();
    inner_w = size.x - 2*t; // width between arms

    hull(){
        reflect_x(){
            translate([-size.x/2+t,0,cutout_bottom]){
                translate([dt,size.y-dt,0]){
                    cylinder(r=dt,h=size.z+2*tiny(),$fn=16);
                }
                translate_y(dt){
                    rotate(-45){
                        cube([dt*2,tiny(),size.z+2*tiny()]);
                    }
                }
            }
        }
    }

    //sloped bottom to improve quality of the dovetail clip and
    //allow insertion of the male dovetail from the bottom
    if(slope_front>0){
        //slope up arms
        rotate_x(45){
            cube([999,1,1]*sqrt(2)*slope_front,center=true);
        }
        //also, slope in the dovetail tooth to avoid marring at the bottom:
        hull(){
            reflect_z(){
                translate_z(slope_front){
                    rotate_y(45){
                        cube([(inner_w)/sqrt(2),dt*2,inner_w/sqrt(2)],center=true);
                    }
                }
            }
        }
    }
}

module dovetail_clip(size=[10,2,10],dt=1.5,t=2,back_t=0,slope_front=0,solid_bottom=0){
    // This forms a clip that will grip a dovetail, with the
    // contact between the m/f parts in the y=0 plane.
    // This is the female part, and it is centred in X and
    // extends into +y, +z.
    // The outer dimensions of the clip are given by size.
    // dt sets the size of the clip's teeth, and t is the
    // thickness of the arms.  By default it has no back, and
    // should be attached to a solid surface.  Specifying back_t>0
    // will add material at the back (by shortening the arms).
    // slope_front will add a sloped section to the front of the arms.
    // this can improve the quality of the bottom of the dovetail
    // (good if you're inserting from the bottom)
    // solid_bottom will join the arms together at the bottom, which
    // can help with bed adhesion.
    // see dovetail_clip_cutout - most of the options are just passed through.
    difference(){
        translate_x(-size.x/2){
            cube(size);
        }
        dovetail_clip_cutout(size-[0,back_t+tiny(),0],
                             dt=dt,
                             t=t,
                             slope_front=slope_front,
                             solid_bottom=solid_bottom);
    }
}

module loop_over_zx_profile(zx_profile, corner_x){
    // Module to loop over the zx_profile. Use to avoid repition in
    // dovetail plug

    for(i=[0:len(zx_profile)-2]){
        hull(){
            for(j=[0:1]){
                z = zx_profile[i+j][0];
                x = zx_profile[i+j][1];
                reflect_x(){
                    translate([corner_x+x,0,z]){
                        rotate(45){
                            children();
                        }
                    }
                }
            }
        }
    }
}

module dovetail_plug(corner_x, r, dt, zx_profile=[[0,0],[10,0],[12,-1]]){
    // Just the  male dovetail without the mounting block.
    //
    // zx_profile defines the profile down one side of the dovetail. This
    //   allows for chamfering the dovetail or for steping the dovetail
    //   to have multiple defined contact points.
    //   it is a list of 2-element vectors, each of which defines
    //   a point in Z-X space, i.e. first element is height and second
    //   is the shift in the corner position.
    //   For example,
    //   zx_profile=[[0,0],[10,0],[12,-1]] creates a plug 12mm+tiny() high
    //   where the top 2mm are sloped at 60 degrees.
    //   NOTE: the use of tiny().

    union(){

        // four flat cylinders make the contact point
        // Note the loop reflects the two cylinders here
        loop_over_zx_profile(zx_profile, corner_x){
            translate([sqrt(3)*r,r,0]){
                //TODO: find out logic for "dt*sqrt(2) - (1+sqrt(3))*r"
                repeat([dt*sqrt(2) - (1+sqrt(3))*r,0,0],2){
                    cylinder(r=r,h=tiny());
                }
            }
        }

        // another four cylinders join the plug to the y=0 plane
        loop_over_zx_profile(zx_profile, corner_x){
            repeat([sqrt(3)*r,r,0],2){
                cylinder(r=tiny(),h=tiny());
            }
        }
    }
}

module dovetail_m(size=[10,2,10],
                  dt=1.5,
                  t=2,
                  top_taper=1,
                  bottom_taper=0.5,
                  waist_height=0,
                  waist_depth=0.5,
                  r=0.5){
    // Male dovetail, contact plane is y=0, dovetail is in y>0
    // size is a box that is centred in X, sits on Z=0, and extends
    // in the -y direction from y=0.  This is the mount for the
    // dovetail, which sits in the +y direction.
    // The width of the box should be the same as the width of the
    // female dovetail clip.  The size of the dovetail is set by dt.
    // t sets the thickness of the female dovetail arms; the dovetail
    // is actually size.x-2*t wide.
    //r =radius of curvature - something around nozzle width is good.
    w=size.x-2*t; //width of dovetail
    h=size.z; //height
    corner=[w/2-dt,0,0]; //location of the pointy bit of the dovetail
    difference(){
        union(){
            //back of the dovetail (the mount) plus the start of the
            //dovetail's neck (as far as y=0)
            sequential_hull(){
                // start with the cube that the dovetail attaches to
                translate([-w/2-t,-size.y,0]){
                    cube([w+2*t,size.y-r,h]);
                }
                // then add shapes that take in the centres of the cylinders
                // from the next step.  This joins together the nicely-rounded
                // contact points, such that when we subtract out the cylinders
                // at the corners we get a nice smooth shape.
                reflect_x(){
                    translate(corner+[sqrt(3)*r,-r,0]){
                        cylinder(r=tiny(),h=h);
                    }
                }
                reflect_x(){
                    translate(corner){
                        cylinder(r=tiny(),h=h);
                    }
                }
            }
            //contact points (with rounded edges to avoid burrs)
            difference(){
                union(){
                    reflect_x(){
                        hull(){
                            translate(corner+[sqrt(3)*r,-r,0]){
                                cylinder(r=r,h=h);
                            }
                            translate([w/2+t-r,-r,0]){
                                cylinder(r=r,h=h);
                            }
                        }
                    }
                    // the "plug" is chamfered for easy insertion, and has
                    // a waist in the middle. The depth of the waist is set by the
                    // waist parameter.
                    // Disable the waist if the height is too small.
                    waist_dx = waist_height>waist_depth*4 ? waist_depth : 0;
                    //waist_dz is sets the chamfer
                    waist_dz = waist_height>waist_depth*4 ? waist_depth*2 : tiny();
                    zx_profile = [[0,-bottom_taper],
                                  [bottom_taper,0],
                                  [h/2-waist_height/2,0],
                                  [h/2-waist_height/2+waist_dz,-waist_dx],
                                  [h/2+waist_height/2-waist_dz,-waist_dx],
                                  [h/2+waist_height/2,0],
                                  [h-top_taper,0],
                                  [h-tiny(),-top_taper/2]];
                    dovetail_plug(corner.x, r, dt, zx_profile);

                }
            }
        }
        // We round out the internal corner so that we grip with the edges
        // of the tooth and not the point (you get better contact this way).
        reflect_x(){
            translate(corner){
                cylinder(r=r,h=3*h,center=true);
            }
        }
    }
}

module dovetail_clip_y(size, dt=1.5, t=2, taper=0, endstop=false){
    // Make a dovetail where the sliding axis is along y, i.e. horizontal
    // This means it's the top of the object that grips the dovetail.
    //
    // the x and y elements of size set the dovetail width and "height"
    // the z element sets the distance from the end of the teeth (z=0) to
    // the bottom of the mount.
    // dt is the size of the dovetail teeth
    // endstop enables a link on the other side of the Y axis, to stop motion there.
    // endstop_w, endstop_t set the width and thickness (in y and z) of the link
    // taper optionally feathers the dovetail onto an edge
    // the dovetail extends along the +y direction from y=0
    h = size.y;
    ew = 0;
    reflect_x(){
        translate_x(-size.x/2){
            mirror([0,0,1]){
                sequential_hull(){
                    translate_y(dt){
                        cube([t+dt,h-2*dt,tiny()]);
                    }
                    cube([t,h,dt]);
                    translate_y(-ew){
                        cube([t,h+ew,dt]);
                    }
                    translate([0,-taper,size.z-tiny()]){
                        cube([t,h+2*taper,tiny()]);
                    }
                }
            }
        }
    }
    if(endstop){
        difference(){
            // make a bridge between the lower tapers
            hull(){
                translate([0,-taper/2,-size.z+tiny()]){
                    cube([size.x,taper,2*tiny()],center=true);
                }
                translate_z(-tiny()){
                    cube([size.x,tiny(),2*tiny()],center=true);
                }
            }
            //cut the middle
            translate_z(-size.z+0.5+999/2){
                cube([(size.x-2*t-2*dt)-2,999,999],center=true);
            }
            translate([0,-taper/2,-size.z]){
                cube([size.x,taper-1.5,0.5*2+tiny()],center=true);
            }
        }
    }
}
