/******************************************************************
*                                                                 *
* OpenFlexure Microscope: logo                                    *
*                                                                 *
* This file draws the OpenFlexure/Open Hardware logos.            *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

$fn=64;

module oshw_logo(){
    linear_extrude(1){
        translate([-17.5,-16]){
            resize([35,0],auto=true){
                import("logos/oshw_gear.dxf");
            }
        }
    }
}

module openflexure_emblem(h=1, scale_factor=1){
    linear_extrude(h){
        scale(scale_factor){
            import("logos/openflexure_emblem.dxf");
        }
    }
}
module openflexure_logo(h=1){
    // The full logo, including text
    // This is 47 mm tall in Inkscape, and exported using base units=mm
    // We resize it to be about the right size for the microscope
    // The origin is set to x=38 to centre the emblem on x=0
    // I don't understand the Y origin value...
    linear_extrude(h){
        scale(0.85){
            import("logos/openflexure_logo.dxf", origin=[38,3]);
        }
    }
}

module openflexure_logo_above(h=1){
    // The logo including text, with embelem above text
    linear_extrude(h){
        scale(0.85){
            import("logos/openflexure_logo_above.dxf", origin=[-25,3]);
        }
    }
}

module oshw_logo_and_text(message=""){
    union(){
        translate([0,45,0]){
            oshw_logo();
        }

        mirror([1,0,0]){
            linear_extrude(1){
                text(message, size=14, font="Calibri", halign="center");
            }
        }
    }
}

 module oshw_logo_and_text_beside(message=""){
    union(){
        translate([25,8,0]){
            oshw_logo();
        }

        mirror([1,0,0]){
            linear_extrude(1){
                text(message, size=14, font="Calibri", halign="left");
            }
        }
    }
}
