void setup() {
  // initialize the serial communication:
  Serial.begin(19200/*38400*/);
}

void loop() {
  // send the value of analog input 0:
  Serial.println(255);
  // wait a bit for the analog-to-digital converter
  // to stabilize after the last reading:
  //delay(2);
}
