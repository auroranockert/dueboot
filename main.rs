#[allow(ctypes)];
#[no_std];
#[no_core];

#[link(name = "blinky", vers = "0.1", author = "Jens Nockert")];

use zero::std_types::*;

mod zero {
  pub mod std_types;
  pub mod zero;
}

static OUTPUT:u8 = 0x01;

static LOW:u8  = 0x00;
static HIGH:u8 = 0x01;

static LED:u8  = 13;

extern {
    fn pinMode(pin:u8, mode:u8);
    fn delay(ms:u32);
    fn digitalWrite(pin:u8, value:u8);
}

#[no_mangle]
#[export_name="setup"]
#[fixed_stack_segment]
pub extern "C" fn core_setup() {
    unsafe {
        pinMode(LED, OUTPUT);
        digitalWrite(LED, LOW);    // turn the LED off by making the voltage LOW
    }
}

#[no_mangle]
#[export_name="loop"]
#[fixed_stack_segment]
pub extern "C" fn core_loop() {
    unsafe {
        digitalWrite(LED, HIGH);   // turn the LED on (HIGH is the voltage level)
        delay(1000);
        digitalWrite(LED, LOW);    // turn the LED off by making the voltage LOW
        delay(100);
    }
}