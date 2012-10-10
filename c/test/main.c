#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define RAND_MAX 65535
#define UINT_MAX 4294967295

int main()
{
	//srand();
	uint32_t nb_times = 0;
	uint64_t total = 0;

	while(1){
		uint16_t rd = rand();
		total += rd;
		nb_times++;
		if(nb_times == UINT_MAX - 1){
			uint16_t average = (total/nb_times) + 1;
			printf("Moyenne : %f \n", (float)average/65536.0f);
			nb_times = 0;
			total = 0;
		}
	}
}