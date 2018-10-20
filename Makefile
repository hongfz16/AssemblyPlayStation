# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile
GDB = gdb
LD = ld -m elf_i386
CC = gcc
NASM = nasm

all: run

kernel1.bin: kernel1.asm
	${NASM} $< -f bin -o $@

kernel2.bin: kernel2.asm
	${NASM} $< -f bin -o $@

bootsect.bin: bootsect.asm
	${NASM} $< -f bin -o $@

os-image.bin: bootsect.bin kernel1.bin kernel2.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

%.o: %.asm
	${NASM} $< -f elf -o $@

run-debug: bootsect.bin kernel1.o kernel2.o
	${LD}  -o kernel.bin -Ttext 0x1000 kernel1.o kernel2.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -fda os-image-debug.bin

debug: bootsect.bin kernel1.o kernel2.o
	${LD} -o kernel.elf -Ttext 0x1000 kernel1.o kernel2.o
	${LD} -o kernel.bin -Ttext 0x1000 kernel1.o kernel2.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -s -fda os-image-debug.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

clean:
	rm *.bin *.o *.elf
