dueboot
=======

Based on https://github.com/neykov/armboot, and is a template for Arduino Due projects

Compiling
---------

Modify the Rakefile with your paths and ports, and then "rake burn" to upload to the Arduino.


Structure
---------

    core.rs - sample program (blinks the led of the Arduino board)
    arduino.rs - extern stubs for the core Arduino libraries
    hardware/ - from a random Arduino IDE for OS X


Credits
-------

  - armboot: https://github.com/neykov/armboot
  - zero.rs: https://github.com/pcwalton/zero.rs
