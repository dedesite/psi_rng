#ifndef _QRAND
 #define _QRAND

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
#endif
//
// Set up a memory regions to access GPIO
//
void qrand_setup()
{
#ifdef RASPBERRY
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
#endif
}

//
// Release GPIO memory region
//
void qrand_close()
{
#ifdef RASPBERRY
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
#endif
}


uint32_t qrand()
{
#ifdef RASPBERRY
    return GPIO_LEV(AVALANCHE_IN);
#else
    return rand() % 2;
#endif
}

#endif /*_QRAND*/