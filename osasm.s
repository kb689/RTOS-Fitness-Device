;/*****************************************************************************/
; OSasm.s: low-level OS commands, written in assembly                       */
; Runs on LM4F120/TM4C123/MSP432
; Lab 4 starter file
; Kirabo Nsereko
; October, 2020
;


        AREA |.text|, CODE, READONLY, ALIGN=2
        THUMB
        REQUIRE8
        PRESERVE8

        EXTERN  RunPt            ; currently running thread
        EXPORT  StartOS
        EXPORT  SysTick_Handler
        IMPORT  Scheduler


SysTick_Handler                ; 1) Saves R0-R3,R12,LR,PC,PSR
    CPSID   I                  ; 2) Prevent interrupt during switch
    PUSH    {R4-R11}           ; save values of R4-R11 onto stack
	LDR     R0, =RunPt         ; load addr of RunPt into R0
	LDR     R1, [R0]           ; R1 holds addr of running thread
	STR     SP, [R1]           ; store SP into tcb.sp
	PUSH    {R0,LR}            ; save values of R0 and LR
	BL      Scheduler	       ; branch th Scheduler function
	POP     {R0, LR}           ; load old values of R) and LR into registers
	LDR     R1, [R0]           ; R1 points to new thread
    LDR     SP, [R1]           ; load SP with addr of top of stack
    POP     {R4-R11}           ; pop values into registers	R4-R11
    CPSIE   I                  ; 9) tasks run with interrupts enabled
    BX      LR                 ; 10) restore R0-R3,R12,LR,PC,PSR

StartOS
    LDR R0, =RunPt             ; load address of RunPt into R0
	LDR R1, [R0]               ; R1 points  to current thread
	LDR SP, [R1]               ; load SP with address of top stack
	POP {R4-R11}               ; pop values into R4-R11
	POP {R0-R3}                ; pop values into R0-R3
	POP {R12}                  ; pop value into R12
	ADD SP, #4                 ; discard value in LR
	POP {LR}                   ; pop value of PC into LR
	ADD SP, #4                 ; discard value in PSR
    CPSIE   I                  ; Enable interrupts at processor level
    BX      LR                 ; start first thread

    ALIGN
    END