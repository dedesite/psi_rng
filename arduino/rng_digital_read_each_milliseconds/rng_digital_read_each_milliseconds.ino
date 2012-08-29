#define INTERVALE_US 1000 //Intervale in micro seconds

int pin = 0;
unsigned long last_time;


void setup() {
  Serial.begin(19200);
  pinMode(pin, INPUT);
  last_time = micros();
}

void loop() {
  //On sample toutes les milliseconds la valeur digital et c'est ça qui nous donnera un 0 ou un 1
  //Car la fréquence du signal est aléatoire
  unsigned long time = micros();
  unsigned long diff = time - last_time;
  //On gère aussi le fait que micros overflow toutes les 70 minutes
  if(diff >= INTERVALE_US || diff < 0){
    //On note la valeur booléenne courante
    build_byte(digitalRead(pin));
    last_time = time;
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
