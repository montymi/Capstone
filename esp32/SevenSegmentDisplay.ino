#include "SevSeg.h"
SevSeg sevseg; //Instantiate a seven segment object

int tfa;

void setup() {
  byte numDigits = 2;
  byte digitPins[] = {17, 15};
  byte segmentPins[] = {4, 5, 18, 21, 19, 16, 2};
  bool resistorsOnSegments = false; // 'false' means resistors are on digit pins
  byte hardwareConfig = COMMON_CATHODE; // See README.md for options
  bool updateWithDelays = false; // Default 'false' is Recommended
  bool leadingZeros = true; // Use 'true' if you'd like to keep the leading zeros
  bool disableDecPoint = false; // Use 'true' if your decimal point doesn't exist or isn't connected. Then, you only need to specify 7 segmentPins[]

  sevseg.begin(hardwareConfig, numDigits, digitPins, segmentPins, resistorsOnSegments,
  updateWithDelays, leadingZeros, disableDecPoint);

  Serial.begin(9600);

  pinMode(23, INPUT);
  pinMode(22, INPUT);
}

void loop() {
  sevseg.refreshDisplay();

  if(digitalRead(23) == HIGH){
    randomNumber();
    setnum(tfa);
  }
  if(digitalRead(22) == HIGH){
    sevseg.blank();
  }

}

void setnum(int number){
  sevseg.setNumber(number);
}

void randomNumber(){
  tfa = random(0,99);
}
