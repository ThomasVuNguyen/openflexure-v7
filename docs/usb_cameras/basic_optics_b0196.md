# Assemble the Arducam B0196 basic optics module

This section describes how to assemble an optics module consisting of an Arducam B0196 webcam and the lens from the camera. To create a microscope the wide angle lens is reversed and separated from the camera. This makes quite a good microscope objective with a field of view about 750×560μm, similar to using a 20x objective.

{{BOM}}

[M3 nut]: ../parts/mechanical.yml#Nut_M3_SS
[No 2 6.5mm self tapping screws]: ../parts/mechanical.yml#SelfTap_PoziPan_No2x6.5_SS
[#1 pozidrive screwdriver]: ../parts/tools/pozidrive_1_screwdriver.md "{cat:tool}"

[PLA filament]: ../parts/materials/pla_filament.md "{cat:material}"
[Black PLA filament]: ../parts/materials/black_pla_filament.md "{cat:material}"
[Fused Filament 3D printer]: ../parts/tools/rep-rap.md "{cat:tool}"
[2.5mm Ball-end Allen key]: ../parts/tools/2.5mmBallEndAllenKey.md

[custom print settings]: ../set_slice_gap_closing_radius.md

## Print the lens spacer and camera platform {pagestep}

Using a [Fused Filament 3D printer]{qty:1}, print the following parts using [PLA filament]{qty: 20g}.

* [lens_spacer_arducam_b0196.stl](../models/lens_spacer_arducam_b0196.stl){previewpage} - The lens gripper may require [custom print settings] - **This must be printed in [black][Black PLA filament]{Qty: 20g}!** [i](../info_pages/why_optics_black.md)
* [camera_platform_arducam_b0196.stl](../models/camera_platform_arducam_b0196.stl){previewpage} 


## Visually inspect the lens spacer {pagestep}

Take the lens spacer and confirm that:

* It has been printed in black [i](../info_pages/why_optics_black.md)
* It is dust free (You can blow air through to clean it)
* The central shaft is not obstructed by strings of plastic.


## Push-fit the lens {pagestep}
![](images/b0196/IMG_4073_2.jpg)
![](images/b0196/IMG_4071_2.jpg)
![](images/b0196/IMG_4076_2.jpg)

* Work out which side of the [Arducam B0196 camera][prepared Arducam B0196 camera](fromstep){qty:1} lens used to be facing the camera sensor (This is the side with more lens visible).
* Place the lens on a clean surface with the side that was next to the camera sensor on the bottom.
* Push the lens spacer down onto the lens until the lens clicks into place. The lens should be flat in the holder and sticking out a little.


## Attach the Arducam camera {pagestep}
![](images/b0196/IMG_4078_2.jpg)
![](images/b0196/IMG_4080_2.jpg)
![](images/b0196/IMG_4082_2.jpg)

* Take the Arducam and the assembled lens spacer and fit them together.
* Place them together onto the camera platform. Make sure that the connector is above the channel in the side of the camera platform.
* Use four [No 2 6.5mm self tapping screws]{qty:4, cat:mech} to secure the three parts together using a [#1 pozidrive screwdriver]{qty:1, cat:tool}
* Take care to not over torque the screws.

## Attach the mounting screw and cable {pagestep}
![](images/b0196/IMG_4086_2.jpg)

* Take an [M3 nut]{qty:1, cat:mech} and push it into the nut trap from the top
* Take an [M3x10 cap head screws](../parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 1, cat:mech} and screw it into the nut.
* Only screw it in a couple of turns. About 5 mm of thread should still be visible.
* Attach the USB cable supplied with the camera.

## Mount the optics module in the microscope {pagestep}
![](images/b0196/IMG_4087_2.jpg)
![](images/b0196/IMG_4090_2.jpg)

(see <a href="low_cost_microscope/mount_optics_and_microscope.html">mounting the basic optics module</a> for more details of this method) 

* Insert the complete optics module into the microscope body from below. It is a close fit and will need to be angled to get it through the gap between the body and the z-actuator.
* Fit the M3 screw head into the keyhole slot in the z-actuator .
* Insert a [2.5mm Ball-end Allen key]{qty:1, cat:tool} through the teardrop shaped hole on the front of the microscope until it engages with the mounting screw.
* Slide the optics module up until the base of the camera platform is level with the base of the dovetail. 
* Tighten the M3 screw with the Allen key 