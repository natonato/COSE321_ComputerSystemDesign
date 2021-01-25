#include "uart_regs.h"
//#define csd_LED_ADDR	0x41200000

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
	ldr r0, =UART1_BASE
	mov r10, #100 // hh
	mov r11, #0 // mm
	mov r12, #0 // ss
	mov r6, #0

  	ldr r2, =0xf8f00608 // Control reg
 	mov r1, #10 << 8   // Prescalar, 10
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r2]



	ldr r3, =0xf8f00600 //load reg
	ldr r4, =0xf8f0060c //Interrupt sts reg
	ldr r5, =#30302999 // PERIPHCLK�� �뷫 333333000, Prescalar = 10, time interval�� 1�ʷ� ������� (Prescalar+1) * (r5+1) = PERIPHCLK. ���⼭ r5�� ���ϸ� 303029999
	str r5, [r3] // load reg�� ����
	mov r5, #1
	str r5, [r4] // interrupt sts reg �ʱ�ȭ
	loop:
		ldr r5, [r4]
		cmp r5, #1
		addeq r12, #1 // sts reg�� �ö���� ss 1 ����
		moveq r6, #1 // �ٸ� cmp�� ���� cmp r5, #1�� ���� �������Ƿ� r6 reg�� ���� �˸�
		cmp r12, #60
		addeq r11, #1
		subeq r12, #60

		cmp r11, #60
		addeq r10, #1
		subeq r11, #60

		cmp r10, #124
		subeq r10, #24 // ��, ��, �� ����. �ô� 24�ð� ������ 0����

		cmp r6, #1
		moveq r1, r10
		bleq print_time
		bleq print_else
		moveq r1, r11
		bleq print_time
		bleq print_else
		moveq r1, r12
		bleq print_time // ��� �κ�
		streq r6, [r4] // interrupt sts reg �ٽ� �ʱ�ȭ
		mov r6, #0 // r6�� �ʱ�ȭ
		b loop

chk_txrx:
	ldr r2, [r0, #UART_CHANNEL_STS_REG0_OFFSET]
	and	r2, r2, #0x8
	cmp	r2, #0x8
	bne	chk_txrx
	mov pc, lr

print_time:
	mov r9, lr // bl�� ������ lr ����
	bl chk_txrx

	cmp r1, #100
	subge r1, #100
	movge r2, #13
	str r2, [r0, #UART_TX_RX_FIFO0_OFFSET] // 100�� �Ѵ� r1 �� r10�� HH�� ������, �ƽ�Ű 13���� ȣ���� ������ �� ������ �̵�

	bl chk_txrx
	mov r2, #48
	dec_loop:
	cmp r1, #10
	subge r1, #10
	addge r2, #1
	bge dec_loop
	str r2, [r0, #UART_TX_RX_FIFO0_OFFSET] // r1�� 10�� �����鼭 r2�� 1�� �ø� �� 10���� �۾����� r2 + '0' ���

	bl chk_txrx
	add r1, #48 // ������ ���� 1�� �ڸ��� r1�� �ƽ�Ű �ڵ� '0'�� �����ش�.
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET]
	mov lr, r9
	mov	pc, lr

print_else:
	mov r9, lr
	bl chk_txrx
	mov r1, #32
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET] // ���� ���
	bl chk_txrx
	mov r1, #58
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET] // : ���
	bl chk_txrx
	mov r1, #32
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET] // ���� ���
	mov lr, r9
	mov pc, lr


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