import processing.serial.*;

class Tychoscope{
  final int NEW_MOVE = 0;
  final int ROTATING = 1;
  final int PAUSE_1 = 2;
  final int MOVING = 3;
  final int PAUSE_2 = 4;
  
  //Necesaire pour l'affichage du tracé du robot
  ArrayList<int []> trail_points;
  
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
  boolean random_clockwise;
  //Avant ou arriere
  boolean random_forward;
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
    pause_delay = 100;
    circle_size = 40;
    circle_radius = circle_size / 2;
    rotation_time = 100;
    
    state = NEW_MOVE;
    
    trail_points = new ArrayList();
    //On créer les deux premier points, pour l'instant identiques
    int[] p1 = new int[] {pos_x, pos_y};
    trail_points.add(p1);
    int[] p2 = new int[] {pos_x, pos_y};
    trail_points.add(p2);
  }
  
  void move(){
    int current_time = millis();
    int diff = current_time - last_state_time;
    switch(state){
      case NEW_MOVE:
        //TODO : avoir un petit temps d'attente entre chaque génération de nombre aléatoire
        //Pour avoir une base de chiffre assez importante
        //random_clockwise = random(0,1) > 0.5;
        random_clockwise = rng.qrand_boolean();
        //random_angle = random(0, 360);
        random_angle = rng.qrand_number(1, 100) * 3.6;
        if(!random_clockwise){
          random_angle = -random_angle;
        }
        //random_forward = random(0,1) > 0.5;
        random_forward = rng.qrand_boolean();
        //random_distance = int(random(20, 100));
        random_distance = rng.qrand_number(20, 100);
        
        println("Angle : " + random_angle);
        println("Sens des aiguilles d'une montre ? " + random_clockwise);
        println("En avant ? " + random_forward);
        println("Distance : " + random_distance);
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
          if(random_forward){
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
          
          //Mise à jour du dernier point du tracé
          int[] p = trail_points.get(trail_points.size()-1);
          p[0] = pos_x;
          p[1] = pos_y;
        }
        else{
          next_state = true;
        }
        if(next_state){
          previous_pos_x = pos_x;
          previous_pos_y = pos_y;
          //On commence un nouveau point
          int[] p = new int[] {pos_x, pos_y};
          trail_points.add(p);
          
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
    fill(0);
    //On affiche le tracé avant le robot comme ça le robot passe par dessus
    for(int i = 0 ; i < trail_points.size() - 1 ; i++){
      int[] p1 = trail_points.get(i);
      int[] p2 = trail_points.get(i+1);
      line(p1[0], p1[1], p2[0], p2[1]);
    }
    
    //Le robot est désactivé pendant la génération du pool
    if(!rng.is_ready()){
      fill(128);
    }
    else{
      move();
      fill(col);
    }
    
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

Tychoscope t;
PImage chicken;
PFont f;
Rng rng;

void setup(){
  size(800, 600);
  f = createFont("Arial", 20, true);
  t = new Tychoscope();
  chicken = loadImage("baby_chicken.jpg");
  chicken.resize(30, 30);
  
  // Using the first available port (might be different on your computer)
  Serial port = new Serial(this, Serial.list()[0], 115200);
  
  rng = new Rng();
  rng.start_homogeneity_test();
}

void draw(){
  background (255);
  //t.display();
  
  if(!rng.is_ready()){
    textFont(f,20);
    fill(0);
    textAlign(CENTER, CENTER);
    text("Generating random numbers pool... ", width/2, height/2);
  }
  else{
    image(chicken, 0, 0);
  }
}

// Called whenever there is something available to read
void serialEvent(Serial port) {
  rng.number_recieved(port.read());
}
