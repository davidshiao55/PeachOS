#include "kernel.h"
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include <stddef.h>
#include <stdint.h>

uint16_t *video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_makechar(char c, char colour)
{
    return c | (colour << 8); // endianness
}

void terminal_putchar(int x, int y, char c, char colour)
{
    video_mem[y * VGA_WIDTH + x] = terminal_makechar(c, colour);
}

void terminal_writechar(char c, char colour)
{
    if (c == '\n') {
        terminal_col = 0;
        terminal_row++;
        return;
    }
    terminal_putchar(terminal_col, terminal_row, c, colour);
    terminal_col++;
    if (terminal_col >= VGA_WIDTH) {
        terminal_col = 0;
        terminal_row++;
    }
}

void terminal_initialize()
{
    video_mem = (uint16_t *)0xB8000;
    for (int y = 0; y < VGA_HEIGHT; y++) {
        for (int x = 0; x < VGA_WIDTH; x++) {
            terminal_putchar(x, y, ' ', 0);
        }
    }
}

size_t strlen(const char *str)
{
    size_t len = 0;
    while (str[len])
        len++;
    return len;
}

void print(const char *str)
{
    for (int i = 0; i < strlen(str); i++) {
        terminal_writechar(str[i], 0x0F);
    }
}

void kernel_main()
{
    terminal_initialize();
    print("Hello, World!\n");

    // Initialize the heap
    kheap_init();

    // Initialize the IDT
    idt_init();

    // Enable interrupts. Only after IDT is initialized, or system may crash
    enable_interrupts();

    void *ptr = kmalloc(50);
    void *ptr2 = kmalloc(5000);
    void *ptr3 = kmalloc(5600);
    kfree(ptr);
    void *ptr4 = kmalloc(50);
    if (ptr || ptr2 || ptr3 || ptr4) {
    }
}