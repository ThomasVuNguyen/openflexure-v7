
# Configure and test your printer

>i If you have bought the plastic parts you can skip this step!

{{BOM}}

[PLA filament]: parts/materials/pla_filament.md "{cat:material}"
[Fused Filament 3D printer]: parts/tools/rep-rap.md
[utility knife]: parts/tools/utility-knife.md
[M3 nut]: parts/mechanical.yml#Nut_M3_SS "{cat:mech}"
[2.5mm Ball-end Allen key]: parts/tools/2.5mmBallEndAllenKey.md


## Set your printer settings {pagestep}


* All microscope parts can be printed out of [PLA filament] on most [Fused Filament 3D printers][Fused Filament 3D printer]{Qty:1,cat:tool}.

* Set your slicer to the following printer settings:

|Setting        |Value          |
|------------   |--             |
|Material       |PLA            |
|Layer height   |0.2mm          |
|Nozzle diameter|0.4mm          |
|Supports       |None           |
|Infill         |Printer default|
|Brim           |Recommended for all parts without built in brim|
|Slice gap closing radius |0.001mm Slicer dependent - [see note][slice gap closing radius]|

>! **Do not print with supports**.
>!
>! The microscope has been designed to print without supports. Supports will damage the mechanism.

>i The microscope body has a custom brim included in the STL, and the condenser lens and optics module also contain small gaps. This may require you to set the [slice gap closing radius].

[Slice gap closing radius]: ./set_slice_gap_closing_radius.md

As a general rule, strength is more important than surface finish, so very thin layers (less than 0.15mm or so) are unlikely to result in a microscope that performs any better, though it may improve the appearance.

## Test your print settings {pagestep}

![leg_test.stl](models/leg_test.stl)
![nut_trap_test.stl](models/nut_trap_test.stl)

* Now test whether your printer can print the bridges in the microscope and the custom brim on the main body, and test the assembly of nut traps
* Download the [leg test](models/leg_test.stl){previewpage} and [nut trap](models/nut_trap_test.stl){previewpage} files
* Slice and print the files. Do not add brim in your slicer. This will only use about [5 grams of PLA][PLA filament]{qty: 5g}



## Check your leg test print {pagestep}

![](images/just_leg_test.jpg)
![](images/just_leg_test_brims_annotated.jpg)

* Check that the bridge at the top of the leg test has crossed the gap cleanly 
* The thinner support bridges in the middle of the legs do not need to be complete, but problems there can be an indicator of more hidden printing issues
* Check that the brim has printed as a separate object around the leg
* Check that the brim is easy to remove. If it is difficult to remove, [check that it has not been joined to the leg when sliced](./set_slice_gap_closing_radius.md#checking-the-bottom-layer)

## Test assembly of the nut trap {pagestep}

![](renders/prepare_nut_trap_test1.png)
![](renders/prepare_nut_trap_test2.png)
![](renders/prepare_nut_trap_test3.png)

* Check that the nut hole entrance is clear and free from dangling filament. If there are obstructions this indicates that there are printing issues
* Place an [M3 nut]{qty:1} into the slot in the nut trap test object
* Put an [M3x10 cap head screw][extra M3x10 cap screw](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 1, cat:tool, note:"For mounting trapped nuts"} into the hole above the nut
* Tighten with a [2.5mm Ball-end Allen key]{qty:1, cat:tool} until you feel reasonable resistance.
* Unscrew and remove the screw. The nut should stay mounted.
* Check that you have not crushed the surface of the test object with the screw. If you have, reprint the test object and try using less force to embed the nut.
