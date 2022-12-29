#include "HX711.h"

HX711 scale;

void setup() {
  Serial.begin(9600);
  Serial.println("Initializing the scale");
  scale.begin(A1, A0);
}

void loop() {
  Serial.println(scale.get_units(), 1);
  delay(1000);
}