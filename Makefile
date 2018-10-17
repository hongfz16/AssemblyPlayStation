# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile
GDB = /usr/local/i386elfgcc/bin/i386-elf-gdb

all: run

kernel1.bin: kernel1.asm
	nasm $< -f bin -o $@

kernel2.bin: kernel2.asm
	nasm $< -f bin -o $@

bootsect.bin: bootsect.asm
	nasm $< -f bin -o $@

os-image.bin: bootsect.bin kernel1.bin kernel2.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

%.o: %.asm
	nasm $< -f elf -o $@

run-debug: bootsect.bin kernel1.o kernel2.o
	i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel1.o kernel2.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -fda os-image-debug.bin

debug: bootsect.bin kernel1.o kernel2.o
	i386-elf-ld -o kernel.elf -Ttext 0x1000 kernel1.o kernel2.o
	i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel1.o kernel2.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -s -fda os-image-debug.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

clean:
	rm *.bin *.o *.elf
