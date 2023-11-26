#include "SevSeg.h"
#include <WiFi.h>
#include <PubSubClient.h>
SevSeg sevseg; //Instantiate a seven segment object


// WiFi
const char *ssid = "iPhone";
const char *password = "01030200";

// MQTT Broker
const char *mqtt_broker = "3.85.78.31";
const char *topic = "esp32/test";
const char *mqtt_username = "capstone";
const char *mqtt_password = "9973";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

int tfa;
int refresh;

void setup() {
  // Serial baud to 115200;
  Serial.begin(115200);

  // Connecting WIFI
  WiFi.begin(ssid, password);
  Serial.print("\nConnecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
  }
  Serial.println("\nConnected to the WiFi network");

  // Configure Seven Segment Display
  byte numDigits = 2;
  byte digitPins[] = {17, 15};
  byte segmentPins[] = {4, 5, 18, 21, 19, 2, 16};  //A-4,B-5,C-18,D-21,E-9,F-2,G-16  (letter-pin)
  bool resistorsOnSegments = false; // 'false' means resistors are on digit pins
  byte hardwareConfig = COMMON_CATHODE; // See README.md for options
  bool updateWithDelays = false; // Default 'false' is Recommended
  bool leadingZeros = true; // Use 'true' if you'd like to keep the leading zeros
  bool disableDecPoint = false; // Use 'true' if your decimal point doesn't exist or isn't connected. Then, you only need to specify 7 segmentPins[]

  sevseg.begin(hardwareConfig, numDigits, digitPins, segmentPins, resistorsOnSegments,
  updateWithDelays, leadingZeros, disableDecPoint);

  // Connecting MQTT Broker
  client.setServer(mqtt_broker, mqtt_port);
  while (!client.connected()) {
    String client_id = "esp32-client-";
    client_id += String(WiFi.macAddress());
    Serial.printf("\n%s connecting to MQTT\n", client_id.c_str());
    client.setCallback(callback);

    // try { connect() } catch { errors }
    if (client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
      if (client.subscribe(topic, 1)) {
        Serial.println("Subscription successful");
      } else {
        Serial.println("Subscription failed");
      }
    } else {
      Serial.print("\nFAILED::state: ");
      Serial.println(client.state());
      switch (client.state()) {
        case -4:
          Serial.println("MQTT_CONNECTION_TIMEOUT");
          break;
        case -3:
          Serial.println("MQTT_CONNECTION_LOST");
          break;
        case -2:
          Serial.println("MQTT_CONNECT_FAILED");
          break;
        case -1:
          Serial.println("MQTT_DISCONNECTED");
          break;
        case 1:
          Serial.println("MQTT_CONNECT_BAD_PROTOCOL");
          break;
        case 2:
          Serial.println("MQTT_CONNECT_BAD_CLIENT_ID");
          break;
        case 3:
          Serial.println("MQTT_CONNECT_UNAVAILABLE");
          break;
        case 4:
          Serial.println("MQTT_CONNECT_BAD_CREDENTIALS");
          break;
        case 5:
          Serial.println("MQTT_CONNECT_UNAUTHORIZED");
          break;
        default:
          Serial.println("Unknown error");
          break;
      }
    }
  }
}

void setnum(int number){
  sevseg.setNumber(number);
}

void randomNumber(){
  tfa = random(0,99);
}

void callback(char *topic, byte *payload, unsigned int length) {
    char message[length + 1];  // +1 for null terminator

    // Serial.print("Message arrived in topic: ");
    // Serial.println(topic);
    // Serial.print("Message:");
    for (int i = 0; i < length; i++) {
        message[i] = (char)payload[i];
    }
    message[length] = '\0';  // Null-terminate the string
    if (String(message) == "refresh") { 
      Serial.println("\n-----------------------"); 
      Serial.println("Received message: " + String(message)); 
      refresh = 1;
      }
    if (String(message) == "clear") { 
      Serial.println("\n-----------------------"); 
      Serial.println("Received message: " + String(message));
      sevseg.blank();
      }
}

void loop() {
  sevseg.refreshDisplay();

  if (client.connected() && refresh == 1){
    randomNumber();
    String stringMessage = String(tfa);
    const char *message = stringMessage.c_str(); 
    client.publish(topic, message); 
    Serial.printf("tfa: %d\n", tfa);
    setnum(tfa);
    refresh = 0;
  }

  client.loop();
/*
  if(digitalRead(23) == HIGH){
    randomNumber();
    setnum(tfa);
  }
  if(digitalRead(22) == HIGH){
    sevseg.blank();
  }
  */

}
