[bits 32]
section .text
call main
ret

VIDEO_MEMORY equ 0xb8000

print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY

print_string_pm_loop:
    mov al, [ebx] ; [ebx] is the address of our character
    mov ah, WHITE_ON_BLACK

    cmp al, 0 ; check if end of string
    je print_string_pm_done

    mov [edx], ax ; store character + attribute in video memory
    add ebx, 1 ; next char
    add edx, 2 ; next video memory position

    jmp print_string_pm_loop

print_string_pm_done:
    popa
    ret

%include "./utils/vga_driver.asm"

main:
	mov eax, MSG
	mov ebx, eax
	call print_string_pm

    push 5
    push 20
    mov eax, MSG
    push eax
    call kprint_at

    ret

MSG db "msg from kernel 111111", 0
times 512 - ($-$$) db 0
finish1: