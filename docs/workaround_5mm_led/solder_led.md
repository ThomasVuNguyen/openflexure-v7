[150 Ohm Resistor]: ../parts/electronics.yml#Resistor_150R
[Warm white 5mm LED]: ../parts/electronics.yml#LED_WarmWhite
[2 pin Du Pont connector female housing]: ../parts/electronics.yml#DuPont_Housing_1x2
[Red pre-crimped Female-Female jumper cable (30 cm)]: ../parts/electronics.yml#JumperCable_FF_300mm_Red
[Black pre-crimped Female-Female jumper cable (30 cm)]: ../parts/electronics.yml#JumperCable_FF_300mm_Black
[Black heatshrink - 4.8mm ID]: ../parts/electronics.yml#Heatshrink_4.8mm_Black
[Red heatshrink - 2.4mm ID]: ../parts/electronics.yml#Heatshrink_2.4mm_Red
[solder]: ../parts/consumables/solder.md
[soldering iron]: ../parts/tools/soldering_iron.md "{cat:tool}"
[wire strippers]: ../parts/tools/wire_strippers.md "{cat:tool}"
[precision wire cutters]: ../parts/tools/precision-wire-cutters.md "{cat:tool}"
[heatgun]: ../parts/tools/heatgun.md "{cat:tool, note: 'If a heatgun is not available, the soldering iron can be used.'}"

# Solder the LED

>i If you have purchased a kit you may already have an assembled soldered LED cable

{{BOM}}

## Solder the resistor to the LED {pagestep}

* Turn on your [soldering iron]{qty:1} so it can heat up
* Take the [LED][Warm white 5mm LED]{qty:1, cat:electronic}
* Cut the longest leg down to about 5mm long using [precision wire cutters]{qty:1}
* Tin this leg with [solder]{qty: a little, cat:consumable}
* Take a [150 Ohm Resistor]{qty:1, note:"The exact value will depend on the current rating of your LED.", cat:electronic} and cut each leg down to about 5mm long. [i](../info_pages/why_led_resistor.md)
* Tin both legs with [solder]
* Solder one side of the resistor to the cut leg of the LED.
* Cut the other leg of the LED to be the same height as the end of the resistor.
* Tin the end of this leg

## Solder cables {pagestep}

* Take the [red][Red pre-crimped Female-Female jumper cable (30 cm)]{qty:1, cat:electronic} and [black][Black pre-crimped Female-Female jumper cable (30 cm)]{qty:1, cat:electronic} precrimped jumper cables and cut off one end with [precision wire cutters]{qty:1}
* Strip about 5mm of cable on each, and tin the cable with [wire strippers]{qty:1, cat:tool}
* Solder the red wire to the leg with the resistor
* Solder the black wire to the other leg
* Take the [red heatshrink][Red heatshrink - 2.4mm ID]{qty:35mm, cat:electronic} and slide it over the red cable up to the LED.
* Use a [heatgun]{qty:1} to shrink the heatshrink
* Take the [black heatshrink][Black heatshrink - 4.8mm ID]{qty:40mm, cat:electronic} and slide it over both cables up to the LED.
* Use a [heatgun]{qty:1} to shrink the heatshrink

## Add the connector {pagestep}

* Take the [DuPont housing][2 pin Du Pont connector female housing]{qty:1, cat:electronic}
* Push both connectors from the LED cable into the connector

[LED assembly]{output, qty:1, hidden}