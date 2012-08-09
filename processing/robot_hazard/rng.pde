//Random Number Generator
class Rng{
  //Il est possible de définir un pool de nombre aléatoire
  //Qui seront générés à partir d'un certain nombre de sample 
  //(on prendra le nombre le plus fréquement sorti par ex.)
  //Si le pool est à zéro, qrand renverra le dernier bit sorti
  int min_pool_size;
  //Je met un maximum pour éviter trop de consommation mémoire si on laisse tourner
  //le programme longtemps
  int max_pool_size = 10000;
  //Nombre de samples nécessaires à générer un boolean ou un byte
  int nb_sample_per_generation;
  
  //Nb de sample a faire pour le test d'homogeneite
  int homogeneity_nb_sample = 50000;
  int[] homogeneity_bytes = new int[256];
  boolean test_homogeneity = false;
  int current_homogeneity_sample = 0;
  
  //Dernières données reçu par le générateur
  int last_byte = 0;
  boolean last_boolean = false;
  
  //Nombre de flip et de 1 depuis la dernière génération de boolean
  int current_nb_flips = 0;
  int current_nb_ones = 0;
  //Tableau stockant le nombre d'occurence pour chaque valeur d'un byte
  int[] current_bytes = new int[256];
  
  //On stocke les chiffres généré dans des arrayList
  //Type FILO (First In Last Out)
  ArrayList<Boolean> boolean_pool;
  ArrayList<Integer> byte_pool;
  
  Rng(int pool_size, int nb_sample){
    min_pool_size = pool_size;
    nb_sample_per_generation = nb_sample;
    
    //Initialisation des pools
    boolean_pool = new ArrayList();
    byte_pool = new ArrayList();
    
    reinit_byte_count();
  }
  //Par défaut on a un très petit pool et les numéros sont générés
  //Directement (pas de nombre de sample minimal)
  Rng(){ this(10, 0); }
  //Si la taille de la pool est définie, on met un nombre de sample assez conséquent
  Rng(int pool_size){ this(pool_size, 3000); }  
  
  void reinit_byte_count(){
    for (int i = 0; i < current_bytes.length; i++) {
      current_bytes[i] = 0;
    }
  }
  
  //Renvois un nombre entier entre les bornes low et high (inclusive)
  //Prend soit de la pool (si pool) ou du dernier byte générer
  int qrand_number(int low, int high){
    //Notre range est inclusif ex : si low est a 1 et high a 100, on veut un range de 100
    int range = high - (low-1);
    float range_ratio = float(range) / 256.0;

    int rand_val = last_byte;
    //On renvoit le dernier nombre du pool (le plus récent) si possible
    if(byte_pool.size() > 0){
      rand_val = byte_pool.remove(byte_pool.size()-1).intValue();
    }
    return int(range_ratio * float(rand_val)) + low;
  }
  int qrand_number(){ return qrand_number(1, 100);}
  int qrand_byte(){ return qrand_number(0, 255);}
  
  //Renvois un boolean soit du pool, soit le dernier générer si pas de pool
  boolean qrand_boolean(){
    boolean b = last_boolean;
    if(boolean_pool.size() > 0){
      b = boolean_pool.remove(boolean_pool.size()-1).booleanValue();
    }
    return b;
  }
  
  //On définit un byte aléatoirement en prenant celui qui est apparu
  //Le plus souvent parmis les n derniers tirages
  //Peut-être pas la meilleure solution, à voir...
  int get_max_occurence_ind(int[] array_num){
    //On cherche le byte qui est tombé le plus souvent
    int max_occurence = 0;
    int best_val = 0;
    for (int i = 0; i < array_num.length; i++) {
      //todo si on a plusieurs valeur qui ont le même nombre d'occurence il ne faut pas tout le temps prendre la première
      if(array_num[i] > max_occurence){
        best_val = i;
        max_occurence = array_num[i];
      }
    }
    
    return best_val;
  }
  
  void fill_pool(){
    if(current_nb_flips > nb_sample_per_generation){
      if(boolean_pool.size() < max_pool_size){
        boolean_pool.add(current_nb_ones > (current_nb_flips/2));
        current_nb_ones = 0;
        current_nb_flips = 0;
      }
      if(byte_pool.size() < max_pool_size){
        int qi = get_max_occurence_ind(current_bytes);
        byte_pool.add(qi);
        reinit_byte_count();
      }
    }
  }
  
  boolean is_ready(){
    return boolean_pool.size() > min_pool_size && byte_pool.size() > min_pool_size;
  }
  
  //Je ne sais pas si cette fonction est bien juste car elle était faite pour les char au début
  //Mais on s'en fou, je récupère bien le bon nombre de bit et c'est l'essentiel pour l'instant
  boolean bit_at(byte b, int pointer) {
     return ((b & (1 << pointer)) != 0);
  }
  
  //Appeler généralement dans le serialEvent de l'application
  //Reçoit le résultat d'un port.read()
  void number_recieved(int num){
    last_byte = num;
    //On compte le nombre d'occurrence de chacun des nombres générés
    current_bytes[num]++;
    if(test_homogeneity){
      test_number_homogeneity(num);
    }
    //Découpe du byte reçu en bit utilisés dans la génération des booleans
    byte b = byte(num);
    for (int i = 0; i < 8; i++) {
      boolean bit = bit_at(b, i);
      current_nb_ones += int(bit);
      current_nb_flips++;
      
      if(i == 7){
        last_boolean = bit;
      }
    }
    
    fill_pool();
  }
  
  void test_number_homogeneity(int num){
    homogeneity_bytes[num]++;
    current_homogeneity_sample++;
    if(current_homogeneity_sample >= homogeneity_nb_sample){
      test_homogeneity = false;
      //write result to a csv file
      String[] report = new String[257];
      report[0] = "number, occurence";
      for(int i = 0 ; i < homogeneity_bytes.length; i++){
        report[i+1] = i + "," + homogeneity_bytes[i];
      }
      println("Save results into a file...");
      saveStrings("homogeneity_test.csv", report);
      println("Test finish");
    }
  }
  
  void start_homogeneity_test(){
    println("Start testing number homogeneity");
    test_homogeneity = true;
    for (int i = 0; i < homogeneity_bytes.length; i++) {
      homogeneity_bytes[i] = 0;
    }
    current_homogeneity_sample = 0;
  }
  
  void start_logging(){
  }
  
  void stop_logging(){
  }
}
