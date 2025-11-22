ORG 0x7c00
BITS 16

start:
    mov si, message
    call print
    jmp $   ; infinite loop

print:
    mov bx, 0
.loop:
    lodsb   ; load byte at SI into AL and increment SI
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0x0e
    int 0x10    ;   invoke BIOS teletype function
    ret

message: db 'Hello World!', 0   ; null-terminated string

times 510-($-$$) db 0 ; pad zero till 510 bytes
dw 0xAA55 ; little-endian boot signature 55AA