section .asm

extern int21h_handler
extern no_interrupt_handler
extern isr80h_handler
extern interrupt_handler

global idt_load
global no_interrupt
global enable_interrupts
global disable_interrupts
global isr80h_wrapper
global interrupt_pointer_table

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

; Dummy handler for unused interrupts, to avoid system crashes
no_interrupt:
    pushad ; Save all general-purpose registers
    call no_interrupt_handler
    popad ; Restore all general-purpose registers
    iret

%macro interrupt 1
    global int%1
    int%1:
        ; Interrupt frame start
        ; Already pushed to us by the processor upon entry to this interrupt
        ; uint32_t ip;
        ; uint32_t cs;
        ; uint32_t flags;
        ; uint32_t sp;
        ; uint32_t ss;
        pushad ; Pushes the General purpose registers to the stack
        ;Interrupt frame end
        push esp
        push dword %1 ; Pushes the interrupt number
        call interrupt_handler
        add esp, 8
        popad
        iret
%endmacro

; Loop through and create interrupt
%assign i 0
%rep 512
    interrupt i
%assign i i+1
%endrep

isr80h_wrapper:
    ; Interrupt frame start
    ; Already pushed to us by the processor upon entry to this interrupt
    ; uint32_t ip;
    ; uint32_t cs;
    ; uint32_t flags;
    ; uint32_t sp;
    ; uint32_t ss;
    pushad ; Pushes the General purpose registers to the stack

    ;Interrupt frame end

    ; Pus the stack pointer so that we are pointing to the interrupt frame
    push esp

    push eax ; Eax holds our command, push it to the stack for isr80h_handler
    call isr80h_handler
    mov dword[tmp_res], eax
    add esp, 8

    ; Restore general purpose registers for user land 
    popad
    mov eax, [tmp_res]
    iretd

section .data

; Inside here is stored the return result from isr80h_handler
tmp_res: dd 0

%macro interrupt_array_entry 1
    dd int%1
%endmacro

interrupt_pointer_table:
; Loop through and fill in the table with address of the interrupt
%assign i 0
%rep 512
    interrupt_array_entry i
%assign i i+1
%endrep
