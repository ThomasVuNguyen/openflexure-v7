use <./assembly_parameters.scad>
use <./render_settings.scad>
use <./render_utils.scad>
use <../../openscad/libs/upright_z_axis.scad>

separate_z_actuator(render_params(), cable_guides = false, cable_housing = false, rectangular = true);

module rendered_separate_z_actuator(colour=undef, alpha=1.0, manual=false){
    //If this is failing to import you need to run this same file first to create the STL
    render_colour = is_undef(colour) ? body_colour() : colour;
    color(render_colour, alpha){
        if (manual){
            import("rendered_separate_z_actuator_manual.stl");
        }
        else {
            import("rendered_separate_z_actuator.stl");
        }
    }
}
