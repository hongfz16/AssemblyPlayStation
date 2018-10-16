# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile
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

clean:
	rm *.bin
