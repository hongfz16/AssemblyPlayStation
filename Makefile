# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile

$(info VAR=$(shell uname))
ifeq ($(shell uname), Linux)
GDB = gdb # /usr/local/i386elfgcc/bin/i386-elf-gdb
LD = ld -m elf_i386
NASM = nasm
else
GDB = /usr/local/i386elfgcc/bin/i386-elf-gdb
LD = i386-elf-ld
NASM = nasm
endif

bootsect.bin: bootsect.asm
	${NASM} $< -f bin -o $@

%.o: %.asm
	${NASM} $< -f elf -o $@

itoa.o: utils/itoa.asm
	${NASM} $< -f elf -o $@

random.o: utils/random.asm
	${NASM} $< -f elf -o $@

vga_driver.o: utils/vga_driver.asm
	${NASM} $< -f elf -o $@

get_time.o: utils/get_time.asm
	${NASM} $< -f elf -o $@

run-debug: bootsect.bin main.o menu.o clock.o dinasour.o stopwatch.o itoa.o random.o vga_driver.o get_time.o
	${LD} -o kernel.bin -Ttext 0x1000 main.o menu.o clock.o dinasour.o stopwatch.o itoa.o random.o vga_driver.o get_time.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -fda os-image-debug.bin

debug: bootsect.bin main.o menu.o clock.o dinasour.o stopwatch.o itoa.o random.o vga_driver.o get_time.o
	${LD} -o kernel.elf -Ttext 0x1000 main.o menu.o clock.o dinasour.o stopwatch.o itoa.o random.o vga_driver.o get_time.o
	${LD} -o kernel.bin -Ttext 0x1000 main.o menu.o clock.o dinasour.o stopwatch.o itoa.o random.o vga_driver.o get_time.o --oformat binary
	cat bootsect.bin kernel.bin > os-image-debug.bin
	qemu-system-i386 -s -fda os-image-debug.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

clean:
	rm *.bin *.o *.elf
