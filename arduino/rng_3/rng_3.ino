volatile int state = LOW;
volatile boolean send_byte = false;

void setup() {
  Serial.begin(19200);
  attachInterrupt(0, random_change, LOW);
}

void loop() {
  /*if(state == LOW){
    Serial.println("low");
  }
  else{
    Serial.println("high");
  }*/
  
  
  if(send_byte){
    Serial.write(out);
    out = 0;
    send_byte = false;
  }
}

void build_byte(boolean input){
  static int byte_counter = 0;
  static byte out = 0;

  if (input == 1){
    out = (out << 1) | 0x01;
  }
  else{
    out = (out << 1); 
  }
  byte_counter++;
  byte_counter %= 8;
  //We can write to serial in an interruption
  send_byte = byte_counter == 0;
}

void random_change() {
  state = !state;
}
