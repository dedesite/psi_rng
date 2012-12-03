#include <stdio.h>
#include <stdlib.h>

#define FIFO_FILE       "MYFIFO"

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
    //in 100ms we can do 200 samples with 500micro seconds of interval 
    for (i = 0; i < 200*10; i++) {
      usleep(500);
    }

    write_fifo(i);
  }
  return(0);
}