[org 0x7c00]
KERNEL_OFFSET equ 0x1000 ; The same one we used when linking the kernel
KERNEL2_OFFSET equ 0x2000

    mov [BOOT_DRIVE], dl ; Remember that the BIOS sets us the boot drive in 'dl' on boot
    mov bp, 0x9000
    mov sp, bp

    mov bx, MSG_REAL_MODE 
    call print
    call print_nl

    call load_kernel ; read the kernel from disk
    call switch_to_pm ; disable interrupts, load GDT,  etc. Finally jumps to 'BEGIN_PM'
    jmp $ ; Never executed

%include "utils/boot_sect_print.asm"
%include "utils/boot_sect_print_hex.asm"
%include "utils/boot_sect_disk.asm"
%include "utils/32bit-gdt.asm"
%include "utils/32bit-print.asm"
%include "utils/32bit-switch.asm"

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print
    call print_nl

    mov bx, KERNEL_OFFSET ; Read from disk and store in 0x1000
    mov dh, 1
    mov cl, 2
    mov dl, [BOOT_DRIVE]
    call disk_load
    mov bx, KERNEL2_OFFSET ; Read from disk and store in 0x2000
    mov dh, 1
    mov cl, 3
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    mov eax, 0x1000
    call KERNEL_OFFSET ; Give control to the kernel
    mov eax, 0x2000
    call KERNEL2_OFFSET
    mov ebx, MSG_OUT
    call print_string_pm
    jmp $ ; Stay here when the kernel returns control to us (if ever)


BOOT_DRIVE db 0 ; It is a good idea to store it in memory because 'dl' may get overwritten
MSG_REAL_MODE db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE db "Landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0
MSG_OUT db "Returnfromkernels", 0

; padding
times 510 - ($-$$) db 0
dw 0xaa55
