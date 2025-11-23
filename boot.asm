ORG 0
BITS 16

; Bios parameter block, prevented from being overwritten by BIOS
_start:
    jmp short start
    nop
times 33 db 0 ; padding the bios parameter block


start:
    jmp 0x7C0: step2 ; Set code segment to 0x7C0

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

    mov ah, 2 ; Read sector command
    mov al, 1 ; One sector to read
    mov ch, 0 ; Cylinder low eight bits
    mov cl, 2 ; Read sector 2
    mov dh, 0 ; Head number
    mov bx, buffer ; Buffer to store the read data
    int 0x13 ; BIOS disk interrupt
    jc error ; Jump if carry flag is set (error)
    
    mov si, buffer
    call print
    jmp $ ; Infinite loop

error:
    mov si, error_message
    call print
    jmp $   

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

error_message: db "Failed to load sector!", 0

times 510-($-$$) db 0 ; pad zero till 510 bytes
dw 0xAA55 ; little-endian boot signature 55AA

buffer: