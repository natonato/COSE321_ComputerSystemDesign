




int indata[32] = { 2, 0, -7, -1, 3, 8, -4, 10,
 -9, -16, 15, 13, 1, 4, -3, 14,
 -8, -10, -15, 6, -13, -5, 9, 12,
 -11, -14, -6, 11, 5, 7, -2, -12 };     // input data
int outdata[32];						// output data


//#pragma GCC target ("arm")	// arm���
#pragma GCC target ("thumb") 	// thumb���

//�������Ҷ� �����Ƽ� ���

int sorting_test()
{
	for(int i=0; i<32; i++) // ��� i�� ����
	outdata[i] = indata[i]; // output�� input ����
	int temp; 				//�ӽ� ����
	for(int i=0; i<32; i++){	//��� i�� ����
		for(int j=0; j<32-i; j++){ // 0~ 32-i������ j�� ����
			if(outdata[j] > outdata[j+1]){ //output[j]�� ourput[j+1]���� ũ��
				temp = outdata[j];
				outdata[j]= outdata[j+1];
				outdata[j+1]=temp; // �� �����͸� ��ȯ
			}
		}
	}// �����Ʈ



	return 0;
}


