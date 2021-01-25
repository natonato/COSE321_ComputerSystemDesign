#include "uart_init.s"

.macro debug_macro
	sub r13, r13, #8
	stmdb r13!, {r13, r14} // 8 감소한 sp가 저장되었다.
	stmdb r13!, {r0-r12}
	add r13, r13, #68
	mrs r0, cpsr
	stmdb r13!, {r0}
	mov r0, r15
	sub r0, r0, #32
	stmdb r13!, {r0}
	sub r13, r13, #60

	uart_init
	bl uart_print


	ldr r1, [r13]
	msr cpsr, r1
	sub r13, r13, #64

	ldmia r13!, {r0-r12}
	add r13, r13, #4
	ldmia r13!, {r14}
	add r13, r13, #8

.endm



uart_print:
	mov r10, r14
	ldr r1, =string0
	bl uart_print_string
	ldr r1, =string1
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string2
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string3
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string4
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string5
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string6
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string7
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string8
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string9
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string10
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string11
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string12
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string13
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string14
	bl uart_print_string
	ldr r1, [r13],#4
	add r1, r1, #8 //저장할때 8 감소한 sp를 저장했기 때문
	bl uart_print_reg

	ldr r1, =string15
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg

	ldr r1, =string16
	bl uart_print_string
	ldr r1, [r13],#4
	bl uart_print_reg // R0 ~ 15번까지 다 출력

	ldr r1, =string17
	bl uart_print_string

	bl uart_print_cpsr // print_cpsr로 진입
	mov r14, r10
	mov pc, lr


uart_print_cpsr:
	mov r11, r14

	ldr r1, [r13]
	bl check_txrxfifo

	and r4, r1, #0x80000000
	cmp r4, #0x80000000
	moveq r3, #78  //ascii 'N'
	movne r3, #110  //ascii 'n'
	strb	r3, [r0, #0x30]

	bl check_txrxfifo

	and r4, r1, #0x40000000
	cmp r4, #0x40000000
	moveq r3, #90//ascii 'Z'
	movne r3, #122//ascii 'z'
	strb	r3, [r0, #0x30]

	bl check_txrxfifo

	and r4, r1, #0x20000000
	cmp r4, #0x20000000
	moveq r3, #67 //ascii 'C'
	movne r3, #99//ascii 'c'
	strb	r3, [r0, #0x30]

	bl check_txrxfifo

	and r4, r1, #0x10000000
	cmp r4, #0x10000000
	moveq r3, #86 //ascii 'V'
	movne r3, #118//ascii 'v'
	strb	r3, [r0, #0x30]

	ldr r1, =string18
	bl uart_print_string

	ldr r1, [r13]
	bl check_txrxfifo

	and r4, r1, #0x00000100
	cmp r4, #0x80
	moveq r3, #65 //ascii 'A'
	movne r3, #0
	strb	r3, [r0, #0x30]

	bl check_txrxfifo

	and r4, r1, #0x00000080
	cmp r4, #0x80
	moveq r3, #73 //ascii 'I'
	movne r3, #0
	strb	r3, [r0, #0x30]

	bl check_txrxfifo

	and r4, r1, #0x00000040
	cmp r4, #0x40
	moveq r3, #70//ascii 'F'
	movne r3, #0
	strb	r3, [r0, #0x30]

	ldr r1, [r13]


	ldr r8, =#0x01000020   // j비트와 t비트의 위치
	and r4, r1, r8
	cmp r4, #0x01000000
	ldrgt r1, =stringThumbEE // 0x01000000보다 크면 0x01000020
	ldreq r1, =stringJazelle // 같으면 0x01000000
	cmplt r4, #0x00000020  // 작으면 0x20과 비교
	ldreq r1, =stringThumb // 같으면 0x20
	ldrne r1, =stringARM // 다르면 0x00
	bl uart_print_string

	ldr r1, =string19
	bl uart_print_string

	ldr r1, [r13]

	and r4, r1, #0x0000001F
	cmp r4, #0x10
	ldreq r1, =stringUSR
	cmp r4, #0x11
	ldreq r1, =stringFIQ
	cmp r4, #0x12
	ldreq r1, =stringIRQ
	cmp r4, #0x13
	ldreq r1, =stringSVC
	cmp r4, #0x16
	ldreq r1, =stringMON
	cmp r4, #0x17
	ldreq r1, =stringABT
	cmp r4, #0x1A
	ldreq r1, =stringHYP
	cmp r4, #0x1B
	ldreq r1, =stringUND
	cmp r4, #0x1F
	ldreq r1, =stringSYS
	bl uart_print_string

	ldr r1, =string20
	bl uart_print_string

	ldr r1, [r13]
	bl uart_print_reg

	ldr r1, =string21
	bl uart_print_string

	mov r14, r11
	mov pc, lr



uart_print_string:
	ldr r0, =0xE0001000

	sys1_loop:

		ldr 	r2, [r0, #0x2c]	@ get Channel Status Register
		and	r2, r2, #0x8		@ get Transmit Buffer Empty bit(bit[3:3])
		cmp	r2, #0x8				@ check if TxFIFO is empty and ready to receive new data
		bne sys1_loop

		ldrb    r3, [r1], #1
		strb	r3, [r0, #0x30]	@ fill the TxFIFO with 0x48
		cmp     r3, #0x00
		bne sys1_loop

	mov pc, lr


uart_print_reg:

		ldr r0, =0xE0001000
		mov r5, #9

	init_loop:
		ldr 	r2, [r0, #0x2c]	@ get Channel Status Register
		and	r2, r2, #0x8		@ get Transmit Buffer Empty bit(bit[3:3])
		cmp	r2, #0x8				@ check if TxFIFO is empty and ready to receive new data
		bne	init_loop		@ if TxFIFO is NOT empty, keep checking until it is empty

		cmp r5, #9
		moveq r3, #48
		streq r3, [r0, #0x30]
		cmp r5, #8
		moveq r3, #120
		streq r3, [r0, #0x30]
		sub r5, r5, #1
		bne init_loop
	TRANSMIT_loop:

		ldr 	r2, [r0, #0x2c]	@ get Channel Status Register
		and	r2, r2, #0x8		@ get Transmit Buffer Empty bit(bit[3:3])
		cmp	r2, #0x8				@ check if TxFIFO is empty and ready to receive new data
		bne	TRANSMIT_loop


		mov r7, #0  // 나누기 결과가 담길 reg
		mov r8, #1	// 나눌 reg
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		mov r8, r8, LSL r5
		subs r9, r1, #0x80000000
		subpls r1, r1, #0x80000000
		movpl r9, #8
		movmi r9, #0

		DEV_loop:
			subs r1, r1, r8
			addge r7, r7, #1
			bge DEV_loop
		add r1, r1, r8


		add r7, r7, r9
		cmp r7, #9
		addgt r7, r7, #87
		addle r7, r7, #48

		str	r7, [r0, #0x30]	@ fill the TxFIFO with 0x48
		sub r5, r5, #1
		cmp r5, #-1
		bne		TRANSMIT_loop
	mov pc, lr

check_txrxfifo:
	ldr 	r2, [r0, #0x2c]	@ get Channel Status Register
	and	r2, r2, #0x8		@ get Transmit Buffer Empty bit(bit[3:3])
	cmp	r2, #0x8				@ check if TxFIFO is empty and ready to receive new data
	bne check_txrxfifo
	mov pc, lr





.data
string0:
	.byte 0x0D
	.byte 0x0A
	.ascii "-----------------------------------------------------------------------------------------------------"
	.byte 0x0D
	.byte 0x0A
	.byte 0x00
string1:
	.ascii "r0  = "
	.byte 0x00
string2:
	.ascii ", r1  = "
	.byte 0x00
string3:
	.ascii ", r2  = "
	.byte 0x00
string4:
	.ascii ", r3  = "
	.byte 0x00
string5:
	.byte 0x0D
	.byte 0x0A
	.ascii "r4  = "
	.byte 0x00
string6:
	.ascii ", r5  = "
	.byte 0x00
string7:
	.ascii ", r6  = "
	.byte 0x00
string8:
	.ascii ", r7  = "
	.byte 0x00
string9:
	.byte 0x0D
	.byte 0x0A
	.ascii "r8  = "
	.byte 0x00
string10:
	.ascii ", r9  = "
	.byte 0x00
string11:
	.ascii ", r10 = "
	.byte 0x00
string12:
	.ascii ", r11 = "
	.byte 0x00
string13:
	.byte 0x0D
	.byte 0x0A
	.ascii "r12 = "
	.byte 0x00
string14:
	.ascii ", r13 = "
	.byte 0x00
string15:
	.ascii ", r14 = "
	.byte 0x00
string16:
	.ascii ", r15 = "
	.byte 0x00
string17:
	.byte 0x0D
	.byte 0x0A
	.ascii "cpsr = "
	.byte 0x00
string18:
	.ascii ", "
	.byte 0x00
string19:
	.ascii ", current mode = "
	.byte 0x00
string20:
	.ascii " ( ="
	.byte 0x00
string21:
	.ascii ")"
	.byte 0x0D
	.byte 0x0A
	.ascii "----------------------------------------------------------------------------------------"
	.byte 0x0D
	.byte 0x0A
	.byte 0x00

stringARM:
	.ascii ", ARM mode"
	.byte 0x00
stringThumb:
	.ascii ", Thumb mode"
	.byte 0x00
stringJazelle:
	.ascii ", Jazelle mode"
	.byte 0x00
stringThumbEE:
	.ascii ", ThumbEE mode"
	.byte 0x00

stringUSR:
	.ascii "USR"
	.byte 0x00
stringFIQ:
	.ascii "FIQ"
	.byte 0x00
stringIRQ:
	.ascii "IRQ"
	.byte 0x00
stringSVC:
	.ascii "SVC"
	.byte 0x00
stringMON:
	.ascii "MON"
	.byte 0x00
stringABT:
	.ascii "ABT"
	.byte 0x00
stringUND:
	.ascii "UND"
	.byte 0x00
stringHYP:
	.ascii "HYP"
	.byte 0x00
stringSYS:
	.ascii "SYS"
	.byte 0x00


.text
