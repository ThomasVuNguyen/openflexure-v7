
# Old versions of the Sangaboard

The motor electronics in the microscope have undergone a number of revisions. As some of these boards are still in circulation, this page describes them. We don't recommend you use any of these in the latest version of the microscope, though it is possible to do so if you are happy figuring out a few details for yourself.

>i A [version 0.5], based on the RP2040 from the Raspberry Pi Pico, is now available and is recommended for this version of the microscope.
>i If you can't get hold of version 0.5, the best option is the [workaround] using easily-available microcontroller boards. This avoids
>i soldering and custom electronics boards.

All versions of the board should be able to use the same firmware. See the [version 0.5] page for details. There exists an older version of the firmware as a [Sangaboard arduino sketch] but this is no longer maintained. 

## v0.1 and v0.2

The first two versions of the board were equivalent to the [workaround] using an Arduino Nano, mounted on a PCB for neatness. 

## v0.3 and v0.4

There is also [version 0.3], a surface-mount design with an integrated ATMEGA32 with Arduino-style programming. The first HAT-shaped board, [version 0.4], also based on ATMEGA32, has been problematic and is **not recommended**. It was intended to simplify wiring and power management, but only a few working boards were made due to problems specifying component values. These versions use surface mount components and custom boards, this makes it hard to solder your own. If you do make a Sangaboard v0.3 or v0.4, you will first need to burn the [custom bootloader], as the ATMEGA32 chip is unlikely to have been pre-flashed with a bootloader. This is not usually a problem for Arduino Nano boards, as they are generally flashed by the supplier.

>i Sangaboard v0.3 and v0.4 have two micro-USB ports.  One is for power only, the other is for data only.  You must upload the firmware using the "data" port.

## Uploading firmware

If you have an older Sangaboard, you can check if it needs a bootloader. It's often easier to do this before it's mounted into the microscope. Plug the Sangaboard into a computer, using the "data" micro-USB port.  If it shows up as a Sangaboard (or as a USB serial port) when plugged into a computer, this means you already have a bootloader and can skip the next bullet point and go straight to uploading the firmware. If you are using an Arduino Nano (supplied as default with a bootloader), you can also skip this step.

For home-made Sangaboard v0.3 and v0.4, the [custom bootloader] repository folder contains instructions on how to flash it onto the ATMEGA32 chip on your Sangaboard.

Once you have the a working bootloader, you should upload the firmware. The [Sangaboard arduino sketch] gives instructions on uploading it, but this version is no longer maintained. The newer firmware will still support Arduino boards, see the [workaround] page for details.


[custom bootloader]: https://gitlab.com/bath_open_instrumentation_group/sangaboard/-/tree/master/Bootloader
[Sangaboard arduino sketch]: https://gitlab.com/bath_open_instrumentation_group/sangaboard/-/tree/master/arduino_code
[version 0.5]: ./sangaboard.md
[version 0.3]: https://kitspace.org/boards/gitlab.com/bath_open_instrumentation_group/sangaboard/sangaboard_v0.3/
[version 0.4]: https://kitspace.org/boards/gitlab.com/bath_open_instrumentation_group/sangaboard/sangaboard_v0.4/
[workaround]: ../../workaround_motor_electronics/workaround_motor_electronics.md


