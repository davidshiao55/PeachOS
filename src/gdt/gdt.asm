section .asm
global gdt_load

gdt_load:
    mov eax, [esp + 4]  ; Store address of GDT in eax
    mov [gdt_descriptor + 2], eax ; Write address of GDT to memory address of gdt_descriptor + 2
    mov ax, [esp + 8]   ; Store size in ax
    mov [gdt_descriptor], ax    ; Write size to memory address of gdt_descriptor
    lgdt [gdt_descriptor]
    ret

section .data
gdt_descriptor:
    dw 0x00 ; Size
    dd 0x00 ; GDT start address