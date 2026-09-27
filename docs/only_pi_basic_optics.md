# The Raspberry Pi Basic Optics Module

This guide is just for creating the basic optics module with a Raspberry Pi camera V2. You can then use this optics module in any OpenFlexure microscope. Note that you will build this module if you follow the complete instructions for the [low cost microscope](low_cost_microscope.md).

{{BOM}}

[Black PLA filament]: parts/materials/black_pla_filament.md "{cat:material}"
[Fused Filament 3D printer]: parts/tools/rep-rap.md

Before you start assembly you should [3D print][Fused Filament 3D printer]{qty:1,cat:tool} the following STLs in [black PLA filament][Black PLA filament]{Qty: 20g}:

* [Lens spacer]{output,qty:1}: [lens_spacer_picamera_2_pilens.stl](models/lens_spacer_picamera_2_pilens.stl){previewpage} - **This must be printed in black** [i](info_pages/why_optics_black.md)
* [Camera platform]{output,qty:1}: [camera_platform_picamera_2_pilens.stl](models/camera_platform_picamera_2_pilens.stl){previewpage} - *this could be a different colour!*

The next step is [assembly](basic_optics_module.md){step, var_lens: pi_lens}.
