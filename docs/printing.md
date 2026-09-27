# Print the plastic parts

>i If you have bought the plastic parts you can skip this step!

{{BOM}}

[PLA filament]: parts/materials/pla_filament.md "{cat:material}"
[Fused Filament 3D printer]: parts/tools/rep-rap.md
[utility knife]: parts/tools/utility-knife.md
[custom print settings]: ./set_slice_gap_closing_radius.md

## Check your printer settings {pagestep}

Check your printer is configured as suggested in the [Configure and test your printer] page.

>i The recommended printer settings are given in the [Configure and test your printer] page. It's also a good idea to try the test print if you have not printed the microscope before.

[Configure and test your printer]: test_your_printer.md#set-your-printer-settings-pagestep

## Printing {pagestep}

>i The microscope body has a custom brim included in the STL. This may require [custom print settings].

Now you have tested your [printer][Fused Filament 3D printer]{qty:1,cat:tool} and [PLA filament][PLA filament]{Qty: {{var_mass_pla}}g, note:"Of any colour you want. Two contrasting colours may look best."} you can print the following parts:

* Actuator assembly tools ([nut tool]{output,qty:1}, [band tool]{output,qty:1}, and [band tool cover]{output,qty:1}):  [actuator_assembly_tools.stl](models/actuator_assembly_tools.stl){previewpage}
* Gear tools ([gear holder]{output,qty:1} and [nut spinner]{output,qty:1}): [gear_tools.stl](models/gear_tools.stl){previewpage}
* [Lens tool]{output,qty:1}: [lens_tool.stl](models/lens_tool.stl){previewpage}
* [Sample clips]{output,qty:2}: [sample_clips.stl](models/sample_clips.stl){previewpage}
{{include: printing{{var_body, default:_motorised}}_only.md}}
{{include: {{var_type}}_only_printing.md}}


## Clean-up of printed parts {pagestep}

>!! **Be careful when removing brim**
>!!
>!! To avoid injury first remove the bulk of the brim without a knife. Remove the remaining brim with a peeling action as described below.

Carefully remove the printing brim from all parts (except the main body).

To remove brim:

1. Use [precision wire cutters](parts/tools/precision-wire-cutters.md){qty:1, cat:tool} to remove most of the brim from the part.
2. Clean up remaining brim with a [utility knife]{qty: 1, cat: tool, note: "Not a scalpel!"}:
    * Hold the knife in your dominant hand with 4 fingers curled around the handle, leaving thumb free.
    * Hold the part in your other hand, as far away from the surface to be cut as possible.
    * Support the part with the thumb of your dominant hand.
    * Place blade on surface to be cut, and carefully close your dominant hand moving the blade, under control, towards your thumb.

![](diagrams/BrimRemoval.png)