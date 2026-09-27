use <./assembly_parameters.scad>
use <./render_settings.scad>
use <./render_utils.scad>
use <../../openscad/libs/main_body_structure.scad>

VERSION_STRING = "custom";
HASH = "#untracked";

main_body(render_params(), VERSION_STRING, HASH);

module rendered_main_body(colour=undef, alpha=1.0, manual=false){
    //If this is failing to import you need to run this same file first to create the STL
    //You will also need to run rendered_main_body_manual to create the STL for the manual main body
    render_colour = is_undef(colour) ? body_colour() : colour;
    color(render_colour, alpha){
        if (manual){
            import("rendered_main_body_manual.stl");
        }
        else{
            import("rendered_main_body.stl");
        }
    }
}
