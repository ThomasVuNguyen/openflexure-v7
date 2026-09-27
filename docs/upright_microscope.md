# Upright microscope

This configuration of the microscope has the objective above the sample rather than below. It is newer and less well tested than other versions of the microscope.

These instructions detail assembling the upright microscope with a basic optics module, but [other optics modules](customisations/optics_options.md) can also be used with this microscope, including modules for high resolution objective lenses.

{{include: version_header_text.md}}

1. [.](test_your_printer.md){step}
1. [.](printing.md){step, var_type: upright, var_mass_pla: 400}
1. [.](prepare_main_body.md){step, var_illum_nuts_words : three, var_illum_nuts : 3, var_optics: upright}
1. [.](prepare_upright_z-axis.md){step}
1. [.](prepare_upright_z_mount.md){step}
1. [.](prepare_stand.md){step}
1. [.](actuator_assembly.md){step, var_body: _upright, var_n_actuators:4, var_n_washers:8}
1. [.](basic_optics_module.md){step, var_ribbon_len: 300mm, var_body: upright, var_lens: pi_lens}
1. [.](illumination.md){step, var_type: upright}
1. [.](upright_mount_illumination_and_microscope.md){step, var_optics: upright}
1. [.](upright_mount_optics.md){step, var_optics: upright}
1. [.](motors.md){step, var_type: upright, var_optics: upright}
1. [.](attach_clips.md){step, var_optics: upright}
1. [.](prepare_pi_and_sangaboard.md){step}
1. [.](wiring.md){step}
1. [.](finished.md){step, var_optics: upright}

![A render of the completed upright microscope](renders/complete_microscope_upright1.png)

There is also an [interactive 3D view](interactive_3d_view_upright.md) of the finished microscope.

{{include: upright_optics_note.md}}