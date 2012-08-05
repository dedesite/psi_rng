int previous_state = 0;
int pin = 2;
boolean heads_or_talls = false;

void setup() {
  Serial.begin(115200);
  pinMode(pin, INPUT);
}

void loop() {
  //On change de valeur en permanence
  heads_or_talls = !heads_or_talls;
  int current_state = digitalRead(pin);
  //Et quand il y a un changement d'état (LOW ou HIGH)
  if(previous_state != current_state){
    //On note la valeur booléenne courante
    build_byte(heads_or_talls);
    previous_state = current_state;
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
  if(byte_counter == 0){
    Serial.write(out);
    out = 0;
  }
}
