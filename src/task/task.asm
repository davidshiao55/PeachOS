[BITS 32]

section .asm
global restore_general_purpose_registers
global task_return
global user_registers

;void task_return(struct registers *regs);
task_return:
    mov ebp, esp
    ; Push the data segment 
    ; Push the stack address
    ; Push the flags
    ; Push the code segment
    ; Push the ip

    mov ebx, [ebp + 4]
    ; Push the data/stack selector
    push dword [ebx + 44]
    ; Push the flags
    push dword [ebx + 40]
    ; Push the flags
    pushf
    pop eax
    ; Or the flag, enable interrupt when iret
    or eax, 0x200
    push eax
    ; Push the code segment
    push dword [ebx + 32]
    ; Push the ip to execute
    push dword [ebx + 28]
    ; Setup some segment registers
    mov ax, [ebx + 44]
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push dword [ebx + 4]
    call restore_general_purpose_registers
    add esp, 4
    ; Leave kernel land and execute in user land
    iretd

; void restore_general_purpose_registers(struct registers *regs);
restore_general_purpose_registers:
    push ebp
    mov ebp, esp
    mov ebx, [ebp + 8]
    mov edi, [ebx]
    mov esi, [ebx + 4]
    mov ebp, [ebx + 8]
    mov edx, [ebx + 16]
    mov ecx, [ebx + 20]
    mov eax, [ebx + 24]
    mov ebx, [ebx + 12]
    pop esp
    pop ebp
    ret

; void user_registers();
user_registers:
    mov ax, 0x23
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    ret
