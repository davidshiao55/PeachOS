section .asm

extern int21h_handler
extern no_interrupt_handler

global idt_load
global int21h
global no_interrupt
global enable_interrupts
global disable_interrupts

enable_interrupts:
    sti
    ret

disable_interrupts:
    cli
    ret

idt_load:
    push ebp
    mov ebp, esp

    mov ebx, [ebp + 8]
    lidt [ebx]

    pop ebp
    ret

int21h:
    cli ; Disable interrupts to avoid nested interrupts
    pushad ; Save all general-purpose registers
    call int21h_handler
    popad ; Restore all general-purpose registers
    sti
    iret

; Dummy handler for unused interrupts, to avoid system crashes
no_interrupt:
    cli ; Disable interrupts to avoid nested interrupts
    pushad ; Save all general-purpose registers
    call no_interrupt_handler
    popad ; Restore all general-purpose registers
    sti
    iret
