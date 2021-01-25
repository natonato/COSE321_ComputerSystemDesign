#include "debug_macro.s"
#define csd_LED_ADDR	0x41200000

.extern csd_main

.align 8

// Our interrupt vector table
csd_entry:
	b csd_reset
	b .
	b .
	b .
	b .
	b .
	//b csd_irq
	b .

.global main
csd_reset:
main:
// Bubble sort�� ����� data�� asc�� �����ϴ� program�Դϴ�.
	debug_macro

	ldr r1, =Output_data // r1�� Output_data�� �ε��մϴ�
	debug_macro

	mov r2, #31 // r2�� �� ��ȸ�� sort������ ���� �����մϴ�. 32���� data�� ������ 31ȸ�� sort�� �ϸ� ������ �Ϸ�� ���Դϴ�.
	mov r6, #0  // temp�� ����� reg�Դϴ�
	debug_macro
loop:
	debug_macro
	ldr r0, =Input_data // �� �������� �ٽ� input data�� ó������ �����ϱ� ���� r0���� �Ź� �ٽ� �ε��մϴ�
	ldr r3, [r0], #4   // r0�� ù �����͸� r3���� �ű�� r0�� 4ĭ ������ ������Ʈ�մϴ�
	mov r4, #0 // r0���� �� ���� ���Ҷ� ���� ���� �� reg�Դϴ�.
	subs r5, r2, #1 // r5�� �� sort �������� ��� ��/��ȯ ������ �ؾ��ϴ����� ��Ÿ���ϴ�. r5�� ���ϴ� �������� bpl�� ���� r5�� 0�϶��� loop�� ����ǹǷ�, 1�� �߰��� sub�Ͽ� �ݴϴ�.
	debug_macro

	loop2: // loop2 ������ �����Ҷ�, [r0]�� �����ʹ� r3�� �ִ� �������� ���� ���� ����Ű�� �־�� �մϴ�. - A����
		mov r4, r3 //r3�� �ִ� �����͸� r4�� �ű�ϴ�.
		ldr r3, [r0] //���� r0�� �����͸� r3���� �ű�ϴ�.
		cmp r4, r3 // r0�� ������ �� 2���� ���մϴ�.
		debug_macro
		blt swap // r4�� r3���� �۴ٸ�, swap���� ���ϴ�

		add r0, r0, #4 // r4�� r3���� ���� �ʴٸ�, ���� ������ ���� r0�� #4��ŭ �̵���ŵ�ϴ�.
		b notswap // �׳� �������� swap���� ���� ������ branch�� ����� notswap���� ���ϴ�
		debug_macro
		swap:
			mov r6, r4
			mov r4, r3
			mov r3, r6  // r4�� r3�� �����͸� ��ȯ�ϴ� 3���Դϴ�
			str r3, [r0], #-4 //���� r0�� �ڸ��� r3�� �����͸� �ְ� #-4��ŭ �̵���ŵ�ϴ�.
			str r4, [r0], #8 //������ -4��ŭ �̵��Ͽ��� ������ ���� �����Ϳ� r4�� �����͸� �ֽ��ϴ�. �׸��� ���� ������ ���� #8��ŭ �̵���ŵ�ϴ�.
			debug_macro
		notswap:

		subs r5, r5, #1 // r5���� 1��ŭ sub�մϴ�
		bpl loop2 // �� subs ������ n flag�� N�� �ɶ����� loop2�� ���ư��ϴ�.
		debug_macro
	str r3, [r1], #4   // ���� ������ �ݺ��ϸ� ��������� ���� ���� ���� ���� �ڷ� �̵��ϰ� �˴ϴ�. ���� ����� ���� ���� ���� r3�� �����Ƿ� r3�� [r1]�� �����ϰ�, #4��ŭ �̵��մϴ�.
	subs r2, r2, #1 // �ϳ��� ���� ���ĵǾ����Ƿ� r2�� 1 �ٿ��ݴϴ�.
	debug_macro
	bne  loop // �� ������ ���� 0�� �ƴҶ����� loop�� ���ư��ϴ�. r2�� ���� ������ Ƚ���̹Ƿ� 0�� �Ǹ� ������ ����˴ϴ�.
	str r4, [r1] // �� loop������ �����Ϳ� �ִ� r3�� ���� �� data�� ������ data�̹Ƿ� ��� ������ ������ ���� ���� data�� output�� ������ �ʽ��ϴ�. �׷��� ������ ������ �־��ݴϴ�.

	//������ ����Ǿ����ϴ�.

.data
.align 4

Input_data: .word 2, 0, -7, -1, 3, 8, -4, 10
 .word -9, -16, 15, 13, 1, 4, -3, 14
 .word -8, -10, -15, 6, -13, -5, 9, 12
 .word -11, -14, -6, 11, 5, 7, -2, -12

Output_data: .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0
 .word 0, 0, 0, 0, 0, 0, 0, 0

/*dst:
	.space 16  // allocate memory for 16 words*/


// Normal Interrupt Service Routine
csd_irq:
	b .