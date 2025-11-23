all:
	nasm -f bin boot.asm -o boot.bin
	# add a message to the second sector and pad to 512 bytes
	dd if=message.txt >> boot.bin
	dd if=/dev/zero bs=512 count=1 >> boot.bin