#define csd_LED_ADDR	0x41200000
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "uart_regs.h"
void init_message();
int led_change =1;
int *led = csd_LED_ADDR;
int init=0;
int delay=1000; // µô·¹ÀÌ
int csd_main()
{
	if(init==0){
		init_message();
		init =1;
	}
	int rx_chk =0;
	int *rx_chk_addr = UART1_BASE + UART_CHANNEL_STS_REG0_OFFSET;
	rx_chk = *rx_chk_addr;
	rx_chk = rx_chk & 0b0010;


	int input = 0;
	int *input_addr;
	input_addr= UART1_BASE + UART_TX_RX_FIFO0_OFFSET;
	if(rx_chk ==0){
		input = *input_addr;
	}
	int chk=1;

	while(chk==1){

			if(input >= 49 && input <= 56){
				init=0;
				chk=0;
			}
			else if( input == 0){
				chk=0;
			}
			else{
				rx_chk = *rx_chk_addr;
				rx_chk = rx_chk & 0b0010;
				if(rx_chk ==0 ) input = *input_addr;
				else chk=0;
			}

	}

	if(input=='1'){ // input1
		delay = 100;
	}
	else if(input=='2'){ // input2
		delay = 200;
	}
	else if(input=='3'){ // input3
		delay = 300;
	}
	else if(input=='4'){// input4
		delay = 400;
	}
	else if(input=='5'){// input5
		delay = 500;
	}
	else if(input=='6'){// input6
		delay = 600;
	}
	else if(input=='7'){// input7
		delay = 700;
	}
	else if(input=='8'){// input8
		delay = 1000;
	}

	usleep(delay * 1000); // ´ë±â
	if(led_change==256){
		led_change =1;
		*led = led_change;
		led_change = led_change*2;
	}
	else{
		*led = led_change;
		led_change = led_change*2;
	}
	if(input >= 49 && input <= 56)
		return input;
	else return 0;
}


void init_message(){

	print("\n\r----------LED on Duration ----------\n\r");
	print("1. 100ms 2. 200ms 3. 300ms 4. 400ms\n\r");
	print("5. 500ms 6. 600ms 7. 700ms 8. 1 sec\n\r");
	print("------------------------------------\n\r");
	print("Select:");
}
