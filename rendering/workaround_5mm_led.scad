use <../openscad/libs/illumination.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <../openscad/libs/gears.scad>
use <librender/render_settings.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/rendered_components.scad>
use <librender/hardware.scad>
use <librender/optics.scad>
use <librender/electronics.scad>
use <mount_microscope.scad>
use <condenser_assembly.scad>

FRAME = 5;
workaround_5mm_led(FRAME);



module workaround_5mm_led(frame){
    if(frame <= 5){
        mount_led(frame);
    }
}

module mount_led(frame){
    rendered_condenser_lid();
    translate_z(frame==1 ? -4 : 0){
        rendered_led(explode=(frame<3));
    }
    translate_z(frame==1 ? 8 : 0){
        rendered_led_holder(explode=(frame<3));
    }
    if(frame >= 4){
        rendered_led_screws(explode=(frame==4));
    }
}
