# Prepare the separate z-actuator

{{BOM}}

[utility knife]: parts/tools/utility-knife.md "{cat:tool}"
[precision wire cutters]: parts/tools/precision-wire-cutters.md "{cat:tool}"
[M3 nut]: parts/mechanical.yml#Nut_M3_SS
[2.5mm Ball-end Allen key]: parts/tools/2.5mmBallEndAllenKey.md

## Remove brim and supports {pagestep}

![](renders/brim_and_ties_separate_z1.png)
![](renders/brim_and_ties_separate_z2.png)

The [separate z-actuator](fromstep){cat: PrintedPart, qty:1} has some custom supports and a custom brim to remove. These are highlighted in red in the images.

* Remove the brim with [utility knife]{qty:1} and [precision wire cutters]{qty:1}
* Cut the ties inside actuator column (2 total) with the precision wire cutters

## Embed mounting nuts for the Z motor {pagestep}

![](renders/prepare_z_axis1.png)
![](renders/prepare_z_axis2.png)
![](renders/prepare_z_axis3.png)

* Place an [M3 nut]{qty:2, cat:mech} into one of the slots
* Put an [M3x10 cap head screw][extra M3x10 cap screw](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 1, cat:tool, note:"For mounting trapped nuts"} into the hole above the nut
* Tighten with a [2.5mm Ball-end Allen key]{qty:1, cat:tool} until you feel reasonable resistance.
* Remove the screw. The nut should stay mounted.
* Repeat for the other side.

[prepared separate z actuator]{output, qty:1, hidden}