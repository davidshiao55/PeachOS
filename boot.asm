ORG 0
BITS 16

jmp 0x7C0: start ; Set code segment to 0x7C0

start:
    cli ; Disable Interrupts for critical setup
    ; manually set up segment registers, incase BIOS set them differently the code won't work as expected
    mov ax, 0x07C0  ; Can't directly move to segment registers
    mov ds, ax
    mov es, ax
    ; Stack is just below the bootloader and grows downwards to 0x0000
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7C00 
    sti ; Enables Interrupts
    mov si, message
    call print
    jmp $   ; infinite loop

print:
    mov bx, 0
.loop:
    lodsb   ; load byte at DS:SI into AL and increment SI -> ds(0x7C0) * 16 + offset
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