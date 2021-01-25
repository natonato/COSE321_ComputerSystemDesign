
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
	ldr r4, =csd_LED_ADDR // LED �ּ� ����
	ldr r5, =0x1  //16���� 1�� �ʱ�ȭ
	str r5, [r4] // 1 ���� r4�� ����.
	loop:
		ldr r0, =csd_SWITCH_ADDR // c�� ������ ������ ����
		bl csd_main // c ȣ��

		mov r5, r5, LSL #1 // r5�� LSL 1�Ѵ�.
		cmp r5, #0x00000100 // �� 8���� ���� ������� �˻�
		moveq r5, #1 // ����ٸ�, 1������ �ʱ�ȭ. ROL

		str r5, [r4] //R5�� R4�� ����
		b loop


//.data
//.align 4



/*dst:
	.space 16  // allocate memory for 16 words*/


// Normal Interrupt Service Routine
csd_irq:
	b .