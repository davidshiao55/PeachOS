# PeachOS

PeachOS is a 32-bit monolithic kernel operating system written in C and x86 Assembly.

> **Attribution:** This project is being developed by following the course **"Developing a Multithreaded Kernel from Scratch"** available at [https://github.com/nibblebits/PeachOS](https://github.com/nibblebits/PeachOS). 

## Features
  * **Architecture**: x86 (32-bit Protected Mode).
  * **Bootloader**: Custom 16-bit real-mode bootloader that sets up the GDT and switches to 32-bit protected mode.
  * **Memory Management**:
      * Paging (Virtual Memory).
      * Kernel Heap implementation (`kmalloc`/`kfree`).
  * **File System**:
      * **FAT16 Driver**: Full implementation of the FAT16 filesystem.
      * **Virtual File System (VFS)**: An abstraction layer that allows the kernel to handle different filesystems uniformly.
  * **Input Subsystem**:
      * **Virtual Keyboard Layer**: An abstraction layer that manages keyboard buffers and supports multiple keyboard drivers.
      * PS/2 Keyboard driver implementation.
  * **Multitasking**:
      * Process loading and execution.
      * Task State Segment (TSS) support.
      * Context switching.
      * Ring 3 (User Mode) support.
  * **Interrupts**:
      * Interrupt Descriptor Table (IDT) setup.
      * Programmable Interrupt Controller (PIC) remapping.
      * System Calls (via `int 0x80`).
  * **Drivers**:
      * VGA Text Mode driver.
      * ATA/LBA Disk driver.