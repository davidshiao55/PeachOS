ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; Bios parameter block, prevented from being overwritten by BIOS
_start:
    jmp short start
    nop
times 33 db 0 ; padding the bios parameter block


start:
    jmp 0: step2

step2:
    cli ; Disable Interrupts for critical setup
    ; manually set up segment registers, incase BIOS set them differently the code won't work as expected
    mov ax, 0x00  ; Can't directly move to segment registers
    mov ds, ax
    mov es, ax
    ; Stack is just below the bootloader and grows downwards to 0x0000
    mov ss, ax
    mov sp, 0x7C00 
    sti ; Enables Interrupts

.load_protected:
    cli
    lgdt [gdt_descriptor] ; Load GDT register with start address of Global Descriptor Table
    mov eax, cr0
    or eax, 0x1 ; Set the PE (Protection Enable) bit in CR0 to enable protected mode
    mov cr0, eax
    jmp CODE_SEG:load32


; GDT description structure
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x08
gdt_code:   ; CS should point to this
    dw 0xFFFF  ; Segment limit first 0-15bit
    dw 0x0000  ; Base address first 0-15bit
    db 0x00    ; Base address 16-23bit
    db 0x9A    ; Access byte
    db 0b11001111 ; High 4 bit flags and the low 4 bit flags
    db 0x00    ; Base address 24-31bit

; offset 0x10
gdt_data:   ; DS, SS, ES, FS, GS
    dw 0xFFFF  ; Segment limit first 0-15bit
    dw 0x0000  ; Base address first 0-15bit
    db 0x00    ; Base address 16-23bit
    db 0x92    ; Access byte
    db 0b11001111 ; High 4 bit flags and the low 4 bit flags
    db 0x00    ; Base address 24-31bit

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size of GDT -1
    dd gdt_start               ; address of GDT

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $

times 510-($-$$) db 0 ; pad zero till 510 bytes
dw 0xAA55 ; little-endian boot signature 55AA