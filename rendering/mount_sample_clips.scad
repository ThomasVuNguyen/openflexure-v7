use <../openscad/libs/microscope_parameters.scad>
use <../openscad/libs/utilities.scad>
use <../openscad/libs/libdict.scad>
use <../openscad/libs/main_body_transforms.scad>
use <../openscad/libs/main_body_structure.scad>
use <librender/assembly_parameters.scad>
use <librender/render_utils.scad>
use <librender/render_settings.scad>
use <librender/hardware.scad>
use <librender/tools.scad>
use <mount_illumination.scad>
use <mount_microscope.scad>
use <motor_assembly.scad>
use <mount_motors.scad>
use <../openscad/sample_clips.scad>

FRAME = 2;
OPTICS_VERSION = "rms"; // "rms", "low_cost", "c270", "upright"
MANUAL = false;
render_mount_sample_clips(FRAME, OPTICS_VERSION, MANUAL);

module render_mount_sample_clips(frame, optics_version="rms", manual=false){
    
    if (frame==1){
        mounted_microscope_frame(manual=manual){
            render_sample_clips(clip="both", exploded=true, screws_exploded=true, allen_key=false);
        }
    }
    else if (frame==2){
        mounted_microscope_frame(manual=manual){
            render_sample_clips(clip="both", exploded=true, screws_exploded=false, allen_key=false);
        }
    }
    else if (frame==3){
        assembled_microscope_without_electronics(optics_version=optics_version, manual=manual);
        mounted_microscope_frame(manual=manual){
            render_sample_clips(clip="left", exploded=true, screws_exploded=false, allen_key=true, arrow="clock");
        }
    }
    else if (frame==4){
        assembled_microscope_without_electronics(optics_version=optics_version, manual=manual);
        mounted_microscope_frame(manual=manual){
            render_sample_clips(clip="left", exploded=false, screws_exploded=false, allen_key=false);
        }
    }
    else if (frame==5){
        assembled_microscope_without_electronics(optics_version=optics_version, manual=manual);
        mounted_microscope_frame(manual=manual){
            render_sample_clips(clip="both", exploded=false, screws_exploded=false, allen_key=false);
        }
    }
}



module render_sample_clips(clip="both", exploded=false, screws_exploded=false, allen_key=false, arrow="none"){
    if (clip=="right" || clip=="both"){
        rev_arrow = (arrow == "none") ?
            "none" : (arrow == "clock") ?
                "anti-clock" : "clock";
        mirror([1,0,0]){
            render_left_sample_clip(exploded=exploded,
                                    screws_exploded=screws_exploded,
                                    allen_key=allen_key,
                                    arrow=rev_arrow);
        }
    }
    // Another if statment without else as both should run for "both"
    if (clip=="left" || clip=="both"){
        render_left_sample_clip(exploded=exploded,
                                screws_exploded=screws_exploded,
                                allen_key=allen_key,
                                arrow=arrow);
    }
}


module render_left_sample_clip(exploded=false, screws_exploded=false, allen_key=false, arrow="none"){
    clip_z = exploded ? 10 : 0;
    screw_z = clip_z + (screws_exploded ? 12.5 : 2.5);
    params = render_params();
    leg_frame(params,45){
        place_part(sample_clip_position(params, extra_z=clip_z)){
            coloured_render(extras_colour()){
                default_sample_clip();
            }
        }
        place_part(sample_clip_position(params, extra_z=screw_z)){
            m3_cap_x10();
        }
        if(allen_key){
            place_part(sample_clip_position(params, extra_z=screw_z+1.5)){
                // Align allen key to z-axis
                rotate_x(90){
                    c_arrow = (arrow == "clock") ? true : false;
                    ac_arrow = (arrow == "anti-clock") ? true : false;
                    allen_key_2_5(180, clockwise_arrow=c_arrow, anticlockwise_arrow=ac_arrow);
                }
            }
        }
    }
}

