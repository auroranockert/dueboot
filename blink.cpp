#include "Arduino.h"

void setup();
void loop();

int led = 13;

void setup() {                
    pinMode(led, OUTPUT);     
}

void loop() {
    digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(1000);               // wait for a second
    digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
    delay(100);                // wait for a second
}

