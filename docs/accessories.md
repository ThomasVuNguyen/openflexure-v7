# Accessories

* [1 Inch Disc Holder](models/accessories/1_inch_disc_holder.stl){previewpage}

To hold a 1 inch calibration target for use on the Microscope stage.

* [Slide Box for 16 slides](models/accessories/slide_box_16.stl){previewpage}
* [Slide Box for 24 slides](models/accessories/slide_box_24.stl){previewpage}

Create Slide Boxes for ``XX`` slides with

``openscad -D "N_SLIDES = XX" openscad/accessories/slide_box.scad -o slide_box-XX.stl``

These fit standard slides with 75x25mm aka 3x1 inches. For slides of different dimmensions edit ``openscad/accessories/slide_box.scad``.

# Footprints

These footprints may be useful to create things to put the microscope in or on.

[![](models/accessories/footprint.svg)](models/accessories/footprint.svg)

Footprint of the [microscope_stand](models/microscope_stand.stl){previewpage}. May be useful to create transport cases, padding or a raised stand.

[![](models/accessories/footprint_pocket.svg)](models/accessories/footprint_pocket.svg)

A variant be used to laser-cut a pocket for the microscope to sit neatly in a baseplate. Make a laser cut base by "pocketing" the difference between the two lines and cutting the smaller of the two - so the microscope sits on a 3mm wide lip. This works more nicely than just a big pocket.

[![](models/accessories/bottom_of_main_body.svg)](models/accessories/bottom_of_main_body.svg)

The footprint of the microscope stage without the stand. Note that this is not lowest point of the assembled stage. The actuators move below the bottom of the stage and have [feet](models/feet.stl){previewpage} attached on the bottom, and the legs opposite the actuators move down as the stage moves. The optics module also needs room below. You will need to adapt the shape for your particular use.
