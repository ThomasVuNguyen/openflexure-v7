# Wire up motor electronics without a Sangaboard

This page describes how to connect the microcontroller and three motor driver boards, to make a Sangaboard-compatible motor control solution without custom PCBs.

[28BYJ-48]: ../parts/electronics.yml#28BYJ-48 "{cat: electronic}"
[28BYJ-48 driver board]: ../parts/electronics.yml#28BYJ-48-Driver "{cat: electronic}"
[Arduino Nano]: ../parts/electronics.yml#ArduinoNano "{cat: electronic}"
[jumper cables]: ../parts/electronics.yml#JumperCable "{cat: electronic}"
[solder]: ../parts/consumables/solder.md "{cat: consumable}"
[soldering iron]: ../parts/tools/soldering_iron.md "{cat: tool}"
[heatshrink tubing]: ../parts/electronics.yml#Heatshrink_4.8mm_Black "{cat: consumable, note:'Electrical tape can be used if heatshrink is not available.'}"
[precision wire cutters]: ../parts/tools/precision-wire-cutters.md "{cat: tool}"

{{BOM}}

## Wire up the boards {pagestep}

Each of your motors should have come with a [driver board][28BYJ-48 driver board]{qty:3, cat:electronic}. You should wire these up to an [Arduino Nano]{qty:1, cat:electronic} using [jumper cables]{qty: 12, cat:electronic} as shown in the diagram below:

![Simple motor controller with Arduino](../images/sangaboard_simple.png)

**The motor order is x-motor, y-motor, z-motor from top to bottom of this diagram.**

## Wire up the power {pagestep}

We use a [soldering iron]{qty:1} to create the power cables. 

To power the boards you need a 5V voltage source. We create this from a USB power supply.

* Tun on the [soldering iron]{qty:1} to the correct temperature for your [solder]{qty:A little}
* Cut the end off the cable with [wire cutters][precision wire cutters]{qty:1}
* Strip back a portion of the outer cable
* Locate the Vcc (usually the red wire) and GND wires (usually the black wire)
* Cut one end off 7 [jumper cables]{qty: 7}. (Preferably 4 black and 3 red)
* Solder 4 of these cables to the GND cable of the power supply
* Solder the other 3 to the Vcc cable of the power supply
* Protect the joints with [heatshrink tubing]{qty: A little}.
* Connect up the power (with the supply off) as shown in the diagram above.
