ORG 0
BITS 16

; Bios parameter block, prevented from being overwritten by BIOS
_start:
    jmp short start
    nop
times 33 db 0 ; padding the bios parameter block


start:
    jmp 0x7C0: step2 ; Set code segment to 0x7C0

handle_zero:
    mov ah, 0xe
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

handle_one:
    mov ah, 0xe
    mov al, 'B'
    mov bx, 0x00
    int 0x10
    iret

step2:
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
    
    ; Set up interrupt vector 0 to our handler, use ss instead of ds because ss points to 0x00
    mov word[ss:0x00], handle_zero  ; offset
    mov word[ss:0x02], 0x7c0    ; segment
    ; Set up interrupt vector 1 to our handler
    mov word[ss:0x04], handle_one   ; offset
    mov word[ss:0x06], 0x7c0    ; segment
    
    int 0
    int 1

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