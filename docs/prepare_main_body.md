# Prepare the main body

{{BOM}}

[utility knife]: parts/tools/utility-knife.md
[precision wire cutters]: parts/tools/precision-wire-cutters.md "{cat:tool, note:'Can use a utility knife if these are unavailable.'}"
[M3 nut]: parts/mechanical.yml#Nut_M3_SS
[2.5mm Ball-end Allen key]: parts/tools/2.5mmBallEndAllenKey.md

## Remove brim and supports {pagestep}

![](renders/brim_and_ties{{var_body, default:}}1.png)
![](renders/brim_and_ties{{var_body, default:}}2.png)
![](renders/brim_and_ties{{var_body, default:}}3.png)

The [main body][{{includetext: "manual ", if: var_body is _manual}}main body](fromstep){cat: PrintedPart, qty:1} has some custom supports and a custom brim to remove. These are highlighted in red in the images.  

* Remove the brim with a [utility knife]{qty:1,cat:tool} and [precision wire cutters]{qty:1}
* Cut out the ties inside the actuator columns (6 total) with the [precision wire cutters]{qty:1}
* Cut out the ties for the rear legs (4 total) with the [precision wire cutters]{qty:1} and trim the stubs flush, so that they do not obstruct the stage movement 

## Embed mounting nuts in the stage {pagestep}

![](renders/prepare_main_body{{var_body, default:}}1.png)
![](renders/prepare_main_body{{var_body, default:}}2.png)
![](renders/prepare_main_body{{var_body, default:}}3.png)


* Place an [M3 nut]{qty:4} into one of the slots at the side of the stage
* Put an [M3x10 cap head screw][extra M3x10 cap screw](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 1, cat:tool, note:"For mounting trapped nuts"} into the hole above the nut
* Tighten with a [2.5mm Ball-end Allen key]{qty:1, cat:tool} until you feel reasonable resistance.
* Remove the screw. The nut should stay mounted.
* Repeat for the other three holes in the stage.

![](renders/prepare_main_body{{var_body, default:}}4.png)
![](renders/prepare_main_body{{var_body, default:}}5.png)
![](renders/prepare_main_body{{var_body, default:}}6.png)

## Embed mounting nuts in the illumination platform {pagestep}

![](renders/prepare_main_body{{var_body, default:}}7.png)
![](renders/prepare_main_body{{var_body, default:}}8.png)
![](renders/prepare_main_body{{var_body, default:}}9.png)

* Repeat the steps used above to add {{var_illum_nuts_words, default:two}} [M3 nuts][M3 nut]{qty:{{var_illum_nuts, default:2}}, cat:mech} into the platform above the z-axis{{includetext:". You do not need to insert a nut in the third hole on the illumination platform", if: var_illum_nuts_words is not three}}

{{include:prepare_main_body_motor_nuts.md, if: var_body is not _manual}}

The [prepared main body]{output, qty:1} is now ready for assembly.
