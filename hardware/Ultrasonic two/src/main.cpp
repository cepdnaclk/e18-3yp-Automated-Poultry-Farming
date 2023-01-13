#include <Arduino.h>

#define TRIGGER_PIN_1 12
#define ECHO_PIN_1 13
#define TRIGGER_PIN_2 14
#define ECHO_PIN_2 27

void setup() {
  Serial.begin(115200);
  pinMode(TRIGGER_PIN_1, OUTPUT);
  pinMode(ECHO_PIN_1, INPUT);
  pinMode(TRIGGER_PIN_2, OUTPUT);
  pinMode(ECHO_PIN_2, INPUT);
}

void loop() {
  long duration1, distance1;
  long duration2, distance2;

  digitalWrite(TRIGGER_PIN_1, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIGGER_PIN_1, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN_1, LOW);
  duration1 = pulseIn(ECHO_PIN_1, HIGH);
  distance1 = (duration1 / 2) / 29.1;

  digitalWrite(TRIGGER_PIN_2, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIGGER_PIN_2, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN_2, LOW);
  duration2 = pulseIn(ECHO_PIN_2, HIGH);
  distance2 = (duration2 / 2) / 29.1;

  Serial.print("Distance 1: ");
  Serial.print(distance1);
  Serial.print(" cm  Distance 2: ");
  Serial.print(distance2);
  Serial.println(" cm");

  delay(100);
}