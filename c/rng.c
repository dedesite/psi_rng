/**
    This code is heavilly based on Giorgio Vazzana code, explained here :
    http://holdenc.altervista.org/avalanche/

    I just modify it a bit and add a RASPBERRY option to test the program on my computer.
*/

/*
 * avalanche - reads a random bit sequence generated by avalanche noise in a
 * pn junction and appends the bits to a file every hour
 * If SIGINT is received, append the sequence acquired so far and exit
 *
 * Copyright 2012 Giorgio Vazzana
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

#include "daemonize.h"

//In microseconds
#define THEORETICAL_SLEEP_INTERVAL 500
//In milliseconds
#define SAMPLE_DURATION 100
long NB_SAMPLES = (SAMPLE_DURATION*1000)/THEORETICAL_SLEEP_INTERVAL;

#define FIFO_FILE "/tmp/.rng_fifo"

uint32_t nb_numbers = 0;
uint32_t adjust_times = 0;
uint8_t *samples;
//We store numbers as bytes
uint8_t current_number = 0;
//In micro seconds
int sleep_interval = THEORETICAL_SLEEP_INTERVAL;
FILE *fp;
struct timeval t1, t2;

//Return the diff in milliseconds between two timeval struct
long diff_time(struct timeval *t1, struct timeval *t0 ){
    return (t1->tv_sec-t0->tv_sec)*1000 + (t1->tv_usec-t0->tv_usec)/1000;
}

void build_byte(uint32_t bit, uint32_t byte_position){
    //We build an uint8 number with random bits
    if(bit){
        current_number = (current_number << 1) | 0x01;
    }
    else{
        current_number = (current_number << 1);
    }

    if((byte_position+1) % 8 == 0){
        samples[nb_numbers] = current_number;
        current_number=0;
        nb_numbers++;
    }
}

//Send numbers to the websocket server through a fifo
void send_numbers(){
    fp = fopen(FIFO_FILE, "wb");
    if (fp) {
        fwrite(samples, 1, nb_numbers, fp);
        fclose(fp);
    }
    else {
        perror("error opening fifo");
        exit(1);
    }

    nb_numbers = 0;
}
/**
As we want to X samples per seconds, we can't just
do usleep(Y) (when Y represent the exact number in micro seconds between samples)
cause our algorithm took time to execute so the real
sample interval will be X+computation_time. So we need to calculate,
on avarage, what is the cost of our algorithm and substract it to the theoritical sleep interval
This way we know that we have X samples per second, even if the interval is not always the same.
*/
void adjust_sleep_interval(struct timeval *t1, struct timeval *t0){
    if(adjust_times >= 10){
        long diff = diff_time(t1, t0);
        //We expect the code above take 100ms to execute
        if(diff > SAMPLE_DURATION){
            //Attention we are in micro second here
            long diff_micro = (diff - SAMPLE_DURATION) * 1000;
            long computation_time = (long)(diff_micro / (long)NB_SAMPLES);
            sleep_interval = THEORETICAL_SLEEP_INTERVAL - computation_time;
            if(sleep_interval < 0){
                printf("Computation time %lu > %d micro seconds\n", computation_time, THEORETICAL_SLEEP_INTERVAL);
                sleep_interval = 0;
            }
        }
        adjust_times = 0;
    }
}

//Wether or not we are on a Raspberry, if not use software generated number
#ifdef __arm__
# define RASPBERRY 1
#endif

#ifdef RASPBERRY
// GPIO Avalanche input
#define AVALANCHE_IN  4
#define LED           9

// GPIO registers address
#define BCM2708_PERI_BASE  0x20000000
#define GPIO_BASE          (BCM2708_PERI_BASE + 0x200000) /* GPIO controller */
#define BLOCK_SIZE         (256)

// GPIO setup macros. Always use GPIO_IN(x) before using GPIO_OUT(x) or GPIO_ALT(x,y)
#define GPIO_IN(g)    *(gpio+((g)/10)) &= ~(7<<(((g)%10)*3))
#define GPIO_OUT(g)   *(gpio+((g)/10)) |=  (1<<(((g)%10)*3))
#define GPIO_ALT(g,a) *(gpio+(((g)/10))) |= (((a)<=3?(a)+4:(a)==4?3:2)<<(((g)%10)*3))

#define GPIO_SET(g) *(gpio+7)  = 1<<(g)  // sets   bits which are 1, ignores bits which are 0
#define GPIO_CLR(g) *(gpio+10) = 1<<(g)  // clears bits which are 1, ignores bits which are 0
#define GPIO_LEV(g) (*(gpio+13) >> (g)) & 0x00000001

int                mem_fd;
void              *gpio_map;
volatile uint32_t *gpio;
//
// Set up a memory regions to access GPIO
//
void setup_io()
{
    /* open /dev/mem */
    mem_fd = open("/dev/mem", O_RDWR|O_SYNC);
    if (mem_fd == -1) {
        perror("Cannot open /dev/mem");
        exit(1);
    }

    /* mmap GPIO */
    gpio_map = mmap(NULL, BLOCK_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, mem_fd, GPIO_BASE);
    if (gpio_map == MAP_FAILED) {
        perror("mmap() failed");
        exit(1);
    }

    // Always use volatile pointer!
    gpio = (volatile uint32_t *)gpio_map;

    // Configure GPIOs
    GPIO_IN(AVALANCHE_IN); // must use GPIO_IN before we can use GPIO_OUT

    GPIO_IN(LED);
//  GPIO_OUT(LED);
}

//
// Release GPIO memory region
//
void close_io()
{
    int ret;

    /* munmap GPIO */
    ret = munmap(gpio_map, BLOCK_SIZE);
    if (ret == -1) {
        perror("munmap() failed");
        exit(1);
    }

    /* close /dev/mem */
    ret = close(mem_fd);
    if (ret == -1) {
        perror("Cannot close /dev/mem");
        exit(1);
    }
}
#endif

int main(int argc, char *argv[])
{
    if(argv[1] != NULL && strcmp(argv[1], "-d") == 0){
        daemonize();
    }

    uint32_t bit;
    uint32_t i;

    /* Create the FIFO if it does not exist */
    umask(0);
    mkfifo(FIFO_FILE, 0666);

    printf("Waiting for server to start...\n");
    fp = fopen(FIFO_FILE, "w");
    if (fp) {
        printf("Server started : could start Random numbers generation.\n");
        fclose(fp);
    }
    else {
        perror("error opening fifo");
        exit(1);
    }
#ifdef RASPBERRY
    // Setup gpio pointer for direct register access
    setup_io();
#endif

    samples = calloc(NB_SAMPLES/8, sizeof(*samples));
    if (!samples) {
        printf("Error on calloc()\n");
        exit(1);
    }


    while (1) {
        adjust_times++;
        if(adjust_times >= 10){
            gettimeofday(&t1, 0);
        }

        for (i = 0; i < NB_SAMPLES; i++) {
#ifdef RASPBERRY
            bit = GPIO_LEV(AVALANCHE_IN);
/*
            if (bit)
                GPIO_SET(LED);
            else
                GPIO_CLR(LED);
*/
#else
            bit = rand() % 2;
#endif
            build_byte(bit, i);

            usleep(sleep_interval);
        }

        send_numbers();

        if(adjust_times >= 10){
            gettimeofday(&t2, 0);
        }

        adjust_sleep_interval(&t2, &t1);
    }

#ifdef RASPBERRY
    close_io();
#endif

    return 0;
}
