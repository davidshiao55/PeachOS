#include "idt.h"
#include "config.h"
#include "io/io.h"
#include "kernel.h"
#include "memory/memory.h"
#include "status.h"
#include "task/task.h"

struct idt_descr idt_descriptors[PEACHOS_TOTAL_INTERRUPTS];
struct idtr_descr idtr_descriptor;

// Will be fill in by the assembly
extern void *interrupt_pointer_table[PEACHOS_TOTAL_INTERRUPTS];

static INTERRUPT_CALLBACK_FUNCTION interrupt_callbacks[PEACHOS_TOTAL_INTERRUPTS];
static ISR80H_COMMAND isr80h_commands[PEACHOS_MAX_ISR80H_COMMANDS];
extern void int21h();
extern void no_interrupt();
extern void idt_load(struct idtr_descr *ptr);
extern void isr80h_wrapper();

void no_interrupt_handler()
{
    outb(0x20, 0x20); // Send acknowledgment to the PIC
}

void interrupt_handler(int interrupt, struct interrupt_frame *frame)
{
    kernel_page();
    if (interrupt_callbacks[interrupt] != 0) {
        task_current_save_state(frame);
        interrupt_callbacks[interrupt]();
    }
    task_page();
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
        idt_set(i, interrupt_pointer_table[i]);
    }

    idt_set(0, idt_zero);
    idt_set(0x80, isr80h_wrapper);

    // Load the interrupt descriptor table
    idt_load(&idtr_descriptor);
}

int idt_register_interrupt_callback(int interrupt, INTERRUPT_CALLBACK_FUNCTION interrupt_callback)
{
    if (interrupt < 0 || interrupt >= PEACHOS_TOTAL_INTERRUPTS) {
        return -EINVARG;
    }
    interrupt_callbacks[interrupt] = interrupt_callback;
    return 0;
}

void isr80h_register_command(int command_id, ISR80H_COMMAND command)
{
    if (command_id < 0 || command_id >= PEACHOS_MAX_ISR80H_COMMANDS) {
        panic("The command is out of bounds\n");
    }

    if (isr80h_commands[command_id]) {
        panic("You are attempting to overwrite an existing command\n");
    }

    isr80h_commands[command_id] = command;
}

void *isr80h_handler_command(int command, struct interrupt_frame *frame)
{
    void *result = 0;

    // Invalid command
    if (command < 0 || command >= PEACHOS_MAX_ISR80H_COMMANDS) {
        return 0;
    }

    ISR80H_COMMAND command_func = isr80h_commands[command];
    // User call a function that doesn't exist
    if (!command_func) {
        return 0;
    }

    result = command_func(frame);
    return result;
}

void *isr80h_handler(int command, struct interrupt_frame *frame)
{
    void *res = 0;
    kernel_page();
    task_current_save_state(frame);
    res = isr80h_handler_command(command, frame);
    task_page();
    return res;
}