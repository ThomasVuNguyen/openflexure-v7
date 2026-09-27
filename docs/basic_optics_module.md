# Assemble the basic optics module

The imaging optics for this version of the microscope consist of a {{includetext: "Raspberry Pi camera", if: var_lens is pi_lens}}{{includetext: "Logitech C270 webcam", if: var_lens is c270_lens}} and the lens from the camera. To create a microscope, the wide angle lens is reversed and separated from the camera. This makes quite a good microscope objective with a field of view about {{includetext: "750×560μm", if: var_lens is pi_lens}}{{includetext: "1000×560μm", if: var_lens is c270_lens}}, similar to using a 20x objective.


{{BOM}}

[M3 nut]: parts/mechanical.yml#Nut_M3_SS
[No 2 6.5mm self tapping screws]: parts/mechanical.yml#SelfTap_PoziPan_No2x6.5_SS
[#1 pozidrive screwdriver]: parts/tools/pozidrive_1_screwdriver.md "{cat:tool}"
[#0 Phillips screwdriver]: parts/tools/phillips_0_screwdriver.md "{cat:tool}"
[Pi Camera lens tool]: parts/tools/pi_camera_lens_tool.md "{cat:tool, note: 'This should come with the [Raspberry Pi Camera Module v2](parts/electronics.yml#PiCamera_2).  If it is missing, you can 3D print a [workaround lens removal tool](workaround_lens_removal_tool.md).'}"

[Raspberry Pi Camera Module v2]: parts/electronics.yml#PiCamera_2 "{cat:electronic}"
[{{var_ribbon_len, default:200mm}} Pi Camera ribbon cable]: parts/electronics/camera_cable_{{var_ribbon_len, default:200mm}}.md "{cat:electronic, note: 'Make sure that the cable is Type B, as identified in the part page'}"

{{include: upright_optics_note.md, if: var_body is upright}}
{{include: manual_optics_note.md, if: var_body is _manual}}

## Visually inspect the lens spacer {pagestep}

Take the [lens spacer][Lens spacer](fromstep){qty:1, cat:printedpart} and confirm that:

* It has been printed in black [i](info_pages/why_optics_black.md)
* It is dust free (You can blow air through to clean it)
* The central shaft is not obstructed by strings of plastic.


{{includetext: "
## Remove Pi Camera Lens {pagestep}

>! **Caution!**
>!
>! The camera board is static sensitive.

* Before touching the Pi Camera touch a metal earthed object. If you own one, consider wearing and anti-static strap.
* Take the [Pi Camera][Raspberry Pi Camera Module v2]{Qty:1} out of the package. Make sure to **hold it only by the sides of the board**.
* Take the protective film off the lens.
* Take the [Pi Camera lens tool]{qty: 1} and place it over the lens
* Slowly unscrew the lens (About 4 full turns of the tool)
* Carefully lift off the lens.
* Save the lens and the camera, we use both in this version of the microscope.

![](renders/picam1.png)
![](renders/picam2.png)
![](renders/picam3.png)", if: var_lens is pi_lens}}


## Push-fit the lens {pagestep}

* Work out which side of the {{includetext:"Pi", if: var_lens is pi_lens}}{{includetext:"Logitech C270", if: var_lens is c270_lens}} Camera lens used to be facing the camera sensor (This is the side with more lens visible).
* Place the lens on a clean surface with the side that was next to the camera sensor on the bottom{{includetext:", and the wider knurled ring towards the top", if: var_lens is c270_lens}}.
* Push the lens spacer down onto the lens until it clicks into place.

![](renders/low_cost_optics_assembly_{{var_lens}}.png)

{{includetext:"
## Attach the camera board to the lens spacer {pagestep}
* Take the [Logitech C270 camera board][C270 camera board](fromstep){qty:1, cat:electronic} and place it on top of the assembled lens spacer, with the sensor facing down
* Align the four screw holes with the corresponding holes in the lens spacer
* Attach the C270 camera board using one of the [No 1 self tapping screws](fromstep){qty:1, cat:mech, note: 'Recovered from C270 camera dissassembly'} that you saved from the camera disassembly, using a [#0 Phillips screwdriver]{qty:1, cat:tool}

 ![](renders/low_cost_optics_assembly_c270_extra_screw1.png)
 ![](renders/low_cost_optics_assembly_c270_extra_screw2.png)", if: var_lens is c270_lens}}

## Attach the {{includetext:"Pi Camera", if: var_lens is pi_lens}}{{includetext:"assembled camera module", if: var_lens is c270_lens}} {pagestep}

{{includetext:"* Locate the dimple on top of the [camera platform][Camera platform](fromstep){qty:1, cat:printedpart} (highlighted with a red circle in the picture.)
* Take the Pi Camera and place it on top of the camera platform so that the centre of the camera sensor is directly above the dimple.
* Place the lens spacer over the camera
* Use four [No 2 6.5mm self tapping screws]{qty:4, cat:mech} to secure the three parts together using a [#1 pozidrive screwdriver]{qty:1, cat:tool}", if: var_lens is pi_lens}}{{includetext:"* Take the assembled camera and lens spacer and place it on top of the [camera platform][Camera platform](fromstep){qty:1, cat:printedpart}
* Use three of the [No 1 self tapping screws](fromstep){qty:3, cat:mech} that you saved from the camera disassembly to secure the three parts together using a [#0 Phillips screwdriver]{qty:1, cat:tool}", if: var_lens is c270_lens}}
* Take care to not over torque the screws

![](renders/low_cost_optics_assembly_camera_{{var_lens}}.png)

{{includetext:"
## Attach the camera backshell  {pagestep}

* Take the [camera backshell][Camera backshell](fromstep){qty:1, cat:printedpart} printed part and make sure that any brim has been fully removed from the two 'forks' if it was printed with brim
* Turn the assembled camera and platform over
* Arrange the cables so that they are on top of the camera board and leading towards the camera platform
* Place the backshell over the camera board with the cable running out through the slot
* Slide the camera backshell into place to engage the 'forks' with the cut outs on the camera platform. 
* Secure with two [No 2 6.5mm self tapping screws]{qty:2, cat:mech} using a [#1 pozidrive screwdriver]{qty:1, cat:tool}. If the screw holes do not align, check that the backshell is fully engaged on the camera platform and that it is not obstructed by remnants on any brim.

![](renders/low_cost_optics_assembly_c270_backshell1.png)
![](renders/low_cost_optics_assembly_c270_backshell2.png)
![](renders/low_cost_optics_assembly_c270_backshell3.png)", if: var_lens is c270_lens}}

## Attach the mounting screw {pagestep}

* Take an [M3 nut]{qty:1, cat:mech} and push it into the nut trap from the top
* Take an [M3x10 cap head screw][M3x10 cap head screws](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 1, cat:mech} and screw it into the nut.
* Only screw it in a couple of turns. About 5 mm of thread should still be visible

![](renders/low_cost_optics_assembly_screw_{{var_lens}}.png)

{{includetext: "
## Check the ribbon cable {pagestep}

![Diagram of TypeA and TypeB FFC ribbon cables](diagrams/TypeA-TypeB_FFC.png)  

* Place the [{{var_ribbon_len, default:200mm}} Pi Camera ribbon cable]{qty:1, cat:electronic} flat on a table
* Check that the connections are on opposite sides of the cable at the two ends. 

>! **Warning**  
>!  
>! Using a cable of the wrong type will cause the camera to burn out in a few seconds.

## Connect the ribbon cable {pagestep}

* Pull the catch forward on the exposed Pi Camera connector
* Insert the ribbon cable with the contacts towards the board
* Close the catch on the connector


![](renders/low_cost_optics_assembly_ribbon_pi_lens.png)", if: var_lens is pi_lens}}

Set the [complete optics module]{output, qty:1} aside in a safe place.

