[bits 32]
section .text
call main
ret

extern init_seed
extern rand_num
extern clear_screen
extern kprint
extern kprint_at
extern print_char
extern int_to_ascii
extern getchar
extern register_kbd_callback
extern register_tim_callback

kbd_handler:
    push KBD
    call kprint
    ret 4

main:
	call init_seed
	mov ecx, 10
	rand_loop:
		call rand_num
		push RANDNUM
		push eax
		call int_to_ascii
		push RANDNUM
		call kprint
		sub ecx, 1
		cmp ecx, 0
		je loop_done
		jmp rand_loop
	loop_done:

    push MSG
    call kprint
    push kbd_handler
    call register_kbd_callback
    jmp $
	ret

RANDNUM db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
MSG db "Message from kernel 2", 0
KBD db "KBD", 0
times 1024 - ($-$$) db 0