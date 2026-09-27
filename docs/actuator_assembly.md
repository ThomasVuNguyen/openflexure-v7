# Assemble the actuators

There is one "actuator column" for each of the three axes of the OpenFlexure Microscope stage{{includetext: ", and a fourth for the separate z-actuator", if: var_body is _upright}}. These allow you to move the sample in X and Y, or focus the microscope by moving in Z. 


{{BOM}}

[M3x25mm stainless steel hex bolt]: parts/mechanical.yml#HexBolt_M3x25mm_SS
[M3 brass nut]: parts/mechanical.yml#Nut_M3_Brass
[M3 stainless steel washers]: parts/mechanical.yml#Washer_M3_SS
[Viton O-ring (30mmx2mm)]: parts/mechanical.yml#O-Ring_30x2_Viton

[light oil]: parts/consumables/light_oil.md

{{includetext: "![Parts required for actuator assembly](renders/actuator_assembly_parts{{var_actuators, default:}}.png)", if: var_n_actuators is 3}}
{{includetext: "![Parts required for actuator assembly](renders/actuator_assembly_parts_upright.png)", if: var_n_actuators is 4}}

## Mount the leadscrew {pagestep}

![](renders/actuator_assembly_lead_screw_exploded{{var_actuators, default:}}.png)
![](renders/actuator_assembly_lead_screw_tight{{var_actuators, default:}}.png)
![](renders/actuator_assembly_lead_screw_only{{var_actuators, default:}}.png)

* Take one of the [hex bolts][M3x25mm stainless steel hex bolt]{qty:{{var_n_actuators, default:3}}, cat:mech}
* Push it through one of the [{{includetext: "thumbwheels", if: var_actuators is _manual}}{{includetext: "large gears", if: var_actuators is not _manual}}](fromstep){qty:{{var_n_actuators, default:3}}, cat:printedpart}, and the [nut spinner](fromstep){qty:1, cat:printedtool}
* Start to screw on a [steel M3 nut][extra M3 nut](parts/mechanical.yml#Nut_M3_SS){qty: 1, cat:tool, note:"For mounting the hex bolt in the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "large gear", if: var_actuators is not _manual }}"}, this should fit into the end of the nut spinner{{includetext: "
* Place the [gear holder](fromstep){qty:1, cat:printedtool} over the large gear", if: var_actuators is not _manual}}
* Tighten, by turning the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear holder", if: var_actuators is not _manual}} and nut spinner in opposite directions. This should bed the screw into the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear", if: var_actuators is not _manual}}
* Remove the tools by unscrewing the nut with the nut spinner. The hex bolt should now be mounted in the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear", if: var_actuators is not _manual}}

## Insert the nut {pagestep}

![Insert the nut into the actuator column](renders/actuator_assembly_nut{{var_body, default:}}.png)
![Check nut seated flat](diagrams/NutSitFlat.png)

* Insert a [brass nut][M3 brass nut]{qty:{{var_n_actuators, default:3}}, cat:mech} into the x actuator through the hole in the front of the [main body][prepared main body](fromstep){qty:1, cat:subassembly}
* Looking through the hole you should see the side of the nut. If it is tilted so you can see the top, tap the microscope until it sits flat

## Attach the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear", if: var_actuators is not _manual }}{pagestep}

![Washer direction](diagrams/washer-direction.png)
![Gear attachment exploded](renders/actuator_assembly_gear{{var_body, default:}}.png)
![Gear attachment](renders/actuator_assembly_gear2{{var_body, default:}}.png)

* Line up two [washers][M3 stainless steel washers]{qty:{{var_n_washers, default:6}}, cat:mech} so that the slightly curved sides are facing each other
* Take the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear", if: var_actuators is not _manual }} with the hex bolt mounted into it, and push it through the two washers
* Push the bolt through the hole at the top of the x actuator until it reaches the nut
* Screw the bolt into the nut until the nut is completely lifted up. (If the nut turns hold it in place with the [nut tool](fromstep){qty:1, cat:printedtool})

## Oil the lead screw {pagestep}

* Lift the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear", if: var_actuators is not _manual }} so you can see about 5mm of screw thread underneath
* Add one drop of [light oil]{qty:{{var_n_actuators, default:3}} drops, cat:consumable, Note: "Don't skip this or you will damage the screws"} onto the screw thread

![oil lead screw](renders/actuator_assembly_oil{{var_body, default:}}.png)

## Assemble the band insertion tool {pagestep}

![The band tool arms and holder](renders/band_tool_assembly1.png)
![The assembled band tool](renders/band_tool_assembly2.png)

* Insert the two arms of the [band tool](fromstep){qty:1, cat:printedtool} into the [band tool cover](fromstep){qty:1, cat:printedtool}

## Prepare the actuator {pagestep}

![Check actuator position](diagrams/ActuatorPosition.png)

* Look through the hole you inserted the nut into
* You should be able to see the screw thread of the hex bolt
* Rotate the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear", if: var_actuators is not _manual }} until the screw is clearly visible through this hole
* Push the [nut tool]{qty:1} into the hole to hold the internal actuator in place

## Attach the viton bands and foot {pagestep}

![Actuator prepare](renders/band_instruction{{var_actuators, default:}}1.png)
![Actuator cutaway](renders/band_instruction{{var_actuators, default:}}2.png)
![Actuator insert band](renders/band_instruction{{var_actuators, default:}}3.png)
![Actuator stretch band](renders/band_instruction{{var_actuators, default:}}4.png)
![Actuator pull tool out](renders/band_instruction{{var_actuators, default:}}5.png)
![Actuator finished](renders/band_instruction{{var_actuators, default:}}6.png)

This is the trickiest part of the microscope build. In this step you will clip bands onto hooks inside each actuator.

* Take the [foot][feet](fromstep){qty:{{var_n_actuators, default:3}}, note:"Each actuator has its own labelled foot", cat:printedpart} for the x actuator
* Loop a [viton band][Viton O-ring (30mmx2mm)]{qty:{{var_n_actuators, default:3}}, note: '"Viton band"', cat:mech} through the foot
* Push the assembled [band tool](fromstep){qty:1, cat:printedtool} through the foot and hook the band onto the tool on each side
* Align the foot under the microscope so that the letter faces outwards
* Place the foot onto the actuator
* Check that the nut tool is still blocking the actuator column
* Push the band tool into the microscope until the band clicks into place. This requires some force
* Remove the band tool

![attach actuator foot](renders/actuator_assembly_x{{var_body, default:}}.png)

>? If you had problems with this step see our [troubleshooting page](troubleshooting.md#actuator-assembly-issues).

## Seat the foot {pagestep}

* If the foot did not click into place during actuator assembly align it and push it into place
* The foot should sit flush with the base of the microscope
* The front of the foot should align with the front of the actuator


## Repeat this process for Y and Z {pagestep}

![Actuators assembled](renders/actuators_assembled{{var_body, default:}}.png)

* Follow the same procedure  to install the {{includetext: "thumbwheel", if: var_actuators is _manual}}{{includetext: "gear", if: var_actuators is not _manual}}, foot and Viton band for the Y and Z axes
* Make sure that you have put a drop of light oil on both of the threads
* Make sure that both feet are seated
* Make sure that each axis has two washers

{{include: upright_separate_z_actuator_assembly.md, if: var_body is _upright}}

[microscope with assembled actuators]{output, qty:1, hidden}

## Centre the actuators {pagestep}

![Check actuator position](diagrams/ActuatorPosition.png)

* Look through the hole where you inserted the brass nut into in the x actuator
{{include: centre_actuators_text.md}}
