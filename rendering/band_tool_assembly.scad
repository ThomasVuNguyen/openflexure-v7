
use <../openscad/libs/utilities.scad>
use <../openscad/libs/lib_actuator_assembly_tools.scad>
use <librender/tools.scad>
use <librender/render_utils.scad>
use <librender/assembly_parameters.scad>
use <librender/render_settings.scad>


FRAME=1;

render_band_tool_assembly(FRAME);

module render_band_tool_assembly(frame){
    params = render_params();
    if (frame<=2){
        color(tools_colour()){
            render(6){
                translate_z(frame == 1 ? holder_height() + 5 : 0){
                    band_tool_arms(params, vertical=true);
                }
            }
        }
        color(tools_colour()){
            render(6){
                band_tool_holder(params);
            }
        }
    }
}

