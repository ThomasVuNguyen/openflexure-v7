// Calculations of the positions of components for the RMS objectives
// See OFEP 2 for more information
use <./libdict.scad>
use <./cameras/camera.scad>

// z position of the shoulder of the objective
function objective_shoulder_z(params, optics_config) = let(
    sample_z = key_lookup("sample_z", params),
    objective_parfocal_distance = key_lookup("objective_parfocal_distance", optics_config)
) sample_z - objective_parfocal_distance;

// Postion of the tube lens (at the rear principal plane)
function tube_lens_z(params, optics_config) = let(
    lens_objective_distance = key_lookup("lens_objective_distance", optics_config)
) objective_shoulder_z(params, optics_config) - lens_objective_distance;

// Position of the bottom face of the tube lens (shifted by the difference between
// the focal length and the front focal length)
function tube_lens_face_z(params, optics_config) = let(
    //Front focal distance (from flat side to focus) - measure this, or take it from the lens spec. sheet
    tube_lens_ffd = key_lookup("tube_lens_ffd", optics_config),
    //The nominal focal length of the tube lens.
    tube_lens_f = key_lookup("tube_lens_f", optics_config)
) tube_lens_z(params, optics_config) - (tube_lens_f - tube_lens_ffd);

// The the distance from the tube lens (rear principal plane)
// to the primary imaging plane of the objective
function lens_pip_distace(optics_config) = let(
    mech_tube_length = key_lookup("objective_mechanical_tube_length", optics_config),
    lens_obj_dist = key_lookup("lens_objective_distance", optics_config)
) mech_tube_length - lens_obj_dist - 10;


function lens_sensor_distance_finite_conj(optics_config) = let(
    f = key_lookup("tube_lens_f", optics_config),
    p = lens_pip_distace(optics_config)
) f*p/(p+f);

function lens_sensor_distance_infinite_conj(optics_config) = key_lookup("tube_lens_f", optics_config);

// The the distance from the tube lens (rear principal plane)
// to the camera sensor
function lens_sensor_distance(optics_config) = key_lookup("is_finite_conjugate", optics_config) ?
    lens_sensor_distance_finite_conj(optics_config):
    lens_sensor_distance_infinite_conj(optics_config);

function rms_camera_sensor_z(params, optics_config) = tube_lens_z(params, optics_config) - lens_sensor_distance(optics_config);

function rms_camera_mount_top_z(params, optics_config) = let(
    mount_height = camera_mount_height(optics_config),
    sensor_height_above_pcb = camera_sensor_height(optics_config),
    sensor_z = rms_camera_sensor_z(params, optics_config)
) sensor_z - sensor_height_above_pcb + mount_height;

