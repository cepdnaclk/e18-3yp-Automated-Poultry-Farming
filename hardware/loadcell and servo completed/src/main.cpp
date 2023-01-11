#include <Arduino.h>
#include "HX711.h"
#include "soc/rtc.h"
#include <Servo.h>
#include <TimeLib32.h>
#include <WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>

const char* ssid = "OPPO A5s";
const char* password = "aaaaaaaa";

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);

const int LOADCELL_DOUT_PIN = 16;
const int LOADCELL_SCK_PIN = 4;
const int SERVO_PIN = 13;

const int THRESHOLD = 60;
const int SERVO_OPEN_ANGLE = 90;
const int SERVO_CLOSE_ANGLE = 0;

const int OPEN_HOUR1 = 6;
const int OPEN_MINUTE1 = 0;
const int OPEN_SECOND1 = 0;

const int OPEN_HOUR2 = 12;
const int OPEN_MINUTE2 = 0;
const int OPEN_SECOND2 = 0;

const int OPEN_HOUR3 = 22;
const int OPEN_MINUTE3 = 23;
const int OPEN_SECOND3 = 0;

HX711 scale;
Servo servo;

void setup() {
  Serial.begin(115200);
  rtc_clk_apb_freq_update(RTC_CPU_FREQ_80M);
  Serial.println("HX711 Demo");

  Serial.println("Initializing the scale");

  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(-491.62);
  scale.tare();
  
  servo.attach(SERVO_PIN);
  servo.write(SERVO_CLOSE_ANGLE);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  
  timeClient.begin();
  timeClient.setTimeOffset(19800);
}

void loop() {
  timeClient.update();
  int current_hour = timeClient.getHours();
  int current_minute = timeClient.getMinutes();
  int current_second = timeClient.getSeconds();
  Serial.print("Current Time: ");
  Serial.print(current_hour);
  Serial.print(":");
  Serial.print(current_minute);
  Serial.print(":");
  Serial.println(current_second);
  //Serial.println(second());
  // open the servo at specific times
  if (current_hour == OPEN_HOUR1 && current_minute == OPEN_MINUTE1 && current_second == OPEN_SECOND1) {
    servo.write(SERVO_OPEN_ANGLE);
    Serial.println("Servo opened at time 1");
  }
  
  if (current_hour == OPEN_HOUR2 && current_minute == OPEN_MINUTE2 && current_second == OPEN_SECOND2) {
    servo.write(SERVO_OPEN_ANGLE);
    Serial.println("Servo opened at time 2");
  }
  
  if (current_hour == OPEN_HOUR3 && current_minute == OPEN_MINUTE3 && current_second == OPEN_SECOND3) {
    servo.write(SERVO_OPEN_ANGLE);
    Serial.println("Servo opened at time 3");
  }

  // close the servo when the load cell reading is above the threshold
  if (scale.get_units() > THRESHOLD) {
    servo.write(SERVO_CLOSE_ANGLE);
    Serial.println("Servo closed");
  }
  delay(1000);
}