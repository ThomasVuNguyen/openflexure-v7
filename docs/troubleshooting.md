# Troubleshooting


>i The [OpenFlexure forum](https://openflexure.discourse.group) is a great place to get help, advice, solutions and work-arounds from the OpenFlexure Community.

## Camera issues

#### My Raspberry Pi Camera did not come with the lens removal tool

If your Raspberry Pi camera did not come with the tool for removing the lens you can print this tool: 
[picamera_2_lens_removal_tool.stl](models/picamera_2_lens_removal_tool.stl){previewpage}. It is a reasonable alternative to the official tool.

## Actuator assembly issues

#### The viton o-rings break on assembly

The Viton O-rings insertion depends on a number of factors:

* The actuator must be centred and held firmly in place with the nut tool.
* The Viton O-rings must be the correct size (30mm inner diameter, 2mm cross section)
* The Viton O-rings must be the correct material. They must be Viton, not nitrile rubber. Viton comes in multiple hardnesses, we use Viton with a durometer hardness of 75. It is key that the Viton can elongate by at least 150%. Not all suppliers specify elongation and hardness.

#### The screw on the main gear wont go in actuator column

This is probably due to the hole in the actuator not being large enough due to your printer over extruding. The best fix is to re-print the main body with adjusted settings. A work around is to print this jig:

* [actuator_drilling_jig.stl](models/accessories/actuator_drilling_jig.stl){previewpage}

You can push this jig inside the actuator column (where the feet go). This will hold the internal column still so that it can be drilled out carefully with a 3mm drill bit.

#### Feet will not fit the into main body.

This is likely due to the first layer of the main body over extruding slightly.

Very carefully run a utility knife around the inside of the oval space where the feet mount.

>! Be careful not to cut into the flexure mechanism.

## Printing problems

#### Some STL files slice incorrectly

In the past we have seen some STL files slice in very strange ways particularly in older versions of Prusa Slicer. We recommend using version 2.3.3 or newer of Prusa Slicer.

For other slicing issues make sure your slicer is up to date. If this doesn't help we recommend [visiting our user forum](https://openflexure.discourse.group/).