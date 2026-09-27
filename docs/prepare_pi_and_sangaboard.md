# Prepare the Raspberry Pi and Sangaboard

Your Raspberry Pi needs the OpenFlexure Server software in order to work. This is installed as an operating system image on an SD card. The SD card with the custom operating system must be inserted into the Pi, before the Pi is fitted into the microscope stand.

You may have a Pi that you used in a different project. You will need to overwrite that operating system, or keep that SD card to use again and use a new one for the microscope.

Your Sangaboard requires firmware in order to work. If you have purchased the board pre-flashed with firmware, it will already be installed. 

{{BOM}}

[Raspberry Pi v4]: parts/electronics.yml#RaspberryPi "{cat:electronic}"
[micro SD card]: parts/electronics.yml#SD_Card "{cat: electronic, note: you may also need a compatible SD card reader}" 
[Sangaboard v0.5]: parts/electronics/sangaboard.md "{cat:electronic, note: 'If you cannot get a Sangaboard, you can put together [workaround motor electronics](workaround_motor_electronics/workaround_motor_electronics.md) instead.'}"
[vendors]: https://openflexure.org/about/vendors

## Load the OpenFlexure operating system onto the SD card {pagestep}
>i If you have purchased a kit from one of the OpenFlexure [vendors] the Raspbian Openflexure software may already be installed on a supplied SD card.
* Plug the [micro SD card]{qty: 1} into your computer, using a compatible  SD card reader if required.
*{warning} Any files already on the SD card will be erased. Do not proceed if you are unsure.
* Download and install the OpenFlexure operating system, Raspbian-OpenFlexure, as detailed on the ['install'](https://openflexure.org/projects/microscope/install) page of the Openflexure web site.
* When the install process is complete, remove the SD card from your computer.

## Install the SD card in the Raspberry Pi{pagestep}

![](renders/prepare_pi_and_sangaboard1.png)
![](renders/prepare_pi_and_sangaboard2.png)

* Take the [Raspberry Pi V4]{qty: 1} and insert the micro SD card into the slot on the underside of the board at the end opposite the USB ports.
* If you are using the 'Full' version of the operating system, you can test the installation by plugging in a keyboard, mouse and screen at this point and powering it up. You should see the main Desktop. Shut down the Pi afterwards and remove the power.

## Prepare the Sangaboard{pagestep}

>i If you have purchased the board pre-flashed with firmware, it will already be installed.
>! The  Sangaboard v0.5 has small surface mount components, they are not suitable for making by hand! 

![](renders/prepare_pi_and_sangaboard3.png)

* If you have had the board made by a PCB foundry, you will need to obtain the Sangaboard firmware.
* The [Sangaboard v0.5]{qty: 1} page has links to where to obtain the firmware.
* Alternatively you can use the [workaround motor electronics](workaround_motor_electronics/workaround_motor_electronics.md) instead.

[Pi with software]{output, qty:1, hidden}
[Sangaboard with firmware]{output, qty:1, hidden}
