#include "csd_zynq_peripherals.h"
#include "uart_regs.h"
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
	b csd_irq
	b .

.global main
main:

	// Disable interrupt: Turn on I bit in CPSR
    cpsID i

	cps #0x12	   	       /* IRQ mode */
	ldr	r13,=irq_stack_top /* stack pointer setup for IRQ mode */

    cps #0x11		       /* FIQ mode */
	ldr	r13,=fiq_stack_top /* stack pointer setup for FIQ mode */

	cps #0x13		       /* supervisor mode */
	ldr	r13,=svc_stack_top /* stack pointer setup for SVC mode */

	// Set VBAR (Vector Base Address Register) to the base of my interrupt vector table
    ldr     r0, =csd_entry
    mcr     p15, 0, r0, c12, c0, 0
    dsb
    isb



// ---------------------------
// Generic Interrupt Controller (GIC) setup - Begin
//

	// CPU Interface ID Register
	ldr r0, =GICC_IIDR
	ldr r3, [r0]

	// CPU Controller Type Register
	ldr r0, =GICD_TYPER
	ldr r3, [r0]

	// CPU Binary Pointer Register
	ldr r0, =GICC_BPR
	ldr r3, [r0]

	// Distributor Control Register
	ldr r0, =GICD_CTLR
	ldr r1, [r0]
	mov r2, #1       // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	 // Interrupt Set-Enable Register 0
	ldr r0, =GICD_ISENABLER0
	ldr r1, [r0]
	mov r2, #1 << 29   // Enable #29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// Interrupt Priority Register #7
	// According to specifications,
	// Cortex-A9 supports 5-bit version of priority format [7:3] in secure world
	// ( 0 -> 8 -> 16 -> 24...)
	ldr r0, =GICD_PRIOR7
	ldr r1, [r0]
	mov r2, #0x10 << 8    // Priority 16 for ID# 29 (Private Timer)
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

	// CPU Interface Control Register
	ldr r0, =GICC_CTLR
	ldr r1, [r0]
	mov r2, #1        // Enable
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]

 	// CPU Interface Interrupt Priority Mask Register
	ldr r0, =GICC_PMR
	ldr r1, [r0]
	mov r2, #0xFF     // Lowest
	orr r1, r1, r2
	str r1, [r0]
	ldr r3, [r0]



//
// Generic Interrupt Controller (GIC) setup - End
// ---------------------------


// ---------------------------
// Private Timer setup - Begin
//

 	// Private Timer Load Register
	ldr r0, =PRIVATE_LOAD
 	ldr r1, =#333332 // PERIPHCLK는 대략 333333000, Prescalar = 0, time interval을 1미리초 로 만들려면 (Prescalar+1) * (r1+1) = 0.001 * PERIPHCLK. 여기서 r1를 구하면 333332
 	str r1, [r0]

 	// Private Timer Control Register
  	ldr r0, =PRIVATE_CONTROL
 	mov r1, #0 << 8   // Prescalar
 	orr r1, r1, #7     // IRQ Enable, Auto-Reload, Timer Enable
 	str r1, [r0]

//
// Private Timer setup - End
// ----------------------------

// ---------------------------
// UART setup - Begin
//

	ldr		r0, =UART1_BASE

	mov		r1, #0x00000020
	str		r1, [r0, #UART_MODE_REG0_OFFSET]

	ldr		r1, [r0, #UART_CONTROL_REG0_OFFSET]	@ read uart.Control_reg0
	bic		r1, r1, #0x0000003C					@ clear TXDIS, TXEN, RXDIS, RXEN (bit[5][4][3][2])
	orr		r1, r1, #0x00000028					@ TXDIS = 1 TXEN = 0 RXDIS = 1 RXEN = 0 (bit[5][4][3][2])
	str		r1, [r0, #UART_CONTROL_REG0_OFFSET]	@ update
	mov		r1, #0x0000003E								@ CD = 62 (Baud rate 115200)
	str		r1, [r0, #UART_BAUD_RATE_GEN_REG0_OFFSET]	@ update uart.Baud_rate_gen_reg0
	mov		r1, #0x00000006								@ BDIV = 6 (Baud rate 115200)
	str		r1, [r0, #UART_BAUD_RATE_DIV_REG0_OFFSET]	@ update uart.Baud_rate_divider_reg0 @ strb	r1, [r0, #UART_BAUD_RATE_DIV_REG0_OFFSET]

	ldr		r1, [r0, #UART_CONTROL_REG0_OFFSET]	@ read uart.Control_reg0
	orr		r1, r1, #0x00000003					@ set TXRST, RXRST (bit[1][0]:self-clearing) - this resets Tx and Rx paths
	str		r1, [r0, #UART_CONTROL_REG0_OFFSET]	@ update

	ldr		r1, [r0, #UART_CONTROL_REG0_OFFSET]	@ read uart.Control_reg0
	bic		r1, r1, #0x0000003C					@ clear TXDIS, TXEN, RXDIS, RXEN (bit[5][4][3][2])
	orr		r1, r1, #0x00000014					@ TXDIS = 0 TXEN = 1 RXDIS = 0 RXEN = 1 (bit[5][4][3][2])
	str		r1, [r0, #UART_CONTROL_REG0_OFFSET]	@ update

	ldr		r1, =0x00000117						@ write 0x00000117 to uart.Control_reg0
	str		r1, [r0, #UART_CONTROL_REG0_OFFSET]	@ update



//
// UART setup - End
// ---------------------------



// ---------------------------
// TCB, stack setup for task1
	ldr r13, =tcb_task1_pointer
	sub r13, #8
	mrs r0, cpsr
	ldr r1, =#0xFFFFFF70
	and r0, r1 // mode bit가 13(svc)이니 10(usr)로 변경해주고, i비트도 1이니 0으로 변경해준다.
	stm r13!, {r0}
	ldr r0, =task1_c
	add r0, #4
	stm r13!, {r0}
	add r13, #52
	ldr r0, =task1_stack_top
	stm r13!, {r0} // TCB에 task_stack을 저장
	ldr r0, =task1_c
	add r0, #4
	stm r13!, {r0}

// ---------------------------
// TCB, stack setup for task2
	ldr r13, =tcb_task2_pointer
	sub r13, #8
	mrs r0, cpsr
	ldr r1, =#0xFFFFFF70
	and r0, r1 // mode bit가 13(svc)이니 10(usr)로 변경해주고, i비트도 1이니 0으로 변경해준다.
	stm r13!, {r0}
	ldr r0, =task2_c
	add r0, #4
	stm r13!, {r0}
	add r13, #52
	ldr r0, =task2_stack_top
	stm r13!, {r0} // TCB에 task_stack을 저장
	ldr r0, =task2_c
	add r0, #4
	stm r13!, {r0}

// ---------------------------
// TCB, stack setup for task3
	ldr r13, =tcb_task3_pointer
	sub r13, #8
	mrs r0, cpsr
	ldr r1, =#0xFFFFFF70
	and r0, r1 // mode bit가 13(svc)이니 10(usr)로 변경해주고, i비트도 1이니 0으로 변경해준다.
	stm r13!, {r0}
	ldr r0, =task3_c
	add r0, #4
	stm r13!, {r0}
	add r13, #52
	ldr r0, =task3_stack_top
	stm r13!, {r0} // TCB에 task_stack을 저장
	ldr r0, =task3_c
	add r0, #4
	stm r13!, {r0}

// ---------------------------
// next process ssetup
	ldr r13, =next_process_top
	sub r13, #12
	ldr r0, =tcb_task3_pointer
	ldr r1, =tcb_task2_pointer
	ldr r2, =tcb_task1_pointer
	stm r13, {r0-r2} // 위에서부터 1,2,3순서로 초기화.


	// Enable interrupt: Turn off I bit in CPSR
	cpsIE i

	cps #0x10 // usr 모드 진입.
	ldr r13,=task1_stack_top // task 1 스택 top 설정
	b task1_c // 첫 프로세스는 task1으로







csd_software_interrupt:
csd_reset:
csd_undefined:
csd_prefetch:
csd_data:
csd_not_used:
csd_irq:


	stmfd sp, {r0-r12, lr}^ // 현재 reg 저장

	ldr r0, =GICC_IAR
	ldr r5, [r0] // IAR에서 interrupt 정보 load




	ldr r3, =GICC_EOIR
	str r5, [r3] // EOIR에 interrupt 정보 store
	ldr r3, =PRIVATE_STATUS
	mov r4, #1
	str r4, [r3] // 타이머 초기화


	cmp r5, #29
	ldmnefd sp, {r0-r12, lr}^
	subnes pc, lr, #4 // interrupt가 timer interrupt가 아니라면 기존 register 복원 후 별도의 처리 없이 돌아간다.


	ldr r13, =irq_stack_top
	sub r13, #56
	ldmfd sp, {r0-r12, lr}^ // irq 진입시 저장한 usr모드 register들 복원


	ldr	r13,=next_process_top
	sub r13, #4
	ldr r13, [r13] // 다음 process가 뭘지 가져옴.

	stm r13, {r0-lr}^
	mrs r0, spsr
	stmdb r13, {r0, lr} // 기존 processor의 register tcb에 저장

	ldr	r13,=next_process_top
	sub r13, #4
	ldr r0, [r13] // 다음 process가 뭘지 가져옴.

	ldmdb r13!, {r1-r2}
	stmia r13!, {r0}
	stmia r13!, {r1-r2}

	sub r13, #4
	ldr r13, [r13] // 다음 process가 뭘지 가져옴.
	ldmdb r13, {r0, lr}
	msr spsr, r0
	ldm r13, {r0-lr}^ // 다음 processor의 register tcb로부터 복원


	ldr r13, =irq_stack_top // irq sp로 복원

	subs pc, lr, #4

csd_fiq:
	b .




.data
.align 4

irq_stack:     .space 1024
irq_stack_top:
fiq_stack:     .space 1024
fiq_stack_top:
svc_stack:     .space 1024
svc_stack_top:
task1_stack:     .space 1024
task1_stack_top:
task2_stack:     .space 1024
task2_stack_top:
task3_stack:     .space 1024
task3_stack_top:
next_process:	.space 12
next_process_top:

tcb_task1: .space 8
tcb_task1_pointer: .space 60

tcb_task2: .space 8
tcb_task2_pointer:
.space 60

tcb_task3: .space 8
tcb_task3_pointer:
.space 60


led_initial: .word 0x07
