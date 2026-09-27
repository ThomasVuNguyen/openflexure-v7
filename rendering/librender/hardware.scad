/*
This is the hardware for rendering the OpenFlexure microscope
documentation.*/

/*
This file licensed CERN OHL.
(c) Richard Bowman 2020

The nuts and bolts are included from "binaries" generated
using NopSCADlib. NopSCADlib is GPL licenses and in compliance
with the GPL we provide our generation script generate_hardware.py
under the GPL. NopSCADLib is available from
https://github.com/nophead/NopSCADlib
the banch we use is:
https://github.com/julianstirling/NopSCADlib/tree/no2_screw_hack
*/
use <../../openscad/libs/utilities.scad>



module double_reflect(){
    //Shortcut function to reflext in both the xy and yz plane. Used for creating the band.
    reflect_x(){
        reflect_y(){
            children();
        }
    }
}

module viton_band(){
    // Viton band before assembly

    //id = inner diameter
    id = 30;
    band_d=2;
    $fn=32;
    color("gray", 1){
        rotate_extrude(angle=360, convexity=2){
            translate_x((id+band_d)/2){
                circle(d=band_d);
            }
        }
    }
}


module viton_band_in_situ_vertical(h=25, foot_z=-11, tool_kink=false){
    // Viton band in situ. A bit of an ad-hoc function, but looks good enough.
    band_d=2;
    $fn=32;
    color("gray", 1){
        // top part, on prongs
        reflect_x(){
            translate([7, 0, h - 3.5]){
                rotate([90,0,90]){
                    rotate_extrude(angle=180, convexity=2){
                        translate([4, 0]){
                            circle(d=band_d);
                        }
                    }
                }
            }
        }
        // band vertical part
        double_reflect(){
            p1 = [7, 4, h - 3.5];
            p2 = [5, 5, h - 18];
            p3 = [4.55, 1.85, foot_z + 4];
            // Anoyingly cannot do the if inside the squential hull
            if (tool_kink) {
                sequential_hull(){
                    translate(p1){
                        cylinder(d=band_d,h=tiny());
                    }
                    translate(p2){
                        cylinder(d=band_d,h=tiny());
                    }
                    translate(p3){
                        cylinder(d=band_d,h=tiny());
                    }
                }
            } else {
                sequential_hull(){
                    translate(p1){
                        cylinder(d=band_d,h=tiny());
                    }
                    translate(p3){
                        cylinder(d=band_d,h=tiny());
                    }
                }
            }
        }
        // bottom part, around foot
        double_reflect(){
            translate([-.4, 1, foot_z + 4]){
                rotate([80,90,0]){
                    rotate_extrude(angle=90, convexity=2){
                        translate([5, 0]){
                            circle(d=band_d);
                        }
                    }
                }
            }
        }
    }

}

module m3_hex_x25(){
    color("Silver"){
        import("m3_hex_x25.stl");
    }
}

module m4_button_x6(){
    color("Silver"){
        import("m4_button_x6.stl");
    }
}

module m3_washer(){
    color("Silver"){
        import("m3_washer.stl");
    }
}

module m3_nut(brass=false, center=false){
    nut_colour = brass ? "Gold" : "Silver";
    nut_tr = center ? [0, 0, -1.15] : [0, 0, 0];
    translate(nut_tr){
        color(nut_colour){
            import("m3_nut.stl");
        }
    }
}

module m3_cap_x10(){
    color("Silver"){
        import("m3_cap_x10.stl");
    }
}

module m3_cap_x8(){
    color("Silver"){
        import("m3_cap_x8.stl");
    }
}

module m3_cap_x6(){
    color("Silver"){
        import("m3_cap_x6.stl");
    }
}

module m2_cap_x6(){
    color("Silver"){
        import("m2_cap_x6.stl");
    }
}

module m2_5_cap_x6(){
    color("Silver"){
        import("m2_5_cap_x6.stl");
    }
}

module no2_x6_5_selftap(){
    color("Silver"){
        import("no2_x6_5_selftap.stl");
    }
}

module no1_x5_0_selftap(){
    color("#505050"){
        scale([0.85,0.85,0.77]){
            import("no2_x6_5_selftap.stl");
        }
    }
}
