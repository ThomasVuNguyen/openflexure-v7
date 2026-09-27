/******************************************************************
*                                                                 *
* OpenFlexure Microscope: Camera mount                            *
*                                                                 *
* This is part of the OpenFlexure microscope, an open-source      *
* microscope and 3-axis translation stage.  It gets really good   *
* precision over a ~10mm range, by using plastic flexure          *
* mechanisms.                                                     *
*                                                                 *
* This file defines the camera mount module, as well as two       *
* functions that return the height of the module and the position *
* of the sensor within that module.  It picks between the various *
* supported cameras using the "camera" variable.                  *
*                                                                 *
*                                                                 *
* (c) Richard Bowman, January 2016                                *
* Released under the CERN Open Hardware License                   *
*                                                                 *
******************************************************************/

use <../libdict.scad>
use <./logitech_c270.scad>
use <./picamera_2.scad>
use <./m12.scad>
use <./6led.scad>
use <./arducam_b0196.scad>

// If I was able to selectively include different files, this wouldn't be needed.
// However, doing this saves the faff of precompiling the SCAD source with some
// dodgy ad-hoc script, and is probably the best compromise.  The ternary operator
// is necessary as proper if statements aren't currently allowed in OpenSCAD functions.

// See the function below for valid values of "camera".

function get_camera_type(optics_config) = key_lookup("camera_type", optics_config);

function get_camera_dictionary(optics_config) = let(
    camera_type = get_camera_type(optics_config),
    //create a dictionary of the dictionaries.
    camera_dicts = [["logitech_c270", c270_camera_dict()],
                    ["m12", m12_camera_dict()],
                    ["6led", 6led_camera_dict()],
                    ["picamera_2", picamera_2_camera_dict()],
                    ["arducam_b0196",arducam_b0196_camera_dict()]
                    ]
) key_lookup(camera_type, camera_dicts);

/**
* The height of the structure that the camera mounts. When contstructing a an optics module or lens spacer the rest of the structure should
* start at this height.
*/
function camera_mount_height(optics_config) = let(
    camera_dict = get_camera_dictionary(optics_config)
) key_lookup("mount_height", camera_dict);


/**
* The height camera sensor above the board
*/
function camera_sensor_height(optics_config) = let(
    camera_dict = get_camera_dictionary(optics_config)
) key_lookup("sensor_height", camera_dict);

module camera_mount(optics_config, screwhole=true, counterbore=false){
    camera_type = get_camera_type(optics_config);
    if(camera_type=="logitech_c270"){
        c270_camera_mount(screwhole=screwhole);
    }
    else if(camera_type=="m12"){
        m12_camera_mount();
    }
    else if(camera_type=="6led"){
        6led_camera_mount();
    }
    else if(camera_type=="picamera_2"){
        picamera_2_camera_mount(screwhole=screwhole, counterbore=counterbore);
    }
    else if(camera_type=="arducam_b0196"){
        arducam_b0196_camera_mount(screwhole=screwhole);
    }
    else{
        assert(false, "This camera option does not have a mount set.");
    }
}

module camera_bottom_mounting_posts(optics_config, outers=true, cutouts=true, bottom_slice=false){
    camera_type = get_camera_type(optics_config);
    if(camera_type=="logitech_c270"){
        c270_camera_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts, bottom_slice=bottom_slice);
    }
    else if(camera_type=="m12"){
        assert(false, "This camera option does not have mounting posts set.");
    }
    else if(camera_type=="6led"){
        6led_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts, bottom_slice=bottom_slice);
    }
    else if(camera_type=="picamera_2"){
        picamera_2_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts, bottom_slice=bottom_slice);
    }
    else if(camera_type=="arducam_b0196"){
        b0196_camera_bottom_mounting_posts(optics_config, outers=outers, cutouts=cutouts, bottom_slice=bottom_slice);
    }
    else{
        assert(false, "This camera option does not have mounting posts set.");
    }
}

module camera_mount_counterbore(optics_config){
    camera_type = get_camera_type(optics_config);
    if(camera_type=="picamera_2"){
        picamera_2_counterbore();
    }
    else if(camera_type=="logitech_c270"){
        c270_counterbore();
    }
    else if(camera_type=="arducam_b0196"){
        b0196_counterbore();
    }
    else{
        assert(false, "This camera option does not have counterbore set.");
    }
}
