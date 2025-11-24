ENTRY(_start)
OUTPUT_FORMAT("binary")
SECTIONS
{
    . = 1M; /* Load kernel at address at 1MB */
    .text :
    {
        *(.text)
    }
    .rodata :
    {
        *(.rodata)
    
    }
    .data :
    {
        *(.data)
    }
    .bss :
    {
        *(COMMON)
        *(.bss)
    }
}