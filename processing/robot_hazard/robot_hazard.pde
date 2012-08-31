import processing.serial.*;

class Tychoscope{
  final int NEW_MOVE = 0;
  final int ROTATING = 1;
  final int PAUSE_1 = 2;
  final int MOVING = 3;
  final int PAUSE_2 = 4;
  //in cm
  final int ROBOT_DIAMETER = 8;
  //in cm
  final double AVERAGE_DISTANCE = 2.1;
  //in degrees/sec possible value in poec'h experiment : 18, 36, 72, 144
  final int ROTATION_SPEED = 144;
  //in cm/sec possible value in poec'h experiment : 1, 2, 4, 8
  final int SPEED = 8;
  //Necesaire pour l'affichage du tracé du robot
  ArrayList<int []> trail_points;
  
  int pos_x;
  int pos_y;
  int previous_pos_x;
  int previous_pos_y;
  color col;
  float current_angle;
  float previous_angle;
  int pause_delay;
  int circle_size;
  int circle_radius;
  int state;
  //Function of the random_angle (in ms)
  int rotation_time;
  //Function of the random distance (in ms)
  int moving_time;
  
  //Entre 0 et 360
  float random_angle;
  //Aiguille d'une montre ou sens inverse
  boolean random_clockwise;
  //Avant ou arriere
  boolean random_forward;
  //0 à 10cm
  int random_distance;
  
  int last_state_time;
  int sample_count=0;
  
  double distance_px;
  int speed_px;
  
  Tychoscope(){
    pos_x = width/2;
    pos_y = height/2;
    previous_pos_x = pos_x;
    previous_pos_y = pos_y;
    col = color(0, 255, 0);
    current_angle = 0.0;
    previous_angle = 0.0;
    pause_delay = 100;
    circle_size = ROBOT_DIAMETER * cm_px;
    circle_radius = circle_size / 2;
    distance_px = AVERAGE_DISTANCE * cm_px;
    speed_px = SPEED * cm_px;
    state = NEW_MOVE;
    
    trail_points = new ArrayList();
    //On créer les deux premier points, pour l'instant identiques
    int[] p1 = new int[] {pos_x, pos_y};
    trail_points.add(p1);
    int[] p2 = new int[] {pos_x, pos_y};
    trail_points.add(p2);
  }
  //Handle when < 0 or > 360
  void set_current_angle(float angle){
    current_angle = angle;   
    if(current_angle > 360){
      current_angle = current_angle - 360;
    }
    else if(current_angle < 0){
      current_angle = 360 + current_angle;
    }
  }
  
  //move the robot backward or foreward
  //also move the last point
  //manage collision
  //return true if there is a collision
  boolean add_distance(float distance_to_add){
    boolean collision = false;
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
      collision = true;
    }
    if(pos_x > width - circle_radius){
      pos_x = width - circle_radius;
      collision = true;
    }
    if(pos_y < 0 + circle_radius){
      pos_y = 0 + circle_radius;
      collision = true;
    }
    if(pos_y > height - circle_radius){
      pos_y = height - circle_radius;
      collision = true;
    }

    //Mise à jour du dernier point du tracé
    int[] p = trail_points.get(trail_points.size()-1);
    p[0] = pos_x;
    p[1] = pos_y;
    
    return collision;
  }
  
  void move(){
    int current_time = millis();
    int state_time = current_time - last_state_time;
    
    switch(state){
      case NEW_MOVE:
        //TODO : avoir un petit temps d'attente entre chaque génération de nombre aléatoire
        //Pour avoir une base de chiffre assez importante
        //random_clockwise = random(0,1) > 0.5;
        random_clockwise = rng.qrand_boolean();
        random_angle = rng.qrand_number(1, 100) * 3.6;
        random_forward = rng.qrand_boolean();
        random_distance = rng.qrand_poisson(distance_px);
        
        rotation_time = int((random_angle / float(ROTATION_SPEED)) * 1000.0);
        moving_time = int((random_distance / float(speed_px)) * 1000.0);
        /*println("Angle : " + random_angle);
        println("Sens des aiguilles d'une montre ? " + random_clockwise);
        println("En avant ? " + random_forward);
        println("Distance : " + random_distance);
        println("----------------------------------------------");*/
        output.println(sample_count+","+random_angle+","+random_clockwise+","+random_forward+","+random_distance);
        
        //Do this after the print
        if(!random_clockwise){
          random_angle = -random_angle;
        }        
        
        sample_count++;
        last_state_time = millis();
        state = ROTATING;
        break;
      case ROTATING:
        if(state_time <= rotation_time){
          float angle_percent = float(state_time) / float(rotation_time);
          float angle_to_add = angle_percent * random_angle;
          set_current_angle(previous_angle + angle_to_add);
        }
        else{
          //Insure that we have the good angle because on my computer there is a too big delta
          set_current_angle(previous_angle + random_angle);
          previous_angle = current_angle;
          last_state_time = millis();
          state = PAUSE_1;          
        }
        break;
      case PAUSE_1:
        if(state_time >= pause_delay){
          last_state_time = millis();
          state = MOVING;
        }
        break;
      case MOVING:
        boolean next_state = false;
        if(state_time <= moving_time){
          float distance_percent = float(state_time) / float(rotation_time);
          float distance_to_add = distance_percent * float(random_distance);
          next_state = add_distance(distance_to_add);
        }
        else{
          next_state = true;
        }
        if(next_state){
          //Insure we've done the exact distance
          add_distance(random_distance);
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
        if(state_time >= pause_delay){
          last_state_time = millis();
          state = NEW_MOVE;
        }
        break;
      default:
        break;
    }
  }
  
  void display(){
    if(!HIDE_ROBOT || experiment_ended){
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
      
      if(!experiment_ended){
        //Robot circle
        ellipse(pos_x, pos_y, circle_size, circle_size);
        //Angle line position
        float x1 = pos_x + circle_radius * cos(radians(current_angle));
        float y1 = pos_y + circle_radius * sin(radians(current_angle));
        float x2 = pos_x - circle_radius * cos(radians(current_angle));
        float y2 = pos_y - circle_radius * sin(radians(current_angle));
        line(x1, y1, x2, y2);
        //Robot "nose"
        fill(color(255, 0, 0));
        ellipse(x1, y1, 4, 4);
      }
    }
  }
}

Tychoscope t;
//PImage chicken;
//Image which will be displayed at the 2 extrem corners
//One pleasant to look and one very unpleasant
PImage good_image;
PImage bad_image;
PFont f;
PrintWriter output;
Rng rng;
int start_time;
int last_time;
//Total amount of ms when the robot generate number
//Should be substract to the total time
int generating_num_time;
boolean experiment_ended = false;
//in milliseconds
final int EXPERIMENT_DURATION = 4*60*1000;
final int NB_EXPERIMENTS = 1;
//the board dimensions in cm
final int BOARD_WIDTH = 88;
final int BOARD_HEIGHT = 59;
//Will be usefull to save logs and traces
int experiment_num = 0;
int current_xp_num = 0;
boolean first_setup = true;
//Size of a centimeter in pixel
int cm_px;
final boolean HIDE_ROBOT = false;
void setup(){
  //The size of the window must have the same ratio as in the poec'h experiment
  //which is 88/59
  boolean width_over_height = BOARD_WIDTH/BOARD_HEIGHT > screen.width/screen.height;
  int size_x, size_y;
  if(width_over_height){
    size_x = screen.width;
    size_y = int(float(size_x) * float(BOARD_HEIGHT)/float(BOARD_WIDTH));
    cm_px = screen.width / BOARD_WIDTH;
  }
  else{
    size_y = screen.height;
    size_x = int(float(size_y) * float(BOARD_WIDTH)/float(BOARD_HEIGHT));
    cm_px = screen.height / BOARD_HEIGHT;
  }
  size(size_x, size_y);
  f = createFont("Arial", 20, true);
  t = new Tychoscope();
  /*chicken = loadImage("baby_chicken.jpg");
  chicken.resize(30, 30);*/
  
  /*good_image = loadImage("forest.jpg");
  bad_image = loadImage("brain.jpg");*/
  
  if(first_setup){
    // Using the first available port (might be different on your computer)
    Serial port = new Serial(this, Serial.list()[0], /*115200*/19200);
    first_setup = false;
  }
  
  //rng = new Rng(50, 100);
  rng = new Rng(1000, 1);
  //rng.start_homogeneity_test();
  String log_name = find_log_name("robot_hazard.csv");
  output = createWriter(log_name);
  println("log will be store at : " + log_name);
  //Write csv header
  output.println("sample,angle,clockwise?,forward?,distance");
  //Needed to stop automatically the experiment
  start_time = millis();
  last_time = start_time;
  generating_num_time = 0;
  
  experiment_ended = false;
  
  current_xp_num++;
}

//Find an available log name
//The first time, find the experiment number
//And then reuse it for all the others files
//This all the files has the same number (except if it already exists)
String find_log_name(String name){
  String filename = dataPath(experiment_num+"_"+name);
  File file = new File(filename);
  while (file.exists())
  {
    experiment_num++;
    filename = dataPath(experiment_num+"_"+name);
    file = new File(filename);
  }
  
  return filename;
}

void draw(){
  background (255);
  int current_time = millis();
  int delta = current_time - last_time;
  last_time = current_time;
  if(last_time - start_time >= EXPERIMENT_DURATION + generating_num_time){
    experiment_ended = true;
  }
  
  //Don't display anything if experiment ended
  //In order to be able to shoot the lines
  if(!experiment_ended){
    if(!rng.is_ready()){      
      textFont(f,20);
      fill(0);
      textAlign(CENTER, CENTER);
      text("Generating random numbers pool... ", width/2, height/2);
      //This time is not part of the experiment
      generating_num_time += delta;
    }
    else{
      /*
      //Test de l'affichage de noms a forte conotation
      textAlign(LEFT);
      textFont(f,20);
      fill(0);      
      text("Gandhi", 10, height - 10);
      textAlign(RIGHT);
      text("Hitler", width - 10, 20);
      */
      //image(chicken, 0, 0);
      
      //Test de l'affichage d'image à forte conotation
      /*image(good_image, 0, 0, screen.width / 2, screen.height / 2);
      image(bad_image, screen.width / 2, screen.height / 2, screen.width / 2, screen.height / 2);*/
    }
  }
  
  t.display();
  
  if(experiment_ended){
    finish_experiment();
  }
}

void finish_experiment(){
  println("Closing application...");
  String img_name = find_log_name("robot_hazard.tif");
  println("Save robot traces to : " + img_name);
  save(img_name); //Write the robot trace to a file
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  
  //We can automatically launch sevral experiments
  if(current_xp_num == NB_EXPERIMENTS){
    exit(); // Stops the program
  }
  else{
    setup();
  }
}

void keyPressed(){
  if(key == ESC){
    experiment_ended = true;
    //overriding escape behaviour
    key = 0;
  }
}
// Called whenever there is something available to read
void serialEvent(Serial port) {
  rng.number_recieved(port.read());
}
