use <../openscad/libs/upright_z_axis.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>
use <librender/rendered_separate_z_actuator.scad>
use <prepare_main_body.scad>

FRAME = 3;

render_prepare_separate_z_actuator(FRAME);

module render_prepare_separate_z_actuator(frame){
    if (frame==1){
        prepared_separate_z_actuator(nuts=true, low=false, screws=false, explode="nut");
	}
    else if (frame==2){
        prepared_separate_z_actuator(nuts=true, low=true, screws=true, explode="screw");
	}
    else if (frame==3){
        prepared_separate_z_actuator(nuts=true, low=false, screws=true, explode="none");
    }
}

module prepared_separate_z_actuator(manual=false, nuts=true, low=false, screws=false, explode="none"){
    exploded_nut = (explode=="nut");
    exploded_screw = (explode=="screw");
    params = render_params();
    rendered_separate_z_actuator(colour=body_colour(), alpha=1.0, manual=manual);
    if (nuts && !manual){
        z_motor_nut(params, right=true, exploded=exploded_nut, low=low);
        z_motor_nut(params, right=false, exploded=exploded_nut, low=low);
    }
    if (screws && !manual){
        z_motor_nut_temp_screw(params, right=true, exploded=exploded_screw, turn=!exploded_screw);
        z_motor_nut_temp_screw(params, right=false, exploded=exploded_screw, turn=!exploded_screw);
    }
}
