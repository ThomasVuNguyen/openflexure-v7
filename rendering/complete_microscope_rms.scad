use <./complete_microscope.scad>

// Render the microscope, with RMS optics.
rotate([-90,0,0]) render_complete_microscope(optics_version="rms", manual=false);