
#define csd_LED_ADDR	0x41200000
#define csd_SWITCH_ADDR	0x41210000
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
	b csd_irq
	b .

.global main
csd_reset:
main:
	ldr r4, =csd_LED_ADDR // LED 주소 저장
	ldr r5, =0x1  //16진수 1로 초기화
	str r5, [r4] // 1 값을 r4에 저장.
	loop:
		ldr r0, =csd_SWITCH_ADDR // c로 변수를 보내기 위해
		bl csd_main // c 호출

		mov r5, r5, LSL #1 // r5를 LSL 1한다.
		cmp r5, #0x00000100 // 뒤 8개의 값을 벗어났는지 검사
		moveq r5, #1 // 벗어났다면, 1값으로 초기화. ROL

		str r5, [r4] //R5를 R4에 저장
		b loop


//.data
//.align 4



/*dst:
	.space 16  // allocate memory for 16 words*/


// Normal Interrupt Service Routine
csd_irq:
	b .
