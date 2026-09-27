use <./mount_electronics.scad>

OPTICS_VERSION = "rms"; // "rms", "low_cost", "c270", "upright"
MANUAL = false;
POST = false;

render_complete_microscope(OPTICS_VERSION, MANUAL, POST);

module render_complete_microscope(optics_version="rms", manual=false, post=false){
    render_microscope(optics_version=optics_version, manual=manual, post=post);
}
