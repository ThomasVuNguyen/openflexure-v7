use <./complete_microscope.scad>

// Render the microscope, without low cost optics, i.e. use RMS.
rotate([-90,0,0]) render_complete_microscope(optics_version="upright");