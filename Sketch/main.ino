#include <EEPROM.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <string.h>
#include "ELEMYO.h"

#define   CSpin         19
#define   sensorInPin   38
#define   jumperPin     39
#define   timePeriod    0.3     // frequency of signal update (time in ms) - Не используется

ELEMYO MyoSensor(CSpin);
WiFiClient net;

TaskHandle_t Task1;

volatile int signalValue = 0;
long loopTime = 0, sendTime = 0;

String str;
String comCmd;

String arg1, arg2;
String devId = "";
String serverName = "https://aing.ru/luna/api/add.php";
String sessionID;

hw_timer_t * timer = NULL;

portMUX_TYPE timerMux = portMUX_INITIALIZER_UNLOCKED;

volatile uint32_t isrCounter = 0;
volatile uint32_t lastIsrAt = 0;
volatile int mas[50];
volatile int currentPos = 0;
volatile bool readyToSend = false;

int filterType = 0;
int filterPar1 = 0;
int filterPar2 = 0;
int filterPar3 = 0;


String readParam(String param);
void writeParam(String arg1, String arg2);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

void IRAM_ATTR onTimer() {

  String st = "";

  portENTER_CRITICAL_ISR(&timerMux);

  isrCounter++;
  lastIsrAt = millis();

  if (currentPos == 49) {

    for (int i = 0; i < 50; i++) {
      st += String(mas[i]);
      if (i != 49) {
        st +=  ";";
      }
    }

    Serial.print(st);
    Serial.print(" onTimer no. ");
    Serial.print(isrCounter);
    Serial.print(" at ");
    Serial.print(lastIsrAt);
    Serial.println(" ms");

    currentPos = 0;
    readyToSend = true;

  } else {
    mas[currentPos] = signalValue;
    currentPos++;
  }

  portEXIT_CRITICAL_ISR(&timerMux);

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

void getSession() {

  String st = "";

  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient http;


    String serverPath = serverName + "?id=" + devId + "&session";

    Serial.println(serverPath);

    http.begin(serverPath.c_str());


    int httpResponseCode = http.GET();

    if (httpResponseCode > 0) {

      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
      String payload = http.getString();
      Serial.println(payload);
      sessionID = payload;
    }
    else {

      Serial.print("Error code: ");
      Serial.println(httpResponseCode);

    }

    http.end();
  }

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

void connect() {
  int i;
  arg1 = readParam("ssid");
  arg2 = readParam("pswd");

  arg1.trim();
  arg2.trim();

  Serial.println("Params {" + arg1 + "," + arg2 + "}");

  arg1 = "TP-LINK_29DAFC";
  arg2 = "44459055";

  WiFi.begin(arg1.c_str(), arg2.c_str());

  //Serial.print("Connecting WiFi ");
  i = 0;
  while ((WiFi.status() != WL_CONNECTED) && (i < 10)) {
    //Serial.print(".");
    delay(1000);
    i++;
  }

  getSession();


}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup() {


  Serial.begin(9600);
  delay(500);
  EEPROM.begin(512);

  MyoSensor.gain(1);

  pinMode(sensorInPin, INPUT);


  devId = readParam("dvid");
  devId.trim();

  filterType  = readParam("fltr").toInt();
  filterPar1  = readParam("prm1").toInt();
  filterPar2  = readParam("prm2").toInt();
  filterPar3  = readParam("prm3").toInt();

  xTaskCreatePinnedToCore(
    Task1code,
    "Task1",
    10000,
    NULL,
    1,
    &Task1,
    1);

  delay(500);

  timer = timerBegin(0, 80, true);
  timerAttachInterrupt(timer, &onTimer, true);
  timerAlarmWrite(timer, 100000, true);  // 1  00 000 - микросекунды, период
  timerAlarmEnable(timer);
}

void loop() {


  portENTER_CRITICAL(&timerMux);

  signalValue = analogRead(sensorInPin);
  int newSignal;
  
  if (filterType == 1) {
    newSignal = MyoSensor.BandStop(signalValue, filterPar1, filterPar2);
    signalValue =  newSignal;
  }
  if (filterType == 2) {
    newSignal = MyoSensor.LowPass(signalValue, filterPar1, filterPar2);
    signalValue =  newSignal;
  }
  if (filterType == 3) {
    newSignal = MyoSensor.BandPass(signalValue, filterPar1, filterPar2, filterPar3);
    signalValue =  newSignal;
  }

  //Serial.println(signalValue);
  /*
    if ((micros() - sendTime > 10000) && (micros() < 100000)) {
    sendTime = micros();
    Serial.print("T");
    Serial.println(sendTime - loopTime);
    }
    loopTime = micros();
  */
  portEXIT_CRITICAL(&timerMux);



  if (Serial.available()) {

    comCmd = Serial.readString();
    Serial.println(comCmd);
    if (comCmd.startsWith("reconnect")) {
      connect();
    }

    if (comCmd.startsWith("ssid=")) {
      arg1 = "ssid";
      arg2 = comCmd.substring(5);
      writeParam(arg1, arg2);
      comCmd = "";
    }

    if (comCmd.startsWith("pswd=")) {
      arg1 = "pswd";
      arg2 = comCmd.substring(5);
      writeParam(arg1, arg2);
      comCmd = "";
    }

    if (comCmd.startsWith("dvid=")) {
      arg1 = "dvid";
      arg2 = comCmd.substring(5);
      writeParam(arg1, arg2);
      comCmd = "";
    }


    if (comCmd.startsWith("fltr=")) {
      arg1 = "fltr";
      arg2 = comCmd.substring(5);
      writeParam(arg1, arg2);
      comCmd = "";
    }

    if (comCmd.startsWith("prm1=")) {
      arg1 = "prm1";
      arg2 = comCmd.substring(5);
      writeParam(arg1, arg2);
      comCmd = "";
    }

    if (comCmd.startsWith("prm2=")) {
      arg1 = "prm2";
      arg2 = comCmd.substring(5);
      writeParam(arg1, arg2);
      comCmd = "";
    }


    if (comCmd.startsWith("prm3=")) {
      arg1 = "prm3";
      arg2 = comCmd.substring(5);
      writeParam(arg1, arg2);
      comCmd = "";
    }

    if (comCmd.startsWith("getinfo")) {

      str = readParam("ssid");
      str.trim();
      Serial.print("[ssid]=");
      Serial.println(str);


      str = readParam("pswd");
      str.trim();
      Serial.print("[pswd]=");
      Serial.println(str);

      str = readParam("dvid");
      str.trim();
      Serial.print("[dvid]=");
      Serial.println(str);


      str = readParam("fltr");
      str.trim();
      Serial.print("[fltr]=");
      Serial.println(str);

      str = readParam("prm1");
      str.trim();
      Serial.print("[prm1]=");
      Serial.println(str);

      str = readParam("prm2");
      str.trim();
      Serial.print("[prm2]=");
      Serial.println(str);

      str = readParam("prm3");
      str.trim();
      Serial.print("[prm3]=");
      Serial.println(str);

      comCmd = "";
    }

  } else {
    comCmd = "";
  }


  //delayMicroseconds(50);   // wait before the next loop
}

////////////////////////////////////////////////////////////////
//
// Функция Task1code: Ядро 0.
//
////////////////////////////////////////////////////////////////

void Task1code( void * pvParameters ) {

  String st = "";

  while (true) {

    if (WiFi.status() != WL_CONNECTED) {
      connect();
    }


    if (readyToSend) {

      readyToSend = false;
      if (WiFi.status() == WL_CONNECTED) {

        HTTPClient http;
        st = "";

        for (int i = 0; i < 50; i++) {
          st += String(mas[i]);
          if (i != 49) {
            st +=  ";";
          }
        }

        String serverPath = serverName + "?add&sessionID=" + sessionID + "&id=" + devId + "&data=" + st + "&time=" + String(micros());

        Serial.println(serverPath);


        http.begin(serverPath.c_str());


        int httpResponseCode = http.GET();

        if (httpResponseCode > 0) {

          Serial.print("HTTP Response code: ");
          Serial.println(httpResponseCode);
          String payload = http.getString();
          Serial.println(payload);

        }
        else {

          Serial.print("Error code: ");
          Serial.println(httpResponseCode);

        }

        http.end();
      }
    }
  }
}



////////////////////////////////////////////////////////////////
//
// Функции сохранения и чтения параметров
//
////////////////////////////////////////////////////////////////

void writeParam(String arg1, String arg2) {

  int startfrom = 0;
  char chh[32];

  Serial.println("Writing " + arg1 + " = " + arg2);

  if (arg1.startsWith("ssid")) {
    startfrom = 0;
    arg2.toCharArray(chh, 30);
    EEPROM.put(startfrom, chh);
  }

  if (arg1.startsWith("pswd")) {
    startfrom = 32;
    arg2.toCharArray(chh, 30);
    EEPROM.put(startfrom, chh);
  }

  if (arg1.startsWith("dvid")) {
    startfrom = 64;
    arg2.toCharArray(chh, 30);
    EEPROM.put(startfrom, chh);
  }

  if (arg1.startsWith("fltr")) {
    startfrom = 100;
    arg2.toInt();
    EEPROM.put(startfrom, arg2.toInt());
  }
  if (arg1.startsWith("prm1")) {
    startfrom = 105;
    arg2.toInt();
    EEPROM.put(startfrom, arg2.toInt());
  }
  if (arg1.startsWith("prm2")) {
    startfrom = 110;
    arg2.toInt();
    EEPROM.put(startfrom, arg2.toInt());
  }
  if (arg1.startsWith("prm3")) {
    startfrom = 115;
    arg2.toInt();
    EEPROM.put(startfrom, arg2.toInt());
  }

  EEPROM.commit();
}
///////////////////////////////////////////////////////////////////////////

String readParam(String param) {

  int startfrom = 0;
  char chh[32];
  int val;

  if (param.startsWith("ssid")) {
    startfrom = 0;
    return (String(EEPROM.get(startfrom, chh)));
  }

  if (param.startsWith("pswd")) {
    startfrom = 32;
    return (String(EEPROM.get(startfrom, chh)));
  }

  if (param.startsWith("dvid")) {
    startfrom = 64;
    return (String(EEPROM.get(startfrom, chh)));
  }

  if (param.startsWith("fltr")) {
    startfrom = 100;
    EEPROM.get(startfrom, val);
    return (String(val));
  }

  if (param.startsWith("prm1")) {
    startfrom = 105;
    EEPROM.get(startfrom, val);
    return (String(val));
  }
  if (param.startsWith("prm2")) {
    startfrom = 110;
    EEPROM.get(startfrom, val);
    return (String(val));
  }

  if (param.startsWith("prm3")) {
    startfrom = 115;
    EEPROM.get(startfrom, val);
    return (String(val));
  }






}
