# Using a Logitech C270 HD USB webcam as a basic optics module

This section describes how to assemble an optics module consisting of a Logitech C270 webcam and the lens from the camera. To create a microscope the wide angle lens is reversed and separated from the camera. This makes quite a good microscope objective with a field of view similar to a 20x objective and a resolution of around 2μm.

>i USB cameras are not supported in the standard Openflexure software.


{{BOM}}


[PLA filament]: ../parts/materials/pla_filament.md "{cat:material}"
[Black PLA filament]: ../parts/materials/black_pla_filament.md "{cat:material}"
[Fused Filament 3D printer]: ../parts/tools/rep-rap.md "{cat:tool}"
[2.5mm Ball-end Allen key]: ../parts/tools/2.5mmBallEndAllenKey.md

[custom print settings]: ../set_slice_gap_closing_radius.md

Before you start assembly you should [3D print][Fused Filament 3D printer]{qty:1,cat:tool} the following STLs in [black PLA filament][Black PLA filament]{Qty: 20g}:

* [Lens spacer]{output,qty:1}: [lens_spacer_logitech_c270.stl](../models/lens_spacer_c270.stl){previewpage} - The lens gripper may require [custom print settings] - **This must be printed in black!** [i](../info_pages/why_optics_black.md)
* [Camera backshell]{output, qty:1}: [c270_camera_backshell.stl](../models/c270_camera_backshell.stl){previewpage}
* [Camera platform]{output,qty:1}: [camera_platform_logitech_c270.stl](../models/camera_platform_c270.stl){previewpage} - *this could be a different colour!*


Once those are printed you can [prepare the camera](c270_preparation.md){step}, and assemble the [optics module](../basic_optics_module.md){step, var_body: _manual, var_lens: c270_lens}.

