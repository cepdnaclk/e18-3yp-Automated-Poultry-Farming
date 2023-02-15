#include <Arduino.h>
#include "HX711.h"
#include "soc/rtc.h"
#include <Servo.h>
#include <TimeLib32.h>
#include <WiFi.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <FirebaseESP32.h>

//Provide the token generation process info.
#include <addons/TokenHelper.h>
//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

#define WATER_LEVEL_SENSOR 36
#define SOLENOID_VALVE 21

#define TRIGGER_PIN_1 13
#define ECHO_PIN_1 12
#define TRIGGER_PIN_2 27
#define ECHO_PIN_2 14

#define WIFI_SSID "*********"
#define WIFI_PASSWORD "***********"



const char* ssid = "****************";
const char* password = "**************";

//#define WIFI_SSID "OPPO A5s"
//#define WIFI_PASSWORD "aaaaaaaa"



#define API_KEY "*********************"
/* 3. Define the RTDB URL */
#define DATABASE_URL "**********************" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

//Define Firebase Data object
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

int Curr_FeedLevel=0;
int Curr_WaterLevel=0;
int Eve_FeedAmnt=0;
int Mor_FeedAmnt=0;
int Nit_FeedAmnt=0;
int Mor_HH=0;
int Mor_MM=0;
int Eve_HH=0;
int Eve_MM=0;
int Nit_HH=0;
int Nit_MM=0;
String LDate;

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);

const int LOADCELL_DOUT_PIN = 16;
const int LOADCELL_SCK_PIN = 4;
const int LOADCELL_DOUT_PIN_2 = 18;
const int LOADCELL_SCK_PIN_2 = 5;
const int SERVO_PIN = 33;
const int SERVO_PIN_2 = 32;

const int THRESHOLD = 60;
const int SERVO_OPEN_ANGLE = 90;
const int SERVO_CLOSE_ANGLE = 0;
const int SERVO_OPEN_ANGLE2 = 0;
const int SERVO_CLOSE_ANGLE2 = 90;

const int OPEN_HOUR1 = 22;
const int OPEN_MINUTE1 = 44;
const int OPEN_SECOND1 = 0;

const int OPEN_HOUR2 = 22;
const int OPEN_MINUTE2 = 37;
const int OPEN_SECOND2 = 0;

const int OPEN_HOUR3 = 22;
const int OPEN_MINUTE3 = 42;
const int OPEN_SECOND3 = 0;

HX711 scale;
HX711 scale2;
Servo servo;
Servo servo2;

void setup() {
  Serial.begin(115200);
  pinMode(SOLENOID_VALVE, OUTPUT);

  //ultrasonic pin configuration
  pinMode(TRIGGER_PIN_1, OUTPUT);
  pinMode(ECHO_PIN_1, INPUT);
  pinMode(TRIGGER_PIN_2, OUTPUT);
  pinMode(ECHO_PIN_2, INPUT);
  rtc_clk_apb_freq_update(RTC_CPU_FREQ_80M);
  Serial.println("HX711 Demo");

  Serial.println("Initializing the scale");

  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(941.0666);
  scale.tare();

  scale2.begin(LOADCELL_DOUT_PIN_2, LOADCELL_SCK_PIN_2);
  scale2.set_scale(-491.62);
  scale2.tare();
//941.0666
  servo.attach(SERVO_PIN);
  servo.write(SERVO_CLOSE_ANGLE);

  servo2.attach(SERVO_PIN_2);
  servo2.write(SERVO_CLOSE_ANGLE2);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  
  timeClient.begin();
  timeClient.setTimeOffset(19800);

  /* Assign the api key (required) */
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  Firebase.begin(DATABASE_URL, API_KEY);
  Firebase.setDoubleDigits(5);
}

void loop() {
  timeClient.update();
  int waterLevel = analogRead(WATER_LEVEL_SENSOR);
  Serial.print("Water Level: ");
  Serial.println(waterLevel);

  timeClient.update();
  if (waterLevel < 500) {
    digitalWrite(SOLENOID_VALVE, HIGH);
    Serial.println("Valve opened");
  } else {
    digitalWrite(SOLENOID_VALVE, LOW);
    Serial.println("Valve closed");
  }
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
  
  timeClient.update();
   /////////////////////////////////////////////////
   if (Firebase.ready()) 
  {
    
    
    Firebase.setInt(fbdo,"/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Current Feed Level", distance1);
    

    Firebase.setInt(fbdo,"/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Current Water Level", distance2);
    
     
    /*
     if (Firebase.getInt(fbdo, "/test/a"))
        {
            int value = fbdo.to<int>();
            Serial.println(value);
        }
        else
        {
            Serial.println(fbdo.errorReason());
        }
    
    if (Firebase.get(fbdo, "/Flock/RFJEi9zOSxLeSpJyor3q/Evening Feed Amount"))
        {
            String value = fbdo.to<String>();
            Serial.println(value);
        }
        else
        {
            Serial.println(fbdo.errorReason());
        }
        */
       
       //User id = uAaYpJao1YdXAI3JNLDR28dU8132
       //flock id = cCO2s70Jd9cBfSinSdDd
      
    
    //    if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Evening Feed Amount"))
    //     {
    //         Eve_FeedAmnt = fbdo.to<int>();
    //         Serial.println("Evening Feed Amount");
    //         Serial.println(Eve_FeedAmnt);
    //     }
    //     else {
    //   Serial.println(fbdo.errorReason());
    // }
    //     if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Morning Feed Amount"))
    //     {
    //         Mor_FeedAmnt = fbdo.to<int>();
    //         Serial.println("Morning Feed Amount");
    //         Serial.println(Mor_FeedAmnt);
    //     }
    //      else {
    //   Serial.println(fbdo.errorReason());
    // }
    //     if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Night Feed Amount"))
    //     {
    //         Nit_FeedAmnt = fbdo.to<int>();
    //         Serial.println("Night Feed ");
    //         Serial.println(Nit_FeedAmnt);
    //     }
    //      else {
    //   Serial.println(fbdo.errorReason());
    // }
      
        
        if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Morning Feed Time MM"))
        {
            Eve_MM = fbdo.to<int>();
            Serial.println("Evening time minutes");
            Serial.println(Eve_MM);
        }
         else {
      Serial.println(fbdo.errorReason());
    }
      
       
        if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Evening Feed Time MM"))
        {
            Eve_MM = fbdo.to<int>();
            Serial.println("Evening time minutes");
            Serial.println(Eve_MM);
        }
         else {
      Serial.println(fbdo.errorReason());
    }
        
        
        if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Night Feed Time MM"))
        {
            Nit_MM = fbdo.to<int>();
            Serial.println("Night time minutes");
            Serial.println(Nit_MM);
        }
         else {
      Serial.println(fbdo.errorReason());
    }
        
        if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Last Modified Date"))
        {
            LDate = fbdo.to<String>();
            Serial.println("Last Update Date");
            Serial.println(LDate);
        }
         else {
      Serial.println(fbdo.errorReason());
    }

    if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Morning Time"))
        {
            Mor_HH = fbdo.to<int>();
            Serial.println("Morning time hours");
            Serial.println(Mor_HH);
        }
         else {
      Serial.println(fbdo.errorReason());
    }

     if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Evening Time"))
        {
            Eve_HH = fbdo.to<int>();
            Serial.println("Evening time hours");
            Serial.println(Eve_HH);
        }
         else {
      Serial.println(fbdo.errorReason());
    }



    if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Night Time"))
        {
            Nit_HH = fbdo.to<int>();
            Serial.println("Night time hours");
            Serial.println(Nit_HH);
        }
        else {
      Serial.println(fbdo.errorReason());
    }
      

    
  }
   ////////////////////////////////////////////////



   


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
  Serial.println(scale.get_units());
  Serial.println(scale2.get_units());
  // open the servo at specific times
  if (current_hour == Mor_HH && current_minute == Mor_MM) {
    if(scale.get_units()<THRESHOLD){
        servo.write(SERVO_OPEN_ANGLE);
        Serial.println("Servo opened at time 1");
    }
    if(scale2.get_units()<THRESHOLD){
      servo2.write(SERVO_OPEN_ANGLE2);
      Serial2.println("Servo opened at time 1");
    }
    
  }
  
  if (current_hour == Eve_HH && current_minute == Eve_MM) {
    if(scale.get_units()<THRESHOLD){
        servo.write(SERVO_OPEN_ANGLE);
        Serial.println("Servo opened at time 2");
    }
    if(scale2.get_units()<THRESHOLD){
      servo2.write(SERVO_OPEN_ANGLE2);
      Serial2.println("Servo opened at time 2");
    }
  }
  
  if (current_hour == Nit_HH && current_minute == Nit_MM ) {
    if(scale.get_units()<THRESHOLD){
        servo.write(SERVO_OPEN_ANGLE);
        Serial.println("Servo1 opened at time 3");
    }
    if(scale2.get_units()<THRESHOLD){
      servo2.write(SERVO_OPEN_ANGLE2);
      Serial2.println("Servo2 opened at time 3");
    }
  }

  // close the servo when the load cell reading is above the threshold
  if (scale.get_units() > THRESHOLD) {
    servo.write(SERVO_CLOSE_ANGLE);
    Serial.println("Servo1 closed");
  }
   if(scale2.get_units() > THRESHOLD) {
    servo2.write(SERVO_CLOSE_ANGLE2);
    Serial.println("Servo2 closed");
  }
  delay(1000);
}

