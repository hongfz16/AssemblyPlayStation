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

stopwatch_kbd_callback:
    push ebp
    mov ebp, esp
    push eax

    mov eax, [ebp+8]
    cmp eax, 0x10
    jne quit_clock_kbd_callback_do_nothing
    mov [QUIT_CHECK], byte 1
    quit_clock_kbd_callback_do_nothing:

    mov eax, [ebp+8]
    cmp eax, 0x1f
    jne start_clock_kbd_callback_do_nothing
    mov [START_CHECK], byte 1
    start_clock_kbd_callback_do_nothing:

    mov eax, [ebp+8]
    cmp eax, 0x19
    jne pause_clock_kbd_callback_do_nothing
    mov al, [PAUSE_CHECK]
    cmp al, 0
    jne pause_clock_kbd_callback_set_zero
    mov [PAUSE_CHECK], byte 1
    jmp pause_clock_kbd_callback_do_nothing
    pause_clock_kbd_callback_set_zero:
    mov [PAUSE_CHECK], byte 0
    pause_clock_kbd_callback_do_nothing:

    mov eax, [ebp+8]
    cmp eax, 0x13
    jne reset_clock_kbd_callback_do_nothing
    mov al, [PAUSE_CHECK]
    cmp al, 0
    je reset_clock_kbd_callback_do_nothing
    mov [RESET_CHECK], byte 1
    reset_clock_kbd_callback_do_nothing:

    pop eax
    pop ebp
    ret 4

stopwatch_tim_callback:
	push eax
	push ebx
	push edx

	mov al, [START_CHECK]
	cmp al, 0
	je stopwatch_not_start

	mov al, [PAUSE_CHECK]
	cmp al, 0
	jne stopwatch_pause

	stopwatch_running:
	mov eax, [CALLBACK_COUNT]
	add eax, 1
	cmp eax, dword 50
	jne stopwatch_tim_callback_do_nothing

	mov edx, [SECOND_COUNT]
	add edx, 1
	push SECOND_STR
	push edx
	call int_to_ascii
	push dword 13
	push dword 38
	push SECOND_STR
	call kprint_at
	push SECOND_STR_S
	call kprint
	mov [SECOND_COUNT], edx
	mov eax, 0

	stopwatch_tim_callback_do_nothing:
	mov [CALLBACK_COUNT], eax
	jmp stopwatch_last

	stopwatch_not_start:
	jmp stopwatch_last
	
	stopwatch_pause:
	mov al, [RESET_CHECK]
	cmp al, 0
	je stopwatch_last
	call stopwatch_reset
	
	stopwatch_last:
	pop edx
	pop ebx
	pop eax
	ret

stopwatch_reset:
	push ecx
	push esi

	mov [SECOND_COUNT], dword 0
	mov [CALLBACK_COUNT], dword 0
	mov [START_CHECK], byte 0
	mov [PAUSE_CHECK], byte 0
	mov [QUIT_CHECK], byte 0
	mov [RESET_CHECK], byte 0

	mov ecx, [STR_LENGTH]
	mov esi, SECOND_STR
	stop_watch_clear_str:
		mov [esi], byte 0
		add esi, 1
		sub ecx, 1
		cmp ecx, 0
		jne stop_watch_clear_str


	call clear_screen
	push dword 0
    push dword 0
    push MSG
    call kprint_at
	push dword 13
	push dword 38
	push SECOND_STR_O
	call kprint_at
	push SECOND_STR_S
	call kprint
	pop esi
	pop ecx
	ret


main:
	call stopwatch_reset

    push stopwatch_kbd_callback
    call register_kbd_callback
    push stopwatch_tim_callback
    call register_tim_callback

    check_quit_loop:
    	cmp [QUIT_CHECK], byte 0
    	je check_quit_loop
	ret

START_CHECK db 0 ; 'S'
PAUSE_CHECK db 0 ; 'P'
QUIT_CHECK db 0 ; 'Q'
RESET_CHECK db 0 ; 'R'

SECOND_STR db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
STR_LENGTH dd 15
SECOND_STR_O db "0", 0
SECOND_STR_S db 's', 0
SECOND_COUNT dd 0
CALLBACK_COUNT dd 0
MSG db "Press 'S' to start; Press 'P' to pause; Press 'R' to reset; Press 'Q' to exit;", 0
times 2048 - ($-$$) db 0