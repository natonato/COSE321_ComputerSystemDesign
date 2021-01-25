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
// Bubble sort를 사용해 data를 asc로 정렬하는 program입니다.
	debug_macro

	ldr r1, =Output_data // r1에 Output_data를 로드합니다
	debug_macro

	mov r2, #31 // r2는 총 몇회의 sort과정을 할지 지정합니다. 32개의 data가 있으니 31회의 sort를 하면 정렬이 완료될 것입니다.
	mov r6, #0  // temp로 사용할 reg입니다
	debug_macro
loop:
	debug_macro
	ldr r0, =Input_data // 매 루프마다 다시 input data의 처음부터 정렬하기 위해 r0으로 매번 다시 로드합니다
	ldr r3, [r0], #4   // r0의 첫 데이터를 r3으로 옮기고 r0을 4칸 앞으로 업데이트합니다
	mov r4, #0 // r0에서 두 값을 비교할때 앞의 값이 들어갈 reg입니다.
	subs r5, r2, #1 // r5는 매 sort 과정에서 몇번 비교/교환 연산을 해야하는지를 나타냅니다. r5를 비교하는 과정에서 bpl이 사용되 r5가 0일때도 loop가 진행되므로, 1을 추가로 sub하여 줍니다.
	debug_macro

	loop2: // loop2 연산을 시작할때, [r0]의 데이터는 r3에 있는 데이터의 다음 값을 가리키고 있어야 합니다. - A조건
		mov r4, r3 //r3에 있는 데이터를 r4로 옮깁니다.
		ldr r3, [r0] //현재 r0의 데이터를 r3으로 옮깁니다.
		cmp r4, r3 // r0의 연달은 값 2개를 비교합니다.
		debug_macro
		blt swap // r4가 r3보다 작다면, swap으로 갑니다

		add r0, r0, #4 // r4가 r3보다 작지 않다면, 다음 연산을 위해 r0을 #4만큼 이동시킵니다.
		b notswap // 그냥 내려가면 swap으로 들어가기 때문에 branch를 사용해 notswap으로 갑니다
		debug_macro
		swap:
			mov r6, r4
			mov r4, r3
			mov r3, r6  // r4와 r3의 데이터를 교환하는 3줄입니다
			str r3, [r0], #-4 //현재 r0의 자리에 r3의 데이터를 넣고 #-4만큼 이동시킵니다.
			str r4, [r0], #8 //위에서 -4만큼 이동하였기 때문에 앞의 데이터에 r4의 데이터를 넣습니다. 그리고 다음 연산을 위해 #8만큼 이동시킵니다.
			debug_macro
		notswap:

		subs r5, r5, #1 // r5에서 1만큼 sub합니다
		bpl loop2 // 위 subs 연산결과 n flag가 N이 될때까지 loop2로 돌아갑니다.
		debug_macro
	str r3, [r1], #4   // 위의 연산을 반복하면 결과적으로 가장 작은 값이 가장 뒤로 이동하게 됩니다. 연산 종료시 가장 뒤의 값은 r3에 있으므로 r3를 [r1]에 저장하고, #4만큼 이동합니다.
	subs r2, r2, #1 // 하나의 값이 정렬되었으므로 r2를 1 줄여줍니다.
	debug_macro
	bne  loop // 위 연산의 값이 0이 아닐때까지 loop로 돌아갑니다. r2는 남은 정렬할 횟수이므로 0이 되면 정렬이 종료됩니다.
	str r4, [r1] // 위 loop문에서 데이터에 넣는 r3는 비교한 두 data중 뒤쪽의 data이므로 모든 정렬이 끝나도 가장 앞의 data는 output에 들어가있지 않습니다. 그렇게 때문에 별도로 넣어줍니다.

	//정렬이 종료되었습니다.

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
