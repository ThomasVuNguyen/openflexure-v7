# Mount the motor boards and upload the firmware

{{BOM}}

## Mount the boards {pagestep}

Using the [nano converter plate](fromstep){qty:1} and [nano converter plate gripper](fromstep){qty:1} printed previously, mount the microcontroller and the three motor driver boards into the electronics drawer.

## Upload the firmware {pagestep}

Using the Arduno IDE load the [Sangaboard arduino sketch] onto the Arduino nano, in the same way as you would do for a Sangaboard v0.4.  If you have problems, check the troubleshooting hints below.

---

## Troubleshooting

* **Arduino IDE:** Some users have found issues with old (or very new) versions of the Arduino IDE not working properly.  See the [issue thread on motor boards not working] for more details.
* **Arduino Clones:** Many people use Nano boards not made by Arduino.  These often come with cheaper USB to serial ICs (which require drivers - see the Arduino section at the end of this page) and old bootloaders (which require different options in the Arduino IDE).  This is also discussed in the [issue thread on motor boards not working].

[issue thread on motor boards not working]: https://gitlab.com/openflexure/openflexure-helpdesk/-/issues/12#note_342049911
[Sangaboard arduino sketch]: https://gitlab.com/bath_open_instrumentation_group/sangaboard/tree/master/arduino_code