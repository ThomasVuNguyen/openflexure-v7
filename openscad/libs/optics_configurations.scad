use <./libdict.scad>

// Notes on parameters:
//
// camera_rotation:  The angle of the camera mount (the ribbon cables exits at 135 degrees from
//                   mount for '0' & 180 degrees from mount for '-45')
//
// beamsplitter_rotation: The angle of the block to hold the fl cube (0 for the fl cube exiting
//                        at 180 degree from the mount and -60 for the fl cube exiting at 120
//                        from the mount)

function rms_f50d13_config(camera_type = "picamera_2", beamsplitter=false, parfocal_distance=45, camera_rotation=0, beamsplitter_rotation=0) = let(
    // if the parfocal distance is undefined, use the default.
    parfocal_distance_validated = (parfocal_distance == undef) ? 45 : parfocal_distance,
    // if parfocal distance is the default 45mm, the lens is 8.5mm below the objective.
    // if a shorter parfocal distance is used, we increase that distance, to stop the camera module
    // from rising up inside the microscope.
    lens_objective_distance = max(45 - parfocal_distance_validated, 0) + 8.5,
    config_dict = [["optics_type", "RMS"],
                   ["camera_type", camera_type],
                   ["tube_lens_ffd", 47],
                   ["tube_lens_f", 50],
                   ["tube_lens_r", 12.7/2+0.1],
                   ["objective_parfocal_distance", parfocal_distance_validated],
                   ["beamsplitter", beamsplitter],
                   ["gripper_t", 1],
                   ["is_finite_conjugate", true],
                   ["objective_mechanical_tube_length", 160],
                   ["lens_objective_distance", lens_objective_distance],
                   ["camera_rotation", camera_rotation],
                   ["beamsplitter_rotation", beamsplitter_rotation]]
) config_dict;

function rms_infinity_f50d13_config(camera_type = "picamera_2", beamsplitter=false, parfocal_distance=undef, camera_rotation=0, beamsplitter_rotation=0) = let(
    finite_config = rms_f50d13_config(camera_type, beamsplitter, parfocal_distance, camera_rotation, beamsplitter_rotation),
    replacements = [["is_finite_conjugate", false]]
) replace_multiple_values(replacements, finite_config);

function pilens_config(camera_type = "picamera_2") = let(
    config_dict = [["optics_type", "spacer"],
                   ["camera_type", camera_type],
                   ["lens_r", 3],
                   ["parfocal_distance", (3+1)], // For a lens spacer, this is the full lens thickness plus the working distance
                   ["lens_h", 2.5], // For a lens spacer this is the lens thickness to be gripped
                   ["lens_spacing", 17], // Minimum 17 for spacer to build correctly
                   ["mounting_post_height",4],
                   ["board_thickness",1]]
) config_dict;

function c270lens_config(camera_type = "logitech_c270") = let(
    config_dict = [["optics_type", "spacer"],
                   ["camera_type", camera_type],
                   ["lens_r", (11.6/2)],
                   ["parfocal_distance", (6+1)], // For a lens spacer, this is the full lens thickness plus the working distance
                   ["lens_h", 4], // For a lens spacer this is the lens thickness to be gripped
                   ["lens_spacing", 17], // Minimum 13 for spacer to build correctly
                   ["mounting_post_height",4],
                   ["board_thickness",1]]
) config_dict;

function b0196lens_config(camera_type = "arducam_b0196") = let(
    config_dict = [["optics_type", "spacer"],
                   ["camera_type", camera_type],
                   ["lens_r", 3],
                   ["parfocal_distance", (3+1)], // For a lens spacer, this is the full lens thickness plus the working distance
                   ["lens_h", 2.5], // For a lens spacer this is the lens thickness to be gripped
                   ["lens_spacing", 17], // Minimum 17 for spacer to build correctly
                   ["mounting_post_height",4],
                   ["board_thickness",1]]
) config_dict;
