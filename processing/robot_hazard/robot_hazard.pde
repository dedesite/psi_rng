import processing.serial.*;

class Tychoscope{
  final int NEW_MOVE = 0;
  final int ROTATING = 1;
  final int PAUSE_1 = 2;
  final int MOVING = 3;
  final int PAUSE_2 = 4;
  
  int pos_x;
  int pos_y;
  int previous_pos_x;
  int previous_pos_y;
  color col;
  float previous_angle;
  float current_angle;
  int speed;
  int pause_delay;
  int circle_size;
  int circle_radius;
  int state;
  int rotation_time;
  
  //Entre 0 et 360
  float random_angle;
  //Aiguille d'une montre ou sens inverse
  boolean random_rotate_sens;
  //Avant ou arriere
  boolean random_direction;
  //0 à 10cm
  int random_distance;
  
  int last_state_time;
  
  Tychoscope(){
    pos_x = width/2;
    pos_y = height/2;
    previous_pos_x = pos_x;
    previous_pos_y = pos_y;
    col = color(0, 255, 0);
    previous_angle = 0;
    current_angle = 0;
    speed = 1;
    pause_delay = 1000;
    circle_size = 40;
    circle_radius = circle_size / 2;
    rotation_time = 1000;
    
    state = NEW_MOVE;
  }
  
  void move(){
    int current_time = millis();
    int diff = current_time - last_state_time;
    switch(state){
      case NEW_MOVE:
        //TODO : avoir un petit temps d'attente entre chaque génération de nombre aléatoire
        //Pour avoir une base de chiffre assez importante
        //random_rotate_sens = random(0,1) > 0.5;
        random_rotate_sens = qrandom_boolean();
        //random_angle = random(0, 360);
        random_angle = qrandom_number(0, 360);
        if(!random_rotate_sens){
          random_angle = -random_angle;
        }
        //random_direction = random(0,1) > 0.5;
        random_direction = qrandom_boolean();
        //random_distance = int(random(20, 100));
        random_distance = qrandom_number(20, 100);
        
        println("New move!!");
        println("Angle : " + random_angle);
        println("Sens des aiguilles d'une montre ? " + random_rotate_sens);
        println("En avant ? " + random_direction);
        println("Distance : " + random_distance);
        println("Int = " + int(0.6));
        println("----------------------------------------------");
        
        last_state_time = millis();
        state = ROTATING;
        break;
      case ROTATING:
        if(diff <= rotation_time){
          float angle_percent = float(diff) / float(rotation_time);
          float angle_to_add = angle_percent * random_angle;
          current_angle = previous_angle + angle_to_add;
          
          if(current_angle > 360){
            current_angle = current_angle - 360;
          }
          else if(current_angle < 0){
            current_angle = 360 + current_angle;
          }
        }
        else{
          previous_angle = current_angle;
          last_state_time = millis();
          state = PAUSE_1;          
        }
        break;
      case PAUSE_1:
        if(diff >= pause_delay){
          last_state_time = millis();
          state = MOVING;
        }
        break;
      case MOVING:
        boolean next_state = false;
        if(diff <= rotation_time){
          float distance_percent = float(diff) / float(rotation_time);
          float distance_to_add = distance_percent * float(random_distance);
          if(random_direction){
            pos_x = previous_pos_x + int(distance_to_add * cos(radians(current_angle)));
            pos_y = previous_pos_y + int(distance_to_add * sin(radians(current_angle)));
          }
          else{
            pos_x = previous_pos_x - int(distance_to_add * cos(radians(current_angle)));
            pos_y = previous_pos_y - int(distance_to_add * sin(radians(current_angle)));
          }
          
          //Manage collisions
          if(pos_x < 0 + circle_radius){
            pos_x = 0 + circle_radius;
            next_state = true;
          }
          if(pos_x > width - circle_radius){
            pos_x = width - circle_radius;
            next_state = true;
          }
          if(pos_y < 0 + circle_radius){
            pos_y = 0 + circle_radius;
            next_state = true;
          }
          if(pos_y > height - circle_radius){
            pos_y = height - circle_radius;
            next_state = true;
          }
        }
        else{
          next_state = true;
        }
        if(next_state){
          previous_pos_x = pos_x;
          previous_pos_y = pos_y;
          last_state_time = millis();
          state = PAUSE_2;
        }
        break;
      case PAUSE_2:
        if(diff >= pause_delay){
          last_state_time = millis();
          state = NEW_MOVE;
        }
        break;
      default:
        break;
    }
  }
  
  void display(){
    move();
    
    fill(col);
    ellipse(pos_x, pos_y, circle_size, circle_size);

    float x1 = pos_x + circle_radius * cos(radians(current_angle));
    float y1 = pos_y + circle_radius * sin(radians(current_angle));
    float x2 = pos_x - circle_radius * cos(radians(current_angle));
    float y2 = pos_y - circle_radius * sin(radians(current_angle));
    line(x1, y1, x2, y2);
    fill(color(255, 0, 0));
    ellipse(x1, y1, 4, 4);
  }
}

int nb_flips = 0;
int nb_ones = 0;
int val = 0;
int[] bytes = new int[256];
Tychoscope t;
PImage b;
void setup(){
  size(800, 600);
  t = new Tychoscope();
  b = loadImage("baby_chicken.jpg");
  b.resize(30, 30);
  
  // Using the first available port (might be different on your computer)
  Serial port = new Serial(this, Serial.list()[1], 115200);
  
  reinit_byte_count();
}

void reinit_byte_count(){
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = 0;
  }
}

void draw(){
  background (255);
  t.display();
  image(b, 0, 0);
}

//Je ne sais pas si cette fonction est bien juste car elle était faite pour les char au début
//Mais on s'en fou, je récupère bien le bon nombre de bit et c'est l'essentiel pour l'instant
boolean bitAt(byte b, int pointer) {
   return ((b & (1 << pointer)) != 0);
}

boolean qrandom_boolean(){
  boolean val = nb_ones > (nb_flips / 2);
  nb_ones = 0;
  nb_flips = 0;
  return val;
}

int qrandom_number(int low, int high){
  int range = high - low;
  float range_ratio = float(range) / float(255);
  
  //On cherche le byte qui est tombé le plus souvent
  int max_occurence = 0;
  int best_val = 0;
  for (int i = 0; i < bytes.length; i++) {
    //todo si on a plusieurs valeur qui ont le même nombre d'occurence il ne faut pas tout le temps prendre la première
    if(bytes[i] > max_occurence){
      best_val = i;
    }
  }
  reinit_byte_count();
  return int(range_ratio * float(best_val));
}

// Called whenever there is something available to read
void serialEvent(Serial port) {
  val = port.read();
  bytes[val]++;
  byte by = byte(val);
  
  for (int i = 0; i < 8; i = i+1) {
    boolean bit = bitAt(by, i);
    nb_ones += int(bit);
    nb_flips++;
  }
}
