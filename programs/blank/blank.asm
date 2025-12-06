[BITS 32]
section .asm
global _start

_start:
_loop:
    call getkey ; Wait for keypresh and output a message
    push eax
    mov eax, 3  ; Command put char
    int 0x80
    add esp, 4

    jmp _loop

getkey:
    mov eax, 2  ; Command getkey
    int 0x80
    cmp eax, 0x00
    je getkey
    ret

section .data
message: db 'I can talk with the kerenl!', 0