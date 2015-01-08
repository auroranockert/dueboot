#![feature(asm)]
#![feature(lang_items)]

#![no_std]

use arduino::{init, delay, pinMode, digitalWrite, analogWrite, LOW, HIGH, OUTPUT};
mod arduino;

#[lang="sized"]
trait Sized {}

#[lang="copy"]
trait Copy {}

#[lang="sync"]
trait Sync {}

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
        delay(100);

        analogWrite(PWM, PWM_HIGH);
        digitalWrite(LED, HIGH);
        delay(1000);
        analogWrite(PWM, PWM_LOW);
        digitalWrite(LED, LOW);
        delay(1000);
  }
}
