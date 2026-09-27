# Assembly Instructions
[![](images/microscopes_less_wide.jpg)](high_res_microscope.md)  
The OpenFlexure Microscope is a 3D printable microscope, with a very precise mechanical translation stage. It is fully motorised, including autofocus, for robotic microscopy, slide scanning and time lapse imaging.  
The microscope is highly [customisable](customisation.md). Find about more about the microscope on the [OpenFlexure website](https://openflexure.org/projects/microscope).

These instructions will take you through how to assemble various configurations. 

## Microscope Configurations:

### [High-resolution motorised microscope](high_res_microscope.md)
[![A render of the completed high resolution microscope.](renders/complete_microscope_rms1.png)](high_res_microscope.md)  
[Interactive 3D view of the finished microscope.](interactive_3d_view_rms.md) 

>? **Choose this microscope** if you want the most tested and highest performance OpenFlexure Microscope.
This configuration of the microscope uses a traditional microscope objective for highest image quality.  
It is motorised for autofocus and automatic scanning.

### [Motorised microscope with low-cost optics](low_cost_microscope.md)
[![A render of the completed microscope using the Raspberry Pi camera module's lens.](renders/complete_microscope_low_cost1.png)](low_cost_microscope.md)  
[Interactive 3D view of the finished microscope.](interactive_3d_view_low_cost.md) 

>? **Choose this microscope** if you want a microscope equivalent to a traditional 20x objective lens.  
>?  You can also test out the OpenFlexure Microscope before purchasing more specialist optics.
This configuration of the microscope uses the original lens from a Raspberry Pi camera module.  The field of view and resolution are similar to a conventional 20x microscope objective.  
It is motorised for autofocus and automatic scanning.

### [Upright microscope](upright_microscope.md)
[![A render of the completed upright microscope.](renders/complete_microscope_upright1.png)](upright_microscope.md)  
[Interactive 3D view of the finished microscope.](interactive_3d_view_upright.md)

>? **Choose this microscope** if you want to look at a sample that cannot be turned upside-down. 
This configuration of the microscope has the objective above the sample rather than below.  
It is motorised for autofocus and automatic scanning.

### [Manual microscope](manual_microscope.md)
[![A render of the completed manual microscope, using a Logitech C270 camera.](renders/complete_microscope_c270_manual1.png)](manual_microscope.md)  
[Interactive 3D view of the finished microscope.](interactive_3d_view_c270_manual.md)

>? **Choose this microscope** with any of the available optics modules if you do not need remote or automated operation.  
>? It can also be the lowest cost option and it is a great tool for education and a great introduction to building your own scientific equipment.
This configuration of the microscope has thumbwheels for manual motion control, instead of using motors. It does not give access to robotic microscopy, so does not take advantage of many of the key features of the motorised microscope like autofocus. All [optics options](customisations/optics_options.md) are compatible, however when built with a USB camera it is a compact and very low-cost digital manual microscope.

## Customising your microscope

The OpenFlexure Microscope is designed to be customisable. There are a number of customisation options already available as discussed on our [customisations and alternatives page](customisation.md).

If you want to get more hands on with customisation all source files are available. You can either [download a zip of the source files for this release](source.zip) or visit our [GitLab page](https://gitlab.com/openflexure/openflexure-microscope/) to see our ongoing development. In preparation for the release of v7, we also save a [hash file](models/dependency_hashes.yaml.gz) that will allow us to determine which STL files have changed between revisions.
