// This library contains certain components rendered in colour

use <render_utils.scad>
use <render_settings.scad>
use <../../openscad/lens_tool.scad>
use <../../openscad/libs/cameras/picamera_2.scad>

module rendered_lens_tool(){
    coloured_render(tools_colour()){
        lens_tool();
    }
}

module rendered_picamera_2_cover(){
    coloured_render(extras_colour()){
        picamera_2_cover();
    }
}