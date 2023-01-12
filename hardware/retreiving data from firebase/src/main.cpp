#if defined(ESP32)
#include <WiFi.h>
#include <FirebaseESP32.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#endif

//Provide the token generation process info.
#include <addons/TokenHelper.h>



//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>


#define WIFI_SSID "Eng-Student"
#define WIFI_PASSWORD "3nG5tuDt"

//#define WIFI_SSID "OPPO A5s"
//#define WIFI_PASSWORD "aaaaaaaa"



#define API_KEY "AIzaSyDBNvWvJlpisHpQh5cP4nabQrQPB-U8K38"
/* 3. Define the RTDB URL */
#define DATABASE_URL "https://poultry-feed-3yp-default-rtdb.firebaseio.com/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app


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

void setup()
{
  
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
  Firebase.begin(DATABASE_URL, API_KEY);
  Firebase.setDoubleDigits(5);

}

void loop()
{
 
  if (Firebase.ready()) 
  {
    
    
    Firebase.setInt(fbdo,"/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Current Feed Level", 1.98);
    delay(200);

    Firebase.setInt(fbdo,"/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Current Water Level", 1.89);
    delay(200);
     
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

     delay(200);
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
       delay(200);
       //User id = uAaYpJao1YdXAI3JNLDR28dU8132
       //flock id = cCO2s70Jd9cBfSinSdDd
      
    
       if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Evening Feed Amount"))
        {
            Eve_FeedAmnt = fbdo.to<int>();
            Serial.println("Evening Feed Amount");
            Serial.println(Eve_FeedAmnt);
        }
        else {
      Serial.println(fbdo.errorReason());
    }
        if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Morning Feed Amount"))
        {
            Mor_FeedAmnt = fbdo.to<int>();
            Serial.println("Morning Feed Amount");
            Serial.println(Mor_FeedAmnt);
        }
         else {
      Serial.println(fbdo.errorReason());
    }
        if (Firebase.get(fbdo, "/uAaYpJao1YdXAI3JNLDR28dU8132/cCO2s70Jd9cBfSinSdDd/Night Feed Amount"))
        {
            Nit_FeedAmnt = fbdo.to<int>();
            Serial.println("Night Feed ");
            Serial.println(Nit_FeedAmnt);
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


}