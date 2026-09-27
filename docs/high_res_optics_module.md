# Assemble the high-resolution optics module

The imaging optics for this version of the microscope consist of an RMS objective, a tube lens[i](info_pages/imaging_optics_explanation.md) and the Raspberry pi camera. With a 40x objective lens the field of view is about 360×270μm. 

The full optical system  (with the illumination optics) is arranged as shown below.

![Optics cutaway](renders/optics_assembled.png)


{{BOM}}

[M3 nut]: parts/mechanical.yml#Nut_M3_SS
[No 2 6.5mm self tapping screws]: parts/mechanical.yml#SelfTap_PoziPan_No2x6.5_SS
[#1 pozidrive screwdriver]: parts/tools/pozidrive_1_screwdriver.md "{cat:tool}"
[Pi Camera lens tool]: parts/tools/pi_camera_lens_tool.md "{cat:tool, note: 'This should come with the [Raspberry Pi Camera Module v2](parts/electronics.yml#PiCamera_2).  If it is missing, you can 3D print a [workaround lens removal tool](workaround_lens_removal_tool.md).'}"

[Raspberry Pi Camera Module v2]: parts/electronics.yml#PiCamera_2 "{cat:electronic}"
[{{var_ribbon_len, default:200mm}} Pi Camera ribbon cable]: parts/electronics/camera_cable_{{var_ribbon_len, default:200mm}}.md "{cat:electronic, note: 'Make sure that the cable is Type B, as identified in the part page'}"

## Visually inspect the optics module {pagestep}

Take the [optics module][Optics module](fromstep){qty:1, cat:printedpart} and confirm that:

* It has been printed in black [i](info_pages/why_optics_black.md)
* It is dust free (You can blow air through to clean it)
* The central shaft is not obstructed by strings of plastic


## Insert the tube lens[i](info_pages/imaging_optics_explanation.md) {pagestep}

* Place the [lens tool][Lens tool](fromstep){qty:1, cat:printedtool} on a steady surface
* Place the [12.7 mm achromatic lens](parts/optics/tube_lens.md){qty:1, cat:optical} on the lens tool
* Check the lens has the more curved side facing down
* Take the optics module and place carefully over lens
* Push down hard to seat the lens in the optics module
* Visually inspect the positioning of the lens. It should be flat, not seated at an angle. If necessary, push against the [lens tool][Lens tool](fromstep){qty:1, cat:printedtool} to align properly

![Insert tube lens](renders/optics_assembly_tube_lens.png)

## Remove Pi Camera Lens {pagestep}


>! **Caution!**
>!
>! The camera board is static sensitive.

* Before touching the Pi Camera touch a metal earthed object. If you own one, consider wearing and anti-static strap.
* Take the [Pi Camera][Raspberry Pi Camera Module v2]{Qty:1} out of the package. Make sure to **hold it only by the sides of the board**.
* Take the protective film off the lens.
* Take the [Pi Camera lens tool]{qty: 1} and place it over the lens
* Slowly unscrew the lens (About 4 full turns of the tool)
* Carefully lift off the lens. We do not use the lens in this version of the microscope.

![](renders/picam1.png)
![](renders/picam2.png)
![](renders/picam3.png)

## Attach the Pi Camera {pagestep}

* Take the Pi Camera and place it on the back of the optics module
* Place the [pi camera cover](fromstep){qty:1, cat:printedpart} over the back of the Pi Camera.
* Use two [No 2 6.5mm self tapping screws]{qty:2, cat:mech} to secure the camera using a [#1 pozidrive screwdriver]{qty:1, cat:tool}
* Take care to not over torque the screws.

![Attach pi camera](renders/optics_assembly_camera.png)


## Attach the objective {pagestep}

* Take your [microscope objective](parts/optics/microscope-objective.md){qty:1, note:"This page provides more information on choosing an objective.", cat:optical} and the partially assembled optics module
* Place objective on top of optics module
* **Check that the objective is not tilted!**
* Carefully and slowly screw the objective into the optics module, taking care to ensure it does not tilt.

![Attach the objective](renders/optics_assembly_objective.png)


## Attach the mounting screw {pagestep}

* Take an [M3 nut]{qty:1, cat:mech} and push it into the nut trap from the top
* Take an [M3x10 cap head screw][M3x10 cap head screws](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 1, cat:mech} and screw it into the nut.
* Only screw it in a couple of turns. About 5 mm of thread should still be visible

![Attach mounting screw](renders/optics_assembly_screw.png)

## Check the ribbon cable {pagestep}

![Diagram of TypeA and TypeB FFC ribbon cables](diagrams/TypeA-TypeB_FFC.png)  

* Place the [200mm Pi Camera ribbon cable]{qty:1} flat on a table
* Check that the connections are on opposite sides of the cable at the two ends. 

>! **Warning**  
>!  
>! Using a cable of the wrong type will cause the camera to burn out in a few seconds.

## Connect the ribbon cable {pagestep}

* Pull the catch forward on the exposed Pi Camera connector
* Insert the ribbon cable with the contacts towards the board
* Close the catch on the connector

![Attach ribbon cable](renders/optics_assembly_ribbon.png)

## Set the complete module aside {pagestep}

Set the [complete optics module]{output, qty:1} aside in a safe place.
