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
extern int_to_hex_ascii
extern getchar
extern register_kbd_callback
extern register_tim_callback
extern port_byte_out
extern port_byte_in

extern get_second
extern get_minute
extern get_hour
extern get_weekday
extern get_dayofmonth
extern get_month
extern get_year
extern get_century
extern get_time_int
extern get_time_str

kbd_callback:
    ; push KBD
    ; call kprint
    push ebp
    mov ebp, esp
    push eax

    mov eax, [ebp+8]
    cmp eax, 0x10
    jne clock_kbd_callback_do_nothing

    mov [QUIT_CHECK], byte 1

    clock_kbd_callback_do_nothing
    pop eax
    pop ebp
    ret 4

clock_tim_callback:
	push eax
	push ebx
	push dword 0xdeadbeef
	
	mov eax, 0x0
	call get_second

	cmp eax, [SECOND]
	je tim_callback_do_nothing

	mov [SECOND], eax
	push SECOND_STR
	call get_time_str
	push dword 12
	push dword 30
	push SECOND_STR
	call kprint_at

	tim_callback_do_nothing:
	pop ebx
	pop ebx
	pop eax
	ret

main:
	
; generate rand number
	; call init_seed
	; mov ecx, 10
	; rand_loop:
	; 	call rand_num
	; 	push RANDNUM
	; 	push eax
	; 	call int_to_ascii
	; 	push RANDNUM
	; 	call kprint
	; 	sub ecx, 1
	; 	cmp ecx, 0
	; 	je loop_done
	; 	jmp rand_loop
	; loop_done:

; register kbd
	clock_register_kbd_start:
    push kbd_callback
    call register_kbd_callback
; register timer
	call clear_screen
    push clock_tim_callback
    call register_tim_callback

    push MSG
    call kprint

    check_quit_loop:
    	cmp [QUIT_CHECK], byte 0
    	je check_quit_loop
    mov [QUIT_CHECK], byte 0
	ret

QUIT_CHECK db 0
SECOND_STR db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
SECOND dd 0
RANDNUM db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
MSG db "Press 'Q' to exit", 0
KBD db "KBD", 0
times 2048 - ($-$$) db 0