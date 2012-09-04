class Tychoscope{
  final int NEW_MOVE = 0;
  final int ROTATING = 1;
  final int PAUSE_1 = 2;
  final int MOVING = 3;
  final int PAUSE_2 = 4;
  //in cm
  final int ROBOT_DIAMETER = 8;
  //in cm possible value in poec'h experiment : 1cm, 2.1cm, 4.2cm ou 8.3cm
  final double AVERAGE_DISTANCE = 2.1;
  //in degrees/sec possible value in poec'h experiment : 18, 36, 72, 144
  final int ROTATION_SPEED = 144;//1000;
  //in cm/sec possible value in poec'h experiment : 1, 2, 4, 8
  final int SPEED = 8;//16;
  //in ms possible values in poec'h experiment : 100, 800, 1600, 3200
  final int PAUSE_DELAY = 100;//10;
  //Necesaire pour l'affichage du tracé du robot
  ArrayList<int []> trail_points;
  
  int pos_x;
  int pos_y;
  int previous_pos_x;
  int previous_pos_y;
  color col;
  float current_angle;
  float previous_angle;
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
        if(state_time >= PAUSE_DELAY){
          last_state_time = millis();
          state = MOVING;
        }
        break;
      case MOVING:
        boolean next_state = false;
        if(state_time <= moving_time){
          float distance_percent = float(state_time) / float(moving_time);
          float distance_to_add = distance_percent * float(random_distance);
          //If we hit the wall, stop moving and pass to the next state
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
        if(state_time >= PAUSE_DELAY){
          last_state_time = millis();
          state = NEW_MOVE;
        }
        break;
      default:
        break;
    }
  }
  
  void display(){
    if(rng.is_ready()){
      move();
    }

    if(!HIDE_ROBOT || experiment_ended){
      fill(0);
      //On affiche le tracé avant le robot comme ça le robot passe par dessus
      for(int i = 0 ; i < trail_points.size() - 1 ; i++){
        int[] p1 = trail_points.get(i);
        int[] p2 = trail_points.get(i+1);
        line(p1[0], p1[1], p2[0], p2[1]);
      }
      
      //Le robot est désactivé pendant la génération du pool
      //On l'affiche en gris
      if(!rng.is_ready()){
        fill(128);
      }
      else{
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
