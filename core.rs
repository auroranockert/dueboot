#![feature(asm)]
#![feature(lang_items)]
#![feature(no_std)]

#![no_std]

use arduino::{init, delay, pinMode, digitalWrite, analogWrite, LOW, HIGH, OUTPUT};
mod arduino;

trait MarkerTrait : PhantomFn<Self> { }
impl<T: ?Sized> MarkerTrait for T { }

#[lang = "phantom_fn"]
trait PhantomFn<A:?Sized,R:?Sized=()> { }

#[lang="sized"]
trait Sized : MarkerTrait {}

#[lang="copy"]
trait Copy : MarkerTrait {}

#[lang="sync"]
trait Sync : MarkerTrait {}

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
