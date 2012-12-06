#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>
#include <time.h>
#include <linux/stat.h>

#define FIFO_FILE       "MYFIFO"

long diff_time(struct timeval *t1, struct timeval *t0 ){
  return (t1->tv_sec-t0->tv_sec)*1000 + (t1->tv_usec-t0->tv_usec)/1000;
}

int main(void)
{
  FILE *fp;
  char readbuf[80];
  int nb_times = 0;

  /* Create the FIFO if it does not exist */
  umask(0);
  mknod(FIFO_FILE, S_IFIFO|0666, 0);

  struct timeval t1, t2, current_time, last_time, start_time;
  long datetime_diff, diff_read, total_diff = 0;

  gettimeofday(&last_time, 0);
  gettimeofday(&start_time, 0);

  while(1)
  {
    //Test to read each 1000ms
    //usleep(1000*1000);

    gettimeofday(&t1, 0);
    fp = fopen(FIFO_FILE, "r");
    fgets(readbuf, 80, fp);@
    fclose(fp);
    gettimeofday(&t2, 0);
    diff_read += diff_time(&t2, &t1);


    nb_times++;

    gettimeofday(&current_time, 0);
    
    datetime_diff = diff_time(&current_time, &last_time);
    total_diff = diff_time(&current_time, &start_time);

    if(datetime_diff >= 1000){
      //It should be always 10
      long average = total_diff/nb_times;
      printf("Received each %lums nb_times=%d total_diff=%lu\n", average, nb_times, total_diff);
      gettimeofday(&last_time, 0);
      //nb_times = 0;
      diff_read = 0;
    }
  }

  return(0);
}