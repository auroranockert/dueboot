#[allow(ctypes)];
#[no_std];
#[no_core];

#[link(name = "blinky", vers = "0.1", author = "Jens Nockert")];

use arduino::*;

mod arduino;

static LED:u32  = 13;

#[no_mangle]
#[fixed_stack_segment]
pub extern "C" fn main() {
    unsafe {
        init();
        delay(1);
        pinMode(LED, OUTPUT);
        digitalWrite(LED, LOW);

        loop {
            digitalWrite(LED, HIGH);   // turn the LED on (HIGH is the voltage level)
            delay(1000);
            digitalWrite(LED, LOW);    // turn the LED off by making the voltage LOW
            delay(100);
        }
    }
}
