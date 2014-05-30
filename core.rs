#![feature(asm)]

#![allow(ctypes)]
#![no_std]

#![crate_id = "blinky#0.1"]

use arduino::{init, delay, pinMode, digitalWrite, analogWrite, LOW, HIGH, OUTPUT};

mod arduino;

static PWM:u32 = 2;
static LED:u32 = 13;

static PWM_LOW:u32 = 0;
static PWM_HIGH:u32 = 16;

#[no_mangle]
pub fn main() {
	init();
	delay(1);
	pinMode(LED, OUTPUT);
	digitalWrite(LED, LOW);
	analogWrite(PWM, PWM_LOW);

	loop {
		analogWrite(PWM, PWM_HIGH);
		digitalWrite(LED, HIGH);
		delay(100);
		analogWrite(PWM, PWM_LOW);
		digitalWrite(LED, LOW);
		delay(900);
	}
}
