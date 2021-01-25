#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void csd_main(int* address)
{
	int sw;
	sw = *address; // r0으로 보내진 csd_SWITCH_ADDR 주소가 가리키는 값을 저장
	int delay; // 딜레이
	if(sw>=128){ // sw7
		delay = 100;
	}
	else if(sw>=64){ // sw6
		delay = 200;
	}
	else if(sw>=32){ // sw5
		delay = 300;
	}
	else if(sw>=16){// sw4
		delay = 400;
	}
	else if(sw>=8){// sw3
		delay = 500;
	}
	else if(sw>=4){// sw2
		delay = 600;
	}
	else if(sw>=2){// sw1
		delay = 700;
	}
	else if(sw>=1){// sw0
		delay = 800;
	}
	else{            //켜진 sw 없음
		delay = 1000;
	}// 얼마나 기다릴지 설정

	usleep(delay * 1000); // 대기
}
