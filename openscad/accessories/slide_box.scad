use <../libs/utilities.scad>
use <../libs/logo.scad>

N_SLIDES = 16;
slide_box(N_SLIDES);

function slide_dims() = [25.4*3, 25.4*1, 1.3];

function slide_clearance() = [1, 1, .5];

function slide_separation() = 1.5;

function slide_seperator_len() = 4;

function slide_box_wall_thickness() = 2.5;

// Need to increase this for boxes smaller than 15 slides to not break
// front slide.
function front_space()=2;

function slide_box_dims(n_slides) = let(
    wall_t2 = 2*slide_box_wall_thickness(),
    sep = slide_separation(),
    slide_space = slide_dims().z + slide_clearance().z+sep
) [
    slide_dims().x + slide_clearance().x + wall_t2,
    n_slides*slide_space + front_space() + wall_t2,
    slide_dims().y + slide_clearance().y + wall_t2,
];

function hinge_d() = 5;
function hinge_space() = hinge_d()+1;

module slide_box(n_slides = 16){
    dims = slide_box_dims(n_slides);

    difference(){
        slide_box_half(n_slides);
        linear_extrude(1, center=true){
            mirror([0,1,0]){
                translate_y(-dims.y/2+6){
                    text("Bottom!", halign="center", valign="center");
                }
                translate_y(-dims.y/2-6){
                    text("Turn over before", size=6, halign="center", valign="center");
                }
                translate_y(-dims.y/2-14){
                    text("opening!", size=6, halign="center", valign="center");
                }
            }
        }
    }
    mirror([0,1,0]){
        difference(){
            slide_box_half(n_slides, pin_side=true);
            translate([11, dims.y/2, -0.5]){
                rotate(180){
                    openflexure_emblem(scale_factor=.1);
                }
            }
            linear_extrude(1, center=true){
                translate_y(dims.y/2+8){
                    rotate(180){
                        text("Slide Holder", size=9, halign="center", valign="center");
                    }
                }
            }
        }
    }
}

module bottom_rounded_cube(dims, r=2){
    hull(){
        for (i = [r, dims.x-r]){
            for (j = [r, dims.y-r]){
                translate([i, j, r]){
                    sphere(r=r);
                }
            }
        }
        for (i = [r, dims.x-r]){
            for (j = [r, dims.y-r]){
                translate([i, j, dims.z-1]){
                    cylinder(r=r, h=1);
                }
            }
        }
    }
}

module slide_box_half(n_slides, pin_side=false){
    dims = slide_box_dims(n_slides);
    sep = slide_separation();
    slide_space = slide_cutout_size();
    box_shift = [-dims.x/2, hinge_space()/2, 0];
    hinge_h = .5*dims.z +.2;
    difference(){
        union(){
            translate(box_shift){
                bottom_rounded_cube([dims.x, dims.y, .5*dims.z],$fn=12);
            }
            hull(){
                translate(box_shift+[2.5,0,6]){
                    cube([dims.x-5, 1, .5*dims.z-2-6]);
                }
                translate_z(hinge_h){
                    rotate_y(90){
                        cylinder(d=hinge_d(), h=dims.x-5, center=true, $fn=16);
                    }
                }
            }
        }
        translate(box_shift + [1,1,1]*slide_box_wall_thickness()){
            if (pin_side){
                cube([slide_space.x, n_slides*(slide_space.y+sep)+front_space(), slide_space.z]);
            }
            else{
                for (i = [0 : n_slides-1]){
                    translate_y(i*(slide_space.y+sep) + sep/2){
                        slide_cutout();
                    }
                }
                translate([slide_seperator_len(),0, 1]){
                    cube([slide_dims().x-2*slide_seperator_len(), n_slides*(slide_space.y+sep), slide_dims().y]);
                }
            }
        }
        rep = pin_side ? [-3 : 2 : 3] : [-4 : 2 : 4];
        for (i = rep){
            translate_x(i*10){
                cube([10.5, hinge_space(), 3*dims.z], center=true);
            }
        }
        if (!pin_side){
            translate_z(hinge_h){
                rotate_y(90){
                    cylinder(d=hinge_d()/2+.8, h=dims.x, center=true, $fn=16);
                }
            }
        }
    }
    if (pin_side){
        translate_z(hinge_h){
            rotate_y(90){
                cylinder(d=hinge_d()/2, h=dims.x-6, center=true, $fn=16);
            }
        }
        translate([0, dims.y+hinge_space()/2, dims.z/2]){
            difference(){
                hull(){
                    cube([10,.1,12],center=true);
                    translate([0,3,3]){
                        cube([10,.1,8],center=true);
                    }
                }
                translate_z(4){
                    sphere(d=3.25, $fn=16);
                }
            }
        }
    }
    else{
        translate([0, dims.y+hinge_space()/2, dims.z/2-4]){
            sphere(d=3, $fn=16);
        }
    }
}

function slide_cutout_size() = let(
    //slide in xy plane
    flat_dims = slide_dims() + slide_clearance()
) [flat_dims.x, flat_dims.z, flat_dims.y];

module slide_cutout(){
    dims = slide_cutout_size();
    cube(dims);
}
