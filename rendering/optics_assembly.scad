use <librender/assembly_parameters.scad>
use <rms_optics_assembly.scad>
use <condenser_assembly.scad>


cutaway_optics();

module cutaway_optics(){
    rendered_optics_module(optics_module_pos(), cut=true, cable_positions=curled_ribbon_pos());
    rendered_condenser_assembly(cut=true);
}
