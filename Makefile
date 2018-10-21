# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile
$(info VAR=$(shell uname))
ifeq ($(shell uname), Linux)
GDB = gdb # /usr/local/i386elfgcc/bin/i386-elf-gdb
LD = ld -m elf_i386
else
GDB = /usr/local/i386elfgcc/bin/i386-elf-gdb
LD = i386-elf-ld
endif

all: run

kernel1.bin: kernel1.asm
	nasm $< -f bin -o $@

kernel2.bin: kernel2.asm
	nasm $< -f bin -o $@

dinosaur.bin: dinosaur.asm
	nasm $< -f bin -o $@

bootsect.bin: bootsect.asm
	nasm $< -f bin -o $@

os-image.bin: bootsect.bin kernel1.bin kernel2.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

%.o: %.asm
	nasm $< -f elf -o $@

run-debug: bootsect.bin kernel1.o kernel2.o dinosaur.o
	$(LD) -o kernel.bin -Ttext 0x1000 kernel1.o kernel2.o dinosaur.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -fda os-image-debug.bin

debug: bootsect.bin kernel1.o kernel2.o dinosaur.o
	$(LD) -o kernel.elf -Ttext 0x1000 kernel1.o kernel2.o dinosaur.o
	$(LD) -o kernel.bin -Ttext 0x1000 kernel1.o kernel2.o dinosaur.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -s -fda os-image-debug.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

clean:
	rm *.bin *.o *.elf
