#if defined(ESP32)
#include <WiFi.h>
#include <FirebaseESP32.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#endif

//Provide the token generation process info.
#include <addons/TokenHelper.h>


// defines variables
long duration; // variable for the duration of sound wave travel
int distance; 
//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

/* 1. Define the WiFi credentials */
#define echoPin 5 // attach pin D2 Arduino to pin Echo of HC-SR04
#define trigPin 18 //attach pin D3 Arduino to pin Trig of HC-SR04
#define WIFI_SSID "*********"
#define WIFI_PASSWORD "*********"

//For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

/* 2. Define the API Key */
#define API_KEY "*********************************"

/* 3. Define the RTDB URL */
#define DATABASE_URL "**********************************" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app


//Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;






void setup()
{
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an OUTPUT
  pinMode(echoPin, INPUT);
  Serial.begin(115200);
  delay(2000);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  config.database_url = DATABASE_URL;



  //////////////////////////////////////////////////////////////////////////////////////////////
  //Please make sure the device free Heap is not lower than 80 k for ESP32 and 10 k for ESP8266,
  //otherwise the SSL connection will fail.
  //////////////////////////////////////////////////////////////////////////////////////////////

  Firebase.begin(DATABASE_URL, API_KEY);

  //Comment or pass false value when WiFi reconnection will control by your code or third party library
 // Firebase.reconnectWiFi(true);

  Firebase.setDoubleDigits(5);

}

void loop()
{
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin HIGH (ACTIVE) for 10 microseconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);
  Serial.println(duration);
  // Calculating the distance
  distance = duration * 0.034 / 2; 
  

    // y=random(10,19);
    
  if (Firebase.ready()) 
  {
    
    //Firebase.setInt(fbdo, main, 5);
    Firebase.setInt(fbdo, "/test/a", distance);
    //Firebase.setInt(fbdo, "/test/b", y);
    delay(200);

    // Serial.printf("Get int a--  %s\n", Firebase.getInt(fbdo, "/test/a") ? String(fbdo.to<int>()).c_str() : fbdo.errorReason().c_str());
    //  a=fbdo.to<int>();
    // Serial.printf("Get int b--  %s\n", Firebase.getInt(fbdo, "/test/b") ? String(fbdo.to<int>()).c_str() : fbdo.errorReason().c_str());
    //  b=fbdo.to<int>();
  }
    Serial.print("Distance: ");
    Serial.print(distance);
    Serial.println(" cm");
    delay(2500);
}
