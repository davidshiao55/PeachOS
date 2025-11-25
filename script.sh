# assemble to binary (not object file)
nasm -f bin src/boot/boot.asm -o bin/boot.bin
# disassemble binary
ndisasm bin/boot.bin 
# run in qemu
qemu-system-x86_64 -hda bin/os.bin
# or for gdb debugging
target remote | qemu-system-x86_64 -hda bin/boot.bin -S -gdb stdio
# cross compile dependency installation (for ubuntu)
sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev 
# link kernel full for gdb debugging
add-symbol-file build/kernelfull.o 0x100000
target remote | qemu-system-x86_64 -hda bin/os.bin -S -gdb stdio
# debugging 32 bit kernel in gdb
target remote | qemu-system-i386 -hda ./bin/os.bin -S -gdb stdio