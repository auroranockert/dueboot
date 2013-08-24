dueboot
=======

Based on https://github.com/neykov/armboot, and is a template for Arduino Due projects

Requirements:

    arm-none-eabi toolchain
    llvm-3.4 toolchain
    rustc (tested with 0.7) with the patch at https://raw.github.com/neykov/armboot/master/rustc.patch applied (works even when compiled only for x86 target)


Compiling:

Modify the Makefile/flash.rb with your paths and ports, and then "make burn" to upload to the Arduino.


Structure

    main.rs - sample program (blinks the led of the Arduino board)
    hardware/ - from a random Arduino IDE for OS X
    zero/ - zero.rs and additional C stubs


Credits

    Rust zero.rs: https://github.com/pcwalton/zero.rs
