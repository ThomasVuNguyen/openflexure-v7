# Prepare the microscope stand

{{BOM}}

[2.5mm Ball-end Allen key]: parts/tools/2.5mmBallEndAllenKey.md
[M3 nut]: parts/mechanical.yml#Nut_M3_SS
[precision wire cutters]: parts/tools/precision-wire-cutters.md "{cat:tool}"
[utility knife]: parts/tools/utility-knife.md "{cat:tool}"

{{includetext: "
## Remove the supports {pagestep}

![](renders/prepare_stand1.png)

* Take each of the supports (highlighted in red) and rock them backward and forward until they detach from the stand.
* Remove any remaining bumps from the support connection with a [utility knife]{qty:1,cat:tool} or [precision wire cutters]{qty:1}. 
", if: var_body is not _manual}}

## Embed mounting nut in the stand {pagestep}

![](renders/prepare_stand{{var_body, default:}}2.png)
![](renders/prepare_stand{{var_body, default:}}3.png)
![](renders/prepare_stand{{var_body, default:}}4.png)
* Take the [microscope stand][Microscope stand](fromstep){qty:1, cat:printedpart}{{includetext:"
* Place an [M3 nut]{qty:4, cat:mech} in the slot under a mounting lug", if: var_stand is not post}}{{includetext:"
* Place an [M3 nut]{qty:2, cat:mech} in the slot in one of the mounting posts", if: var_stand is post}}
* Put an [M3x10 cap head screw][extra M3x10 cap screw](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 1, cat:tool} into the hole above the nut
* Tighten with a [2.5mm Ball-end Allen key]{qty:1, cat:tool} until you feel reasonable resistance
* Unscrew and remove the screw. The nut should stay mounted.

## Embed {{includetext: "the other mounting nut", if: var_stand is post}}{{includetext: "remaining mounting nuts", if: var_stand is not post}} in the stand {pagestep}

![](renders/prepare_stand{{var_body, default:}}5.png)
![](renders/prepare_stand{{var_body, default:}}6.png)
![](renders/prepare_stand{{var_body, default:}}7.png)

Repeat the above process for the other  {{includetext: "three mounting lugs", if: var_stand is not post}}{{includetext: "mounting post", if: var_stand is post}}

[prepared microscope stand]{output, qty:1, hidden}

