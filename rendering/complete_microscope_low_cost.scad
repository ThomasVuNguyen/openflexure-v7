use <./complete_microscope.scad>

// Render the microscope, with low cost optics.
rotate([-90,0,0]) render_complete_microscope(optics_version="low_cost", manual=false);