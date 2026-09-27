---
Tags: knowledge
---
# The OpenFlexure Microscope Illumination

The standard configuration of the OpenFlexure microscope is for transmission bright-field imaging: the sample is illuminated from one side, and the transmitted light is imaged on the other side.  This works particularly well for nearly-transparent, thin samples, where image contrast comes from absorption of light.  This was the first, and still most widely used, way of taking microscopic images.  

## Aims of illumination

There are a few things that are important when designing the illumination for a microscope.  One of the most important is to have *even* illumination across the sample - i.e. the intensity stays the same, and there is no noticeable structure in the illumination light.  The range of angles from which it is illuminated needs to be large enough that it doesn't affect the resolution of the image, small enough not to hurt contrast, and stay uniform across the image.  The gold standard for achieving this with a filament bulb is Koehler illumination, where the lamp is placed such that it is perfectly out of focus in the sample.

This page is not (yet) a tutorial on Koehler illumination, but the [wikipedia article on Koehler illumination](https://en.wikipedia.org/wiki/K%C3%B6hler_illumination) is a good place to start.

## Critical illumination

A much simpler scheme uses a diffuser, which is placed quite close to an aperture.  This aperture is then *imaged* onto the sample.  We rely on the diffuser to create an even illumination, and use the aperture to set the area of the sample that's illuminated.  This can be quite wasteful of light, however modern LED sources are incredibly bright compared to halogen lamps, and so at least for transmission imaging (where it's very rare to be short of light) this is a very good option.

### Diffuser

Previous versions of the OpenFlexure Microscope used white tape as a diffuser.  The tape, on the surface of the LED, was then imaged onto the sample by an acrylic lens.  The latest version uses a diffuser made of a flat sheet of white plastic.  This is mechanically more reliable, and less prone to tearing or uneven stretching when it is assembled - that results in a more even image.

### Light source

The latest version of the microscope uses a small PCB for illumination, with an LED and constant-current driver.  This replaces the 5mm LED and resistor used in previous designs.  It is mechanically more reliable, eliminates wire-to-wire soldering, and is much more manufacturable at scale.  The constant-current driver should result in more stable illumination, and mounting it with screws rather than a push-fit should give a much more repeatable assembly.  The surface-mount LED is also brighter than the 5mm LEDs we used previously.

### Testing

We tested the new condenser with both 5mm LED and PCB, against the old condenser with 5mm LED and tape diffuser.  The new condenser was at least as bright, and the recommended configuration (PCB, spacer, and diffuser) produced bright images with a 40x objective and 6.2ms exposure time.  At 100x, this exposure time should increase by a factor of 2.5 squared, which gives 38.6ms.  For imaging at 30 frames per second, we can have a maximum exposure of about 33ms, which will still give acceptably bright images with unity gain on the camera.

The test was mainly looking for brightness, but I also assessed whether there were out of focus objects visible in the background - this is a good test of whether we are illuminating the full aperture of the condenser lens (i.e. whether we are using a high enough range of angles in the illumination).

| Configuration | Exposure time (us) | Notes |
|---------------|--------------------|-------|
| PCB on spacer on diffuser, screwed onto condenser | 6078us | Best image - out of focus objects were fainter |
| PCB on diffuser, screwed onto condenser | 3848us | Brighter but mechanically less robust. |
| PCB without diffuser, screwed onto condenser | 917us | Incredibly bright but not uniform.  Also much more blue than with the diffuser. |
| Diffuser on PCB, screwed into lid | 3809us | |
| Diffuser on spacer on PCB, screwed into lid | 11806us | |
| Previous illumination with 5mm LED and tape | ~1000us | NB not taken in the same set of images as the above, but should be comparable |

The previous illumination (5mm LED and tape) is brighter than the new illumination, but not by a huge amount - something between a factor of 4 and 8 depending on exactly how it's done.  However, the new illumination should be bright enough for everything we want to do, and can be built much more consistently.
