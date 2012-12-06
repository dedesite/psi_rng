#include <stdio.h>
#include <stdlib.h>

#define FIFO_FILE       "MYFIFO"
//In microseconds
#define THEORIC_SLEEP_INTERVAL 500
//In milliseconds
#define SAMPLE_DURATION 100
long NB_SAMPLES = (SAMPLE_DURATION*1000)/THEORIC_SLEEP_INTERVAL;

struct timeval t1, t2;
long diff=0;
int nb_times = 0;
//In micro seconds
int sleep_interval = THEORIC_SLEEP_INTERVAL;

long diff_time(struct timeval *t1, struct timeval *t0 ){
  return (t1->tv_sec-t0->tv_sec)*1000 + (t1->tv_usec-t0->tv_usec)/1000;
}

void write_fifo(int value){
  FILE *fp;
  if((fp = fopen(FIFO_FILE, "w")) == NULL) {
    perror("fopen");
    exit(1);
  }

  fprintf(fp, "%d", value);

  fclose(fp);
}

int main(void)
{
  int i;
  while(1){
    nb_times++;
    //We check the time each seconds
    if(nb_times >= 10){
      gettimeofday(&t1, 0);  
    } 

    //in 100ms we can do 200 samples with 500micro seconds of interval 
    for (i = 0; i < NB_SAMPLES; i++) {
      usleep(sleep_interval);
    }

    write_fifo(i);

    if(nb_times >= 10){
      gettimeofday(&t2, 0);
      diff = diff_time(&t2, &t1);
      //We expect the code above take 100ms to execute
      if(diff > SAMPLE_DURATION){
        //Attention we are in micro second here
        long test = 200;
        long diff_micro = (diff - SAMPLE_DURATION) * 1000;
        long computation_time = (long)(diff_micro / (long)NB_SAMPLES);
        sleep_interval = THEORIC_SLEEP_INTERVAL - computation_time;
        printf("here diff=%lu sleep_interval=%d computation_time=%lu NB_SAMPLES=%lu diff_micro=%lu\n", diff, sleep_interval, computation_time, NB_SAMPLES, diff_micro);
      }
      nb_times = 0;
    }
  }
  return(0);
}