// Learning Processing
// Daniel Shiffman
// http://www.learningprocessing.com

// Example 19-8: Reading from serial port

import processing.serial.*;

int lastStatsTime = 0;
int lastCalibrationTime = 0;
int nb_bytes = 0;
int nb_ones = 0;
int current_calibration_nb = 0;

//Au début on doit toujours se calibrer
boolean calibrating = true;
//Nb de chiffre sur lesquels on va sampler pout calculer la médiane
static final int calibration_size = 10000;
//Tableau contenant les chiffres qui vont servir au calcul de la mediane
int[] calibration_numbers = new int[calibration_size];
//Médiane : seuil au dessus duquel on a un 1
int median = 0;

//On recalibre toutes les 10 minutes
static final int calibration_intervale = 10*60*1000;
//Et on affiche les stats toutes les heures
static final int stats_intervale =  10000;

void setup() {
  size(200,200);
  
  // In case you want to see the list of available ports
  println("Start calibration");
  // Using the first available port (might be different on your computer)
  Serial port = new Serial(this, Serial.list()[0], /*115200*/19200);
}

void draw() {
  // The serial data is used to color the background.   
 //background(val); 
}

void displayStats(){
  int elapsedTime = millis();
  int delta = elapsedTime - lastStatsTime;
  int deltaCalib = elapsedTime - lastCalibrationTime;
  //A chaque interval on affiche le nombre de 1 et le rapport au nombre de chiffre total (doit normalement être de 0.5)
  if(delta >= stats_intervale){
    println("Nb 1 = " + nb_ones);
    println("Nb 0 = " + (nb_bytes - nb_ones));
    println("Random ratio = " + float(nb_ones)/float(nb_bytes));
    println("-------------------------------------------");
    lastStatsTime = elapsedTime;
  }
  if(deltaCalib >= calibration_intervale){
    calibrating = true;
  }
}

//Renvois la mediane d'un tableau d'entier
int calcul_median(int[] numbers){
  numbers = sort(numbers);
  int nb_num = numbers.length;
  if(nb_num > 1){
    //On calcul la médiane en prenant la moyenne du chiffre du milieu et de celui d'après
    int median_1 = numbers[nb_num / 2 - 1];
    int median_2 = numbers[(nb_num / 2)];
    int med = (median_1 + median_2) / 2;
    println("Min : " + numbers[0]);
    println("Max : " + numbers[nb_num - 1]);
    println("Median : " + med);
    println("-------------------------------------------");
    return med;
  }
  else{
    return numbers[0];
  }
}

boolean get_random_bool(int num){
  return num >= median;
}

// Called whenever there is something available to read
void serialEvent(Serial port) {
  // Data from the Serial port is read in serialEvent() using the read() function and assigned to the global variable: val
  // Je ne sais pas pourquoi mais il faut enlever 48
  int val = port.read();
  //Avant de pouvoir savoir si on a un 1 ou un 0, il faut calibrer la machine
  if(calibrating){     
    if(current_calibration_nb >= calibration_size - 1){
      //println("We've got enough numbers");
      median = calcul_median(calibration_numbers);
      //println("The median is : " + median);
      calibrating = false;
      current_calibration_nb = 0;  
    }
    else{
      calibration_numbers[current_calibration_nb] = val;
      current_calibration_nb++;
    }
  }
  else{
    boolean heads_or_tails = get_random_bool(val);
    nb_ones += int(heads_or_tails);
    nb_bytes++;
    displayStats();
  }
  // For debugging
  //println(val);
}
