#ifndef IDT_H
#define IDT_H

#include <stdint.h>

struct idt_descr {
    uint16_t offset_1; // offset bits 0..15
    uint16_t selector; // a code segment selector in GDT
    uint8_t zero;      // unused, set to 0
    uint8_t type_attr; // Descriptor type and attributes
    uint16_t offset_2; // offset bits 16..31
} __attribute__((packed));

struct idtr_descr {
    uint16_t limit; // Size of descriptor table - 1
    uint32_t base;  // Address of the first element
} __attribute__((packed));

void idt_init();
#endif