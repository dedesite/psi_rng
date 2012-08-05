import processing.serial.*;

int nb_bytes = 0;
int nb_ones = 0;
static final int stats_intervale = 1000;
int lastStatsTime = 0;
float[] vals;
PFont f;
int min_val = 255;
int max_val = 0;


void setup() {
  size(400, 200);
  
  // Using the first available port (might be different on your computer)
  Serial port = new Serial(this, Serial.list()[0], 19200/*38400*/);
  //port.bufferUntil('\n');
  //port.buffer(4);
}

void draw() {
  background(255);
}

void displayStats(){
  int elapsedTime = millis();
  int delta = elapsedTime - lastStatsTime;

  if(delta >= stats_intervale){
    /*println("Nb 1 = " + nb_ones);
    println("Nb 0 = " + (nb_bytes - nb_ones));
    println("Random ratio = " + float(nb_ones)/float(nb_bytes));*/
    println("Debit = " + nb_bytes + " bytes/s");
    println("Min val = " + min_val);
    println("Max val = " + max_val);
    println("-------------------------------------------");
    lastStatsTime = elapsedTime;
    nb_bytes = 0;
    min_val = 0;
    max_val = 0;
  }
}

//Je ne sais pas si cette fonction est bien juste car elle était faite pour les char au début
//Mais on s'en fou, je récupère bien le bon nombre de bit et c'est l'essentiel pour l'instant
boolean bitAt(byte b, int pointer) {
   return ((b & (1 << pointer)) != 0);
}

// Called whenever there is something available to read
void serialEvent(Serial port) {
  //byte[] val = port.readBytes();
  int val = port.read();
  byte b = byte(val);
  
  print(val + " == ");
  for (int i = 0; i < 8; i = i+1) {
    boolean bit = bitAt(b, i);
    if(bit){
      print(1);
    }
    else{
      print(0);
    }
  }
  println(" en binaire");
  
  
  //String s = port.readStringUntil('\n');
  //println(s);
  nb_bytes++;
  /*String inString = port.readStringUntil('\n');
   if (inString != null) {
     // trim off any whitespace:
     inString = trim(inString);
     // convert to an int and map to the screen height:
     int inByte = int(inString);
     nb_bytes++;
     //println(inByte);
   }
   else{
     //println("OUPS!");
   }*/
  //println(val);
  //Comme on lit de l'ascii on reçoit 48 et 49
  /*boolean heads_or_tails = boolean(val);
  //println(heads_or_tails);
  nb_ones += int(heads_or_tails);*/
  //println(val);
  
  /*if(val > max_val){
    max_val = val;
  }
  else if(val < min_val){
    min_val = val;
  }*/
  
  displayStats();
}
