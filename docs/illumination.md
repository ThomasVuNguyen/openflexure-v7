# Assemble the illumination

In this section we are assembling the transmission illuminator.  This mounts the LED and condenser lens above the sample, so the transmitted light can be imaged by the microscope objective.

{{BOM}}

[No 2 6.5mm self tapping screws]: parts/mechanical.yml#SelfTap_PoziPan_No2x6.5_SS "{cat:mech}"
[#1 pozidrive screwdriver]: parts/tools/pozidrive_1_screwdriver.md "{cat:tool}"
[illumination PCB]: ./parts/electronics/illumination_pcb.md "{cat:electronic, note: 'A 5mm LED can be used instead, if you follow the [LED workaround](./workaround_5mm_led/workaround_5mm_led.md).'}"

[LED workaround]: ./workaround_5mm_led/workaround_5mm_led.md

>i If the illumination PCB is not available, you can use a 5mm LED instead, by following the [LED workaround].


## Push-fit the lens {pagestep}

![](renders/{{includetext:"upright_", if: var_type is upright}}optics_assembly_condenser_lens.png) 

* Place the [condenser lens](parts/optics/condenser_lens.md){qty:1, cat:optical} on the [lens tool][Lens tool](fromstep){qty:1, cat:printedtool} flat side down
* Take the {{includetext: "[condenser arm][Condenser arm](fromstep){qty:1, cat:printedpart}", if: var_type is not upright}}{{includetext: "[upright condenser][upright condenser](fromstep){qty:1, cat:printedpart}", if: var_type is upright}} and align the opening over the lens
* Push down until the lens clicks into place.
* Visually inspect the positioning of the lens. It should be flat, not seated at an angle. If necessary, push against the [lens tool][Lens tool](fromstep){qty:1, cat:printedtool} to align properly.

{{include: condenser_retaining_screw.md, if: var_type is not upright}}

## Cut out the diffuser {pagestep}

* Take a small sheet of [0.5mm polypropylene]{qty: 4cm^2} [i](info_pages/illumination_optics_explanation.md).
* Cut out a circle, approximately 14mm in diameter, using a [utility knife]{qty:1}.  It is better to be slightly smaller than required, rather than slightly larger.
* Using the [condenser board spacer](fromstep) as a guide, make two small holes for the screws that mount the illumination.
* The diffuser is shown in white in the next step.

[0.5mm polypropylene]: parts/materials/white_polypropylene_sheet.md "{cat:material}"
[utility knife]: parts/tools/utility-knife.md "{cat: tool}"

## Mount the diffuser and LED board {pagestep}

![](renders/{{includetext:"upright_", if: var_type is upright}}mount_led_board1.png)
![](renders/{{includetext:"upright_", if: var_type is upright}}mount_led_board2.png)
![](renders/{{includetext:"upright_", if: var_type is upright}}mount_led_board3.png)
![](renders/{{includetext:"upright_", if: var_type is upright}}mount_led_board4.png)

* Turn the condenser over, so the flat side is on top {{includetext:"
* Note the position of the small slot in the side", if:var_type is upright}}
* Place the diffuser on the condenser, then the [condenser board spacer][Condenser board spacer](fromstep){qty:1, cat:printedpart}{{includetext:", then the [illumination PCB]{qty:1}", if:var_type is not upright}}{{includetext:"
* Place the [illumination PCB]{qty:1} with the pins towards the slot", if:var_type is upright}}  
* Fix in place with two [No 2 6.5mm self tapping screws]{qty:2} using a [#1 pozidrive screwdriver]{qty:1}

## Assemble the illumination cable {pagestep}
* Take a [red pre-crimped female-female jumper cable (30 cm)][Pre-crimped Female-Female jumper cable (30 cm), Red]{qty:1} and a [black pre-crimped female-female jumper cable (30 cm)][Pre-crimped Female-Female jumper cable (30 cm), Black]{qty:1}.
* Attach a [2 pin Du Pont connector female housing]{qty:2} to each end.

[2 pin Du Pont connector female housing]: parts/electronics.yml#DuPont_Housing_1x2 "{cat:electronic}"
[Pre-crimped Female-Female jumper cable (30 cm), Red]: parts/electronics.yml#JumperCable_FF_300mm_Red "{cat:electronic}"
[Pre-crimped Female-Female jumper cable (30 cm), Black]: parts/electronics.yml#JumperCable_FF_300mm_Black "{cat:electronic}"

## Attach the illumination cable {pagestep}

![](renders/{{includetext:"upright_", if: var_type is upright}}mount_led_cable1.png)
![](renders/{{includetext:"upright_", if: var_type is upright}}mount_led_cable2.png)

* Attach the illumination cable to the [illumination PCB]
* Make sure that the red wire is attached to the terminal labelled '+'

## Attach the {{includetext:"illumination cover", if: var_type is not upright}}{{includetext:"condenser to the condenser platform", if: var_type is upright}} {pagestep}

![](renders/{{includetext:"upright_", if: var_type is upright}}mount_condenser_lid1.png)
![](renders/{{includetext:"upright_", if: var_type is upright}}mount_condenser_lid2.png)
![](renders/{{includetext:"upright_", if: var_type is upright}}mount_condenser_lid3.png)
![](renders/{{includetext:"upright_", if: var_type is upright}}mount_condenser_lid4.png)

{{includetext:"* Place the [condenser lid][Condenser lid](fromstep){qty:1, cat:printedpart} on top of the condenser assembly.", if: var_type is not upright}}{{includetext:"
* Place the assembled condenser on the [upright condenser platform][upright condenser platform](fromstep){qty:1, cat:printedpart}.
>i Check that the illumination wiring and the small slot in the condenser body are both pointing away from the mounting dovetail.", if: var_type is upright}}  
* Secure in place with two [No 2 6.5mm self tapping screws]{qty:2} using a [#1 pozidrive screwdriver]{qty:1}.

{{include: upright_condenser_retaining_screw.md, if: var_type is upright}}

[assembled illumination module]{output, qty:1, hidden}