dueboot
=======

Based on https://github.com/neykov/armboot, and is a template for Arduino Due projects

Compiling
---------

Modify the Makefile/flash.rb with your paths and ports, and then "make burn" to upload to the Arduino.


Structure
---------

    main.rs - sample program (blinks the led of the Arduino board)
    hardware/ - from a random Arduino IDE for OS X
    zero/ - zero.rs and additional C stubs


Credits
-------

  - armboot: https://github.com/neykov/armboot
  - zero.rs: https://github.com/pcwalton/zero.rs
