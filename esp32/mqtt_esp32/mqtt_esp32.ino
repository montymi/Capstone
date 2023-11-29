#include <WiFi.h>
#include <PubSubClient.h>

// WiFi
const char *ssid = "iPhone de Miguel (2)";
const char *password = "agent002";

// MQTT Broker
const char *mqtt_broker = "3.85.78.31";
const char *topic = "esp32/station/1/state";
const char *mqtt_username = "capstone";
const char *mqtt_password = "9973";
const int mqtt_port = 1883;

// the number of the LED pin
const int ledPin0 = 0;  // Switch 1 of Leg A
const int ledPin4 = 4;  // Switch 2 of Leg A
const int ledPin16 = 16;  // Switch 1 of Leg B
const int ledPin17 = 17;  // Switch 2 of Leg B

// setting PWM properties
const double freqCar = 44000; //PWM frequency (MATCHES SINE WAVE)
const double freqMod = 60;  //Modulation signal frequency
const int ledChannel_A = 0;
const int ledChannel_B = 1;
// const int ledChannel_B1 = 2;
// const int ledChannel_B2 = 3;
const int resolution = 8;
const int sample = freqCar/freqMod;
int duty;
int loop_counter = 0;
bool charge_state = 1;
float avg_peak = 0;

WiFiClient espClient;
PubSubClient client(espClient);

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

  // PWM
  /// configure LED PWM functionalitites
  ledcSetup(ledChannel_A, freqCar, resolution);
  ledcSetup(ledChannel_B, freqCar, resolution);
  // ledcSetup(ledChannel_A, freqCar, resolution);
  // ledcSetup(ledChannel_B, freqCar, resolution);
  /// attach the channel to the GPIO to be controlled
  ledcAttachPin(ledPin0, ledChannel_A);
  ledcAttachPin(ledPin4, ledChannel_B);
  ledcAttachPin(ledPin16, ledChannel_B);
  ledcAttachPin(ledPin17, ledChannel_A);
  // END PWM

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

void callback(char *topic, byte *payload, unsigned int length) {
    char message[length + 1];  // +1 for null terminator

    // Serial.print("Message arrived in topic: ");
    // Serial.println(topic);
    // Serial.print("Message:");
    for (int i = 0; i < length; i++) {
        message[i] = (char)payload[i];
    }
    message[length] = '\0';  // Null-terminate the string
    if (String(message) == "off") { Serial.println("\n-----------------------"); Serial.println("Received message: " + String(message)); charge_state = 0; }
    if (String(message) == "on") { Serial.println("\n-----------------------"); Serial.println("Received message: " + String(message)); charge_state = 1; }
}

void loop() {
  while (WiFi.status() != WL_CONNECTED) {
    WiFi.disconnect();
    WiFi.reconnect();
  }

  if (client.connected() && charge_state == 1) {
    // PWM
    for (int i= 0; i <= sample; i++){
      double sinVal = abs(255 * sin(2 * 3.141592356 * freqMod * (i / freqCar)));
      if (i == (sample/2)){ //zero crossing
        GPIO.func_out_sel_cfg[0].inv_sel = 0;
        GPIO.func_out_sel_cfg[17].inv_sel = 0;
        GPIO.func_out_sel_cfg[4].inv_sel = 0;
        GPIO.func_out_sel_cfg[16].inv_sel = 0;
        duty = 0;
        ledcWrite(ledChannel_A, duty);
        ledcWrite(ledChannel_B, duty);
      } if (sinVal > 0){
        GPIO.func_out_sel_cfg[4].inv_sel = 1;
        GPIO.func_out_sel_cfg[16].inv_sel = 1;
        GPIO.func_out_sel_cfg[0].inv_sel = 0;
        GPIO.func_out_sel_cfg[17].inv_sel = 0;
        duty = sinVal;
        ledcWrite(ledChannel_A, duty);
        ledcWrite(ledChannel_B, duty);
      } if (sinVal < 0){
        GPIO.func_out_sel_cfg[0].inv_sel = 1;
        GPIO.func_out_sel_cfg[17].inv_sel = 1;
        GPIO.func_out_sel_cfg[4].inv_sel = 0;
        GPIO.func_out_sel_cfg[16].inv_sel = 0;
        duty = sinVal;
        ledcWrite(ledChannel_A, duty);
        ledcWrite(ledChannel_B, duty);
      } if (loop_counter % 100 == 0 && i == sample / 4) {
        int lightLevel = analogRead(33);  // WILL BE A6 (34) and A7 (35)
        float voltage = lightLevel * (3.3 / 4096.0) + 0.2; // offset of 0.2
        printf("> Peak:\t%f\n", voltage);
        avg_peak = (avg_peak + voltage) / 2;
        printf("> Avg:\t%f\n", avg_peak);
        String stringMessage = String(avg_peak);
        const char *message = stringMessage.c_str();
        client.publish(topic, message);
      }
    }
    // END PWM
  }
  client.loop();
  loop_counter += 1;
}
