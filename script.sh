# assemble to binary (not object file)
nasm -f bin boot.asm -o boot.bin
# disassemble binary
ndisasm boot.bin 
# run in qemu
qemu-system-x86_64 -hda ./boot.bin
# or for gdb debugging
target remote | qemu-system-x86_64 -hda ./boot.bin -S -gdb stdio