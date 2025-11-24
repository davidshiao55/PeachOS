FILES = ./build/kernel.asm.o

all: ./bin/boot.bin ./bin/kernel.bin
	dd if=./bin/boot.bin > ./bin/os.bin # bootloader in the first sector
	dd if=./bin/kernel.bin >> ./bin/os.bin	# kernel after bootloader
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin # pad the rest with zeros

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./build/kernel.asm.o: ./src/kernel.asm
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o
clean:
	rm ./bin/boot.bin ./bin/kernel.bin ./bin/os.bin ./build/kernelfull.o $(FILES)