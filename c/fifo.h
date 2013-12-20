#ifndef _FIFO
 #define _FIFO

#include <sys/stat.h>

#define FIFO_FILE "/tmp/.rng_fifo"

void create_fifo_and_wait(char* wait_msg, char* open_msg)
{
    FILE *fp;

    /* Create the FIFO if it does not exist */
    umask(0);
    mkfifo(FIFO_FILE, 0666);

    printf("%s\n", wait_msg);
    fp = fopen(FIFO_FILE, "w");
    if (fp) {
        printf("%s\n", open_msg);
        fclose(fp);
    }
    else {
        perror("error opening fifo\n");
        exit(1);
    }
}
#endif /*_FIFO*/