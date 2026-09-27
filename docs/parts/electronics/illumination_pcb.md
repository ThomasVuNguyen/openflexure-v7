---
PartData:
  Suppliers:
    Taulab:
      Link: https://taulab.eu/openflexure/4-ofmv7-illumination-kit.html
      PartNo: OFMv7 Illumination Kit
---

# Illumination PCB

As of version 7, the OpenFlexure Microscope uses a PCB rather than just an LED. This can be obtained together with the [Sangaboard v0.5]
as part of the illumination kit at [taulab.eu]. The illumination PCB contains only an LED and connector: the constant-current electronics are on the Sangaboard. This means that the Sangaboard is able to change the brightness of the LED. The design files are available in this [GitLab repository](https://gitlab.com/filipayazi/ofm-led).

If you are unable to get hold of the PCB, it is possible to mount a 5mm LED into the condenser instead, using the [instructions for the LED workaround].

>i There is an older version of the illumination PCB that includes a constant-current driver on board. The older board is usually green, and is circular. The newer boards supplied with Sangaboard v0.5 are usually purple, and have a flat edge. The older PCB can be previewed and ordered via [kitspace], and all design files are available in its [repository][old_repo].  More information, and comparison data between the 5v board and the old LED, is in the [illumination optics explanation]. 

[illumination optics explanation]: ../../info_pages/illumination_optics_explanation.md
[old_repo]: https://gitlab.com/openflexure/openflexure-constant-current-illumination
[kitspace]: https://kitspace.org/boards/gitlab.com/openflexure/openflexure-constant-current-illumination/ofm_cc_illumination_single/
[instructions for the LED workaround]:  ../../workaround_5mm_led/workaround_5mm_led.md
[sangaboard v0.5]: ./sangaboard.md
[taulab.eu]: https://taulab.eu/openflexure/4-ofmv7-illumination-kit.html
