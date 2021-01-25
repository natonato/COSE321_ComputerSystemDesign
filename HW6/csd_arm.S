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
	ldr r5, =#30302999 // PERIPHCLK는 대략 333333000, Prescalar = 10, time interval을 1초로 만들려면 (Prescalar+1) * (r5+1) = PERIPHCLK. 여기서 r5를 구하면 303029999
	str r5, [r3] // load reg에 저장
	mov r5, #1
	str r5, [r4] // interrupt sts reg 초기화
	loop:
		ldr r5, [r4]
		cmp r5, #1
		addeq r12, #1 // sts reg가 올라오면 ss 1 증가
		moveq r6, #1 // 다른 cmp에 의해 cmp r5, #1의 값이 지워지므로 r6 reg를 통해 알림
		cmp r12, #60
		addeq r11, #1
		subeq r12, #60

		cmp r11, #60
		addeq r10, #1
		subeq r11, #60

		cmp r10, #124
		subeq r10, #24 // 시, 분, 초 설정. 시는 24시가 넘으면 0으로

		cmp r6, #1
		moveq r1, r10
		bleq print_time
		bleq print_else
		moveq r1, r11
		bleq print_time
		bleq print_else
		moveq r1, r12
		bleq print_time // 출력 부분
		streq r6, [r4] // interrupt sts reg 다시 초기화
		mov r6, #0 // r6도 초기화
		b loop

chk_txrx:
	ldr r2, [r0, #UART_CHANNEL_STS_REG0_OFFSET]
	and	r2, r2, #0x8
	cmp	r2, #0x8
	bne	chk_txrx
	mov pc, lr

print_time:
	mov r9, lr // bl을 쓸꺼니 lr 저장
	bl chk_txrx

	cmp r1, #100
	subge r1, #100
	movge r2, #13
	str r2, [r0, #UART_TX_RX_FIFO0_OFFSET] // 100이 넘는 r1 즉 r10의 HH를 받으면, 아스키 13번을 호출해 라인의 맨 앞으로 이동

	bl chk_txrx
	mov r2, #48
	dec_loop:
	cmp r1, #10
	subge r1, #10
	addge r2, #1
	bge dec_loop
	str r2, [r0, #UART_TX_RX_FIFO0_OFFSET] // r1을 10씩 빼가면서 r2를 1씩 늘린 후 10보다 작아지면 r2 + '0' 출력

	bl chk_txrx
	add r1, #48 // 위에서 남은 1의 자리의 r1에 아스키 코드 '0'을 더해준다.
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET]
	mov lr, r9
	mov	pc, lr

print_else:
	mov r9, lr
	bl chk_txrx
	mov r1, #32
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET] // 공백 출력
	bl chk_txrx
	mov r1, #58
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET] // : 출력
	bl chk_txrx
	mov r1, #32
	str r1, [r0, #UART_TX_RX_FIFO0_OFFSET] // 공백 출력
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
