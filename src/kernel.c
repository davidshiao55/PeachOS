#include "kernel.h"
#include "disk/disk.h"
#include "disk/streamer.h"
#include "fs/file.h"
#include "fs/pparser.h"
#include "idt/idt.h"
#include "io/io.h"
#include "memory/heap/kheap.h"
#include "memory/paging/paging.h"
#include "string/string.h"
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

void print(const char *str)
{
    for (int i = 0; i < strlen(str); i++) {
        terminal_writechar(str[i], 0x0F);
    }
}

static struct paging_4gb_chunk *kernel_chunk = 0;

void kernel_main()
{
    terminal_initialize();
    print("Hello, World!\n");

    // Initialize the heap
    kheap_init();

    // Initialize the filesystem
    fs_init();

    // Search and Initialize the disk
    disk_search_and_init();

    // Initialize the IDT
    idt_init();

    // Setup paging
    kernel_chunk = paging_new_4gb(PAGING_IS_WRITABLE | PAGING_IS_PRESENT | PAGING_ACCESS_FROM_ALL);

    // Switch to kernel paging chunk
    paging_switch(paging_4gb_chunk_get_directory(kernel_chunk));

    // Enable paging
    enable_paging();

    // Enable interrupts. Only after IDT is initialized and paging is enable, or system may crash
    enable_interrupts();

    char buf[20];
    strcpy(buf, "hello world");
    print(buf);
}