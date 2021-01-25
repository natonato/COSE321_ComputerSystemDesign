#include "uart_init.s"
#include "uart_regs.h"
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
	uart_init
	ldr r4, =UART1_BASE+UART_TX_RX_FIFO0_OFFSET
	ldr r5, =UART1_BASE+UART_CHANNEL_STS_REG0_OFFSET
	loop:

		bl csd_main // c »£√‚
		ldr r6, [r5]
		and r6, r6, #8
		cmp r6, #8
		streq r0, [r4]
		b loop


//.data
//.align 4



/*dst:
	.space 16  // allocate memory for 16 words*/


// Normal Interrupt Service Routine
csd_irq:
	b .
