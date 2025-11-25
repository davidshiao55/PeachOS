#include "idt.h"
#include "config.h"
#include "io/io.h"
#include "kernel.h"
#include "memory/memory.h"

struct idt_descr idt_descriptors[PEACHOS_TOTAL_INTERRUPTS];
struct idtr_descr idtr_descriptor;

extern void int21h();
extern void no_interrupt();
extern void idt_load(struct idtr_descr *ptr);

void no_interrupt_handler()
{
    outb(0x20, 0x20); // Send acknowledgment to the PIC
}

void int21h_handler()
{
    print("Keyboard interrupt received!\n");
    outb(0x20, 0x20); // Send acknowledgment to the PIC
}

void idt_zero()
{
    print("Divide by zero error\n");
}

void idt_set(int interrupt_no, void *address)
{
    struct idt_descr *desc = &idt_descriptors[interrupt_no];
    desc->offset_1 = (uint32_t)address & 0x0000FFFF;
    desc->selector = KERNEL_CODE_SELECTOR;
    desc->zero = 0x00;
    desc->type_attr = 0xEE;
    desc->offset_2 = (uint32_t)address >> 16;
}

void idt_init()
{
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t)idt_descriptors;

    for (int i = 0; i < PEACHOS_TOTAL_INTERRUPTS; i++) {
        idt_set(i, no_interrupt);
    }

    idt_set(0, idt_zero);
    idt_set(0x21, int21h);

    // Load the interrupt descriptor table
    idt_load(&idtr_descriptor);
}