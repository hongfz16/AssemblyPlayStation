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

; kbd_callback:
;     push KBD
;     call kprint
;     ret 4

tim_callback:
	push eax
	push ebx
	
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
    ; push kbd_callback
    ; call register_kbd_callback
; register timer
	call clear_screen
    push tim_callback
    call register_tim_callback
    jmp $
	ret

SECOND_STR db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
SECOND dd 0
RANDNUM db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
MSG db "Message from kernel2 ", 0
KBD db "KBD", 0
times 1024 - ($-$$) db 0