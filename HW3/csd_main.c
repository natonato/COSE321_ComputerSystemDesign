#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
void csd_main(int* address)
{
	int sw;
	sw = *address; // r0���� ������ csd_SWITCH_ADDR �ּҰ� ����Ű�� ���� ����
	int delay; // ������
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
	else{            //���� sw ����
		delay = 1000;
	}// �󸶳� ��ٸ��� ����

	usleep(delay * 1000); // ���
}
