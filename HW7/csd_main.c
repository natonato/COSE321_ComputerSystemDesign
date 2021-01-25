




int indata[32] = { 2, 0, -7, -1, 3, 8, -4, 10,
 -9, -16, 15, 13, 1, 4, -3, 14,
 -8, -10, -15, 6, -13, -5, 9, 12,
 -11, -14, -6, 11, 5, 7, -2, -12 };     // input data
int outdata[32];						// output data


//#pragma GCC target ("arm")	// arm모드
#pragma GCC target ("thumb") 	// thumb모드

//컴파일할때 번갈아서 사용

int sorting_test()
{
	for(int i=0; i<32; i++) // 모든 i에 대해
	outdata[i] = indata[i]; // output에 input 복사
	int temp; 				//임시 변수
	for(int i=0; i<32; i++){	//모든 i에 대해
		for(int j=0; j<32-i; j++){ // 0~ 32-i까지의 j에 대해
			if(outdata[j] > outdata[j+1]){ //output[j]가 ourput[j+1]보다 크면
				temp = outdata[j];
				outdata[j]= outdata[j+1];
				outdata[j+1]=temp; // 두 데이터를 교환
			}
		}
	}// 버블소트



	return 0;
}


