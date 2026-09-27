use <./utilities.scad>
use <./libdict.scad>
use <./lighttrap.scad>
use <./rms_calculations.scad>

//bottom of the beamsplitter filter cube (0 except for the RMS f=50mm modules where it's -8 or -20)
function fl_cube_bottom(params, optics_config) = rms_camera_sensor_z(params, optics_config) + 6;
function fl_cube_top(params, optics_config) = fl_cube_bottom(params, optics_config) + fl_cube_w() + 2.7; //top of beamsplitter cube

function fl_cube_w() = 16; //width of the fluorescence filter cube
function fl_cube_roc() = 0.6;

function fl_cube_width() = fl_cube_w();

module fl_cube_cutout(params, optics_config, taper=true){
    fl_cube_cutout_w = fl_cube_w()+1; //make the cutout a little bigger than the fl_cube
    fl_cube_bottom = fl_cube_bottom(params, optics_config);
    // A cut-out that enables a filter cube to be inserted.
    union(){
        sequential_hull(){
            translate([-fl_cube_cutout_w/2,-fl_cube_w()/2,fl_cube_bottom]){
                cube([fl_cube_cutout_w,999,fl_cube_cutout_w]);
            }
            translate([-fl_cube_cutout_w/2+2,-fl_cube_w()/2,fl_cube_bottom]){
                cube([fl_cube_cutout_w-4,999,fl_cube_cutout_w+2]); //sloping sides
            }
            translate([-fl_cube_cutout_w/2+2,-fl_cube_w()/2+2,fl_cube_bottom]){
                cube([fl_cube_cutout_w-4,fl_cube_w()-4,fl_cube_cutout_w+2]);
            }
            if(taper){
                //taper gradually to the diameter of the beam
                translate([-tiny(),-tiny(),fl_cube_bottom]){
                    cube([2*tiny(),2*tiny(),fl_cube_cutout_w*1.5]);
                }
            }
        }
        //a space at the back to allow the grippers for the dichroics to extend back a bit further.
        hull(){
            translate([-fl_cube_w()/2+2,-fl_cube_w()/2-1,fl_cube_bottom]){
                cube([fl_cube_w()-4,999,fl_cube_w()]);
            }
            translate([-fl_cube_w()/2+4,-fl_cube_w()/2,fl_cube_bottom]){
                cube([fl_cube_w()-8,999,fl_cube_w()+2]);
            }
        }

    }
}
module fl_cube_casing(params, optics_config){
    // A solid object, big enough to contain the beamsplitter cube cutout.
    minkowski(){
        difference(){
            fl_cube_cutout(params, optics_config);
            translate([-999, fl_cube_w()/2, -999]){
                cube(999*2);
            }
        }
        cylinder(r=1.6, h=0.5);
    }
}

module fl_screw_holes(params, optics_config, d, h){
    reflect_x(){
        union(){
            translate([fl_cube_w()/2+3,0,fl_cube_bottom(params, optics_config)+fl_cube_w()]){
                rotate_x(90){
                    trylinder_selftap(d, h);
                }
            }
        }
    }
}

module optical_path_fl(params, optics_config, lens_z, camera_mount_top_z){
    // The cut-out part of a camera mount, with a space to slot in a filter cube.
    bs_rotation = key_lookup("beamsplitter_rotation", optics_config);
    tube_lens_r = key_lookup("tube_lens_r", optics_config);
    aperture_r = tube_lens_r - 1.5;
    rotation = 180 + bs_rotation; // The angle that the fl module exits from (0* is the dovetail)
    rotate(rotation){
        union(){
            translate_z(camera_mount_top_z-tiny()){
                // beam path from camera mount to bottom of cube
                camera_mount_to_bs = fl_cube_bottom(params, optics_config)-camera_mount_top_z;
                // The light trap will go wrong if it's not at least two ridges high - so if we
                // are shorter than the default ridge spacing, make the ridges smaller.
                ridge = (camera_mount_to_bs > 3) ? 1.5 : camera_mount_to_bs/2;
                lighttrap_sqylinder(
                    r1=5, f1=0,                      // The bottom is a circle, radius=5mm
                    r2=0, f2=fl_cube_w()-4,          // The top is a square, side length fl_cube_w()-4
                    h=camera_mount_to_bs+2*tiny(),
                    ridge=ridge
                );
            }
            //filter cube
            fl_cube_cutout(params, optics_config);
            translate_z(fl_cube_top(params, optics_config)-tiny()){
                //beam path
                lighttrap_sqylinder(r1=1.5, f1=fl_cube_w()-4-3, r2=aperture_r, f2=0, h=lens_z-fl_cube_top(params, optics_config)+4*tiny());
            }
            translate_z(lens_z){
                //lens
                cylinder(r=aperture_r,h=99);
            }
        }
    }
}


module chamfer_bottom_edge(chamfer=0.3, h=0.5){
    difference(){
        children();

        minkowski(){
            cylinder(r1=2*chamfer, r2=0, h=2*h, center=true);
            linear_extrude(tiny()){
                difference(){
                    square(999, center=true);
                    projection(cut=true){
                        translate_z(-tiny()){
                            hull(){
                                children();
                            }
                        }
                    }
                }
            }
        }
    }
}

module fl_cube_outer(roc, w, foot, bottom_t){
    // The outer body for fl_cube()

    $fn=8;
    chamfer_bottom_edge(){
        union(){
            reflect_x(){
                // outer "arms" that are responsible for the tight fit
                sequential_hull(){
                    translate([w/2-2-roc*0.8/sqrt(2), w+2-roc*1.2, 0]){
                        cylinder(r=roc, h=w);
                    }
                    translate([w/2-roc, w-roc/sqrt(2), 0]){
                        cylinder(r=roc, h=w);
                    }
                    translate([w/2-roc, foot+bottom_t+roc, 0]){
                        cylinder(r=roc, h=w);
                    }
                }
                translate([w/2-3*roc, foot+bottom_t+roc, 0]){
                    difference(){
                        // the curved bits at the bottom
                        resize([0,(bottom_t+roc)*2,0]){
                            cylinder(r=3*roc, h=w, $fn=24);
                        }
                        // cut out the inner radius
                        cylinder(r=roc, h=999, center=true);
                        // restrict it to a quarter-turn
                        mirror([1,0,0]){
                            translate([-roc,0,-99]){
                                cube(999);
                            }
                        }
                        mirror([1,0,0]){
                            translate([0,-roc,-99]){
                                cube(999);
                            }
                        }
                    }
                }
            }
            // join the two arms together at the bottom
            translate([0,foot+bottom_t/2, w/2]){
                cube([w - roc*3*2 + 2*tiny(), bottom_t, w], center=true);
            }

            // Five mounting points for the cube. Three on the bottom of the cube
            // one on each sprung arm on the top.
            points = [[-w/2+roc*3, roc, roc+0.5],
                      [w/2-roc*3, roc, roc+0.5],
                      [0, roc, w-roc],
                      [w/2-2-roc*0.3/sqrt(2), w+2-roc*1.2, w/2],
                      [-(w/2-2-roc*0.3/sqrt(2)), w+2-roc*1.0, w/2]];
            for(p = points){
                translate(p){
                    sphere(r=roc,$fn=8);
                }
            }
        }
    }
}


//TODO: Huge module need breaking up
module fl_cube(){
    // Filter cube that slots into a suitably-modified optics module
    // This prints with the Y axis vertical - to save rotating all the
    // cylinders, it's written here as printed.
    roc = fl_cube_roc();
    w = fl_cube_w();
    foot = roc*0.7;
    bottom_t = roc*3;
    dichroic = [12,16,1.1];
    dichroic_t = dichroic.z;
    emission_filter = [10,14,1.5];
    beamsplit = [0, w/2+2, w/2];
    inner_w = w - 6*roc;
    bottom = bottom_t + foot;
    $fn=8;
    difference(){
        // mount for 45 degree dichroic, with bottom retaining clip
        // y and z position of coated tip of dichroic + clearance room
        by = beamsplit.y + dichroic.y/2/sqrt(2) + 0.3;
        bz = beamsplit.z - dichroic.y/2/sqrt(2) + 0.3;
        // y and z position of back tip of dichroic
        bby = beamsplit.y + dichroic.y/2/sqrt(2) - dichroic.z/sqrt(2);
        bbz = beamsplit.z - dichroic.y/2/sqrt(2) - dichroic.z/sqrt(2);

        union(){
            fl_cube_outer(roc, w, foot, bottom_t);

            sequential_hull(){
                // tall back of triangle
                translate([-inner_w/2, bottom, 0]){
                    cube([inner_w, tiny(), beamsplit.z + beamsplit.y - bottom - dichroic_t*sqrt(2)]);
                }
                //pointy end of triangle
                translate([-inner_w/2, bby, 0]){
                    cube([inner_w, tiny(), bbz]);
                }
                //far end
                translate([-inner_w/2+2, by, 0]){
                    cube([inner_w-4, 1.5, bz]);
                }
                translate([-inner_w/2+2, by, bz]){
                    //start of retaining clip
                    cube([inner_w-4, 1.5, tiny()]);
                }
                //end of retaining clip
                translate([-inner_w/2, by - 4, 4 + 2*dichroic_t]){
                    cube([inner_w, 2, tiny()]);
                }
                //overhanging bit
                translate([-inner_w/2, by - 5, 4 + 2*dichroic_t]){
                    cube([inner_w, 2, 1]);
                }
            }

            // Note: This is a static dovetail that does not use the dovetail library.
            // We should find a new way to mount this cube.
            // attachment for the excitation filter and LED
            reflect_x(){
                translate([-w/2, bottom + 4, w]){
                    sequential_hull(){
                        depth = w-bottom-4-roc;
                        translate_z(-roc){
                            cube([2*roc, depth, tiny()]);
                        }
                        translate([0.5,0,roc]){
                            cube([2*roc, depth, 1.5]);
                        }
                        translate([0.5+2*roc + 1.5 - 0.2*(1+sqrt(2)),0,roc+1.5-0.2]){
                            rotate_x(-90){
                                cylinder(r=0.2, h=depth);
                            }
                        }
                    }
                }
            }
        }
        // hole for the beam
        translate(beamsplit){
            rotate_x(90){
                cylinder(r=5,h=999, center=true, $fn=32);
            }
        }
        // hole for the emission filter
        translate([-emission_filter.x/2, bottom - roc*1.5, beamsplit.z-emission_filter.y/2]){
            cube([emission_filter.x, emission_filter.z, 999]);
        }
        // hole for easy removal of emission filter
        translate([0,emission_filter.z/2 + bottom - roc*1.5,0]){
            cylinder(h=beamsplit.z-emission_filter.y/2, r=emission_filter.z/2);
        }
        // access hole for the dichroic
        translate(beamsplit){
            rotate_x(-45){
                translate_y(-dichroic.y/2){
                    scale([1.1,1,1.9]){
                        cube(dichroic, center=true);
                    }
                }
            }
        }
        // hole for easy removal of the beamsplitter
        beamsplitter_eject_hole_angle=32;
        beamsplitter_eject_hole_r = 0.6;
        translate([0, bby, bbz]){
            rotate_x(beamsplitter_eject_hole_angle){
                translate([0, beamsplitter_eject_hole_r, 0]){
                    cylinder(h=10, r=beamsplitter_eject_hole_r, center=true);
                }
            }
        }
    }
}