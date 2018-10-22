[bits 32]
section .text
call main
ret

extern init_seed
extern rand_num
extern clear_screen
extern kprint
extern kprint_at
extern put_char
extern int_to_ascii
extern getchar
extern register_kbd_callback
extern register_tim_callback
WHITE_ON_BLACK equ 0x0f
RED_ON_WHITE equ 0xf4


;==============================
safe_put_char:
; print char safely
;	Params: dd: chr, [ebx+8]
;			dd: col, [ebx+12]
;			dd: row, [ebx+16]
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	mov eax, [ebp+8]
	mov ebx, [ebp+12]
	mov ecx, [ebp+16]
	mov edx, dword WHITE_ON_BLACK
	safe_put_char_debug1:
	;-----------------------------------------
	; make sure row >= 0
	cmp ecx, 0
	jl safe_put_char_funcEnd
	;-----------------------------------------
	; make sure row < 25
	cmp ecx, 25
	jge safe_put_char_funcEnd
	;-----------------------------------------
	; make sure col >= 0
	cmp ebx, 0
	jl safe_put_char_funcEnd
	;-----------------------------------------
	; make sure col < 80
	cmp ebx, 80
	jge safe_put_char_funcEnd
	;-----------------------------------------

	push edx
	push ecx
	push ebx
	push eax
	call put_char
	safe_put_char_debug2:

	safe_put_char_funcEnd:
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret 12

;==============================
print_obstacle:
; print obstacle on screen
; Params:
;		dd row [esp+8]
;		dd col [esp+12]
;==============================
	push ebp
	mov ebp, esp
	push ecx
	push eax
	push ebx
	push edx

	mov eax, [ebp+8]
	mov ecx, dword obstacle_height
	print_obstacle_L1:
		push ecx

		mov ebx, [ebp+12]
		mov ecx, dword obstacle_width
		print_obstacle_L1_L1:
			;--------------------------------------------
			; push params
			push eax
			push ebx
			mov edx, '#'
			push edx
			;--------------------------------------------
			; call print function
			call safe_put_char
			;--------------------------------------------
			inc ebx
		loop print_obstacle_L1_L1

		inc eax
		pop ecx
	loop print_obstacle_L1

	pop edx
	pop ebx
	pop eax
	pop ecx
	pop ebp
	ret 8


;==============================
print_player:
; print player on screen
; Params:
;		dd row [esp+8]
;       dd col [esp+12]
;      @      @
;      |      |
;   -+-+   -+-+
;    / /    \ \
;
;==============================
	push ebp
	mov ebp, esp
	push ecx
	push eax
	push ebx
	push edx

	mov eax, [ebp+8]
	inc eax
	mov ebx, [ebp+12]
	add ebx, 3
	push eax
	push ebx
	mov edx, '@'
	push edx
	call safe_put_char

	inc eax
	push eax
	push ebx
	mov edx, '|'
	push edx
	call safe_put_char

	inc eax
	mov ebx, [ebp+12]
	push eax
	push ebx
	mov edx, '-'
	push edx
	call safe_put_char

	inc ebx
	push eax
	push ebx
	mov edx, '+'
	push edx
	call safe_put_char

	inc ebx
	push eax
	push ebx
	mov edx, '-'
	push edx
	call safe_put_char

	inc ebx
	push eax
	push ebx
	mov edx, '+'
	push edx
	call safe_put_char


	mov edx, '/'
	mov ecx, [frame]
	test ecx, 0x4
	; cmp ecx, 0
	je print_player_odd_frame1
	mov edx, '\'
	print_player_odd_frame1:


	inc eax
	mov ebx, [ebp+12]
	inc ebx
	push eax
	push ebx
	push edx
	call safe_put_char

	add ebx, 2
	push eax
	push ebx
	push edx
	call safe_put_char	


	pop edx
	pop ebx
	pop eax
	pop ecx
	pop ebp
	ret 8

kbd_handler:
    push KBD
    call kprint
    ret 4

dinosaur_render:
	push eax
	push ebx
	push ecx

	call clear_screen
	;----------------------------------------------
	; print player
	mov eax, 5
	push eax
	mov eax, 0
	mov al, [player_pos_y]
	push eax
	call print_player
	;----------------------------------------------

	;----------------------------------------------
	; print obstacle
	mov ecx, 0
	mov cl, [num_obstacles]
	mov ebx, obstacles
	dinosaur_render_L1:
		; cmp [ebx], byte 0
		; jle dinosaur_render_L1_end
		; dinosaur_render_debug:
		mov eax, 0
		mov al, byte [ebx]
		dinosaur_render_debug:
		push eax
		mov eax, 22
		push eax
		call print_obstacle

		add ebx, 1
	loop dinosaur_render_L1
	dinosaur_render_L1_end:
	; mov eax, 5
	; push eax
	; mov eax, 0
	; mov al, [player_pos_y]
	; push eax
	; call print_player
	;----------------------------------------------

	pop ecx
	pop ebx
	pop eax
	ret

dinosaur_move:
	push eax
	push ecx
	push ebx

	;----------------------------------------------
	;if player_pos_y < 20
	cmp [player_pos_y], byte 20
	jge dinosaur_move_onGround
	;----------------------------------------------
		mov al, [player_acc_y]
		sub [player_pos_y], al
		; mov al, [player_pos_y]
		; dinosaur_move_debug1:
		sub [player_acc_y], byte 1
		; mov al, [player_acc_y]
		; dinosaur_move_debug2:
		cmp [player_pos_y], byte 20
		jl dinosaur_move_endif1
			mov [player_pos_y], byte 20
		jmp dinosaur_move_endif1
	;----------------------------------------------
	; else player_pos_y >= 20
	dinosaur_move_onGround:
		mov [player_acc_y], byte 0
		mov [player_pos_y], byte 20
	dinosaur_move_endif1:
	;----------------------------------------------

	mov ecx, 0
	mov cl, [num_obstacles]
	mov ebx, obstacles
	dinosaur_move_L1:
		; mov al, [ebx]
		; dinosaur_move_debug1:
		; cmp [ebx], byte 0
		; jle dinosaur_move_L1_end

		sub [ebx], byte velocity
		; mov al, [ebx]
		; dinosaur_move_debug2:

		add ebx, 1
	loop dinosaur_move_L1
	dinosaur_move_L1_end:

	;------------------------------------------
	; if out screen
	mov bl, [obstacles]
	add bl, obstacle_width
	; dinosaur_move_debug:
	cmp bl, byte 0
	jge dinosaur_move_funcEnd
	;------------------------------------------
		mov ecx, 10
		mov ebx, obstacles
		dinosaur_move_L2:
			mov al, [ebx+1]
			mov [ebx], al
			add ebx, 1
		loop dinosaur_move_L2
		mov [ebx], byte 0
		sub [num_obstacles], byte 1

	dinosaur_move_funcEnd:

	pop ebx
	pop ecx
	pop eax
	ret

dinosaur_random_add:
	push eax
	push ebx
	push ecx

	;-----------------------------------------------
	; if there is no obstacle on screen
	; add one obstacle
	cmp [num_obstacles], byte 0
	jg dinosaur_random_add_has_obstacle
	;-----------------------------------------------
		mov [obstacles], byte 80
		add [num_obstacles], byte 1
		jmp dinosaur_random_add_funcEnd
	;-----------------------------------------------
	dinosaur_random_add_has_obstacle:
	;-----------------------------------------------
	; if last obstacle pos_x <= 60
	mov ebx, 0
	mov bl, [num_obstacles]
	cmp [obstacles+ebx-1], byte 60
	jg dinosaur_random_add_funcEnd
	;-----------------------------------------------
		;-----------------------------------------------
		; random add
		call rand_num
		; dinosaur_random_add_debug1:
		and eax, 0x7
		; dinosaur_random_add_debug2:
		cmp eax, 0
		jne dinosaur_random_add_funcEnd
		;-----------------------------------------------
			mov [obstacles+ebx], byte 80
			add [num_obstacles], byte 1
			jmp dinosaur_random_add_funcEnd

	dinosaur_random_add_funcEnd:
	pop ecx
	pop ebx
	pop eax
	ret

dinosaur_check:
	push eax
	push ebx
	push ecx
	push edx

	call dinosaur_move
	call dinosaur_random_add

	mov ecx, 11
	mov ebx, obstacles
	dinosaur_check_L1:
		cmp [ebx], byte 0
		jle dinosaur_check_L1_end

		;----------------------------------------------------
		;check conflicts
		mov al, [ebx]
		; .dinosaur_check_debug1:
		cmp al, byte (5+player_width)
		jg .dinosaur_check_continue
		cmp al, byte (5-obstacle_width)
		jle .dinosaur_check_continue

		mov al, [player_pos_y]
		; .dinosaur_check_debug2:
		cmp al, byte 25
		jg .dinosaur_check_continue
		cmp al, byte (25-obstacle_height-player_height)
		jl .dinosaur_check_continue
		;----------------------------------------------------

		mov [gameStatus], byte 2

		.dinosaur_check_continue:
		inc ebx
	loop dinosaur_check_L1
	dinosaur_check_L1_end:

	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

dinosaur_gameOver:
	push eax

	mov eax, 13
	push eax
	mov eax, 36
	push eax
	mov eax, infoGameOver
	push eax
	call kprint_at
	; dinosaur_gameOver_debug:
	mov [frame], dword 0
	
	; dinosaur_gameOver_funcEnd:
	pop eax
	ret

dinosaur_callback:
	push eax
	push ebx

	add [frame], dword 1
	mov eax, dword [frame]
	and eax, 0x1
	; add eax, 1
	; mov [frame], eax
	cmp eax, 0
	jne dinosaur_callback_funcEnd

	; mov [frame], dword 0
	; call clear_screen
	; push NUM
	; push eax
	; call int_to_ascii
	; push NUM
	; call kprint
	;----------------------------------------------
	;if gameStatus == 1
	; mov al, 1
	cmp [gameStatus], byte 1
	jne dinosaur_callback_gameStatusNotEqual1
	;----------------------------------------------
		; call dinosaur_move
		; call dinosaur_random_add
		call dinosaur_check
		call dinosaur_render
		jmp dinosaur_callback_funcEnd
		dinosaur_callback_gameStatusNotEqual1:
	;----------------------------------------------
	;if gameStatus == 2
	cmp [gameStatus], byte 2
	jne dinosaur_callback_gameStatusNotEqual2
	;----------------------------------------------
		call dinosaur_gameOver
		jmp dinosaur_callback_funcEnd
		dinosaur_callback_gameStatusNotEqual2:

	dinosaur_callback_funcEnd:

	; mov eax, 0
	; mov al, byte [gameStatus]
	; push RANDNUM
	; push eax
	; call int_to_ascii
	; mov eax, 0
	; push eax
	; push eax
	; push RANDNUM
	; call kprint_at

	; mov eax, dword [frame]
	; push RANDNUM
	; push eax
	; call int_to_ascii
	; mov eax, 1
	; push eax
	; mov eax, 0
	; push eax
	; push RANDNUM
	; call kprint_at

	pop ebx
	pop eax
	ret

dinosaur_jump:
	push eax

	; push inJump

	;----------------------------------------------
	;if player_pos_y >= 20
	mov al, [player_pos_y]
	cmp al, byte 20
	jl dinosaur_jump_funEnd
	;----------------------------------------------
	; dinosaur_jump_debug:
		mov [player_acc_y], byte 3
		mov [player_pos_y], byte 19

	dinosaur_jump_funEnd:
	pop eax
	ret

dinosaur_startgame:

	; mov [gameStatus], byte 1
	; mov [frame], dword 0
	call dinosaur_restart
	ret

dinosaur_restart:
	push ebx
	push ecx

	mov [gameStatus], byte 1
	mov [player_pos_y], byte 20
	mov [frame], dword 0

	mov ebx, obstacles
	mov ecx, 11
	dinosaur_restart_L1:
		mov [ebx], byte 0
		add ebx, 1
	loop dinosaur_restart_L1
	mov [obstacles], byte 80
	mov [num_obstacles], byte 1

	pop ecx
	pop ebx
	ret

dinosaur_kbdDectect:
	push ebp
	mov ebp, esp
	push eax

	mov eax, [ebp+8]
	;----------------------------------------------
	;if input 'S'
	cmp eax, 0x1F
	jne dinosaur_kbdDectect_Not_S
	;----------------------------------------------
		;------------------------------------------
		; if gameStatus = 0
		cmp [gameStatus], byte 0
		jne dinosaur_kbdDectect_funcEnd
		;------------------------------------------
			call dinosaur_startgame
		jmp dinosaur_kbdDectect_funcEnd
	dinosaur_kbdDectect_Not_S:
	;----------------------------------------------
	;if input 'J'
	cmp eax, 0x24
	jne dinosaur_kbdDectect_Not_J
	;----------------------------------------------
		;------------------------------------------
		; if gameStatus = 1
		cmp [gameStatus], byte 1
		jne dinosaur_kbdDectect_funcEnd
		;------------------------------------------
			call dinosaur_jump
		;------------------------------------------
		jmp dinosaur_kbdDectect_funcEnd
	dinosaur_kbdDectect_Not_J:
	;----------------------------------------------
	;if input 'R'
	cmp eax, 0x13
	jne dinosaur_kbdDectect_Not_R
	;----------------------------------------------
		;------------------------------------------
		; if gameStatus = 2
		cmp [gameStatus], byte 2
		jne dinosaur_kbdDectect_funcEnd
		;------------------------------------------
			call dinosaur_restart
		;------------------------------------------
		jmp dinosaur_kbdDectect_funcEnd
	dinosaur_kbdDectect_Not_R:
	;----------------------------------------------
	;if input 'P'
	cmp eax, 0x19
	jne dinosaur_kbdDectect_Not_P
	;----------------------------------------------
		;------------------------------------------
		; if gameStatus = 1
		cmp [gameStatus], byte 1
		jne dinosaur_kbdDectect_Not_P_not_1
		;------------------------------------------
			; call dinosaur_restart
			mov [gameStatus], byte 3
			jmp dinosaur_kbdDectect_funcEnd
		;------------------------------------------
		dinosaur_kbdDectect_Not_P_not_1:
		;------------------------------------------
		; if gameStatus = 3
		cmp [gameStatus], byte 3
		jne dinosaur_kbdDectect_Not_P_not_3
		;------------------------------------------
			mov [gameStatus], byte 1
			jmp dinosaur_kbdDectect_funcEnd
		;------------------------------------------
		dinosaur_kbdDectect_Not_P_not_3:
		jmp dinosaur_kbdDectect_funcEnd
	dinosaur_kbdDectect_Not_P:

	;----------------------------------------------
	;if input 'Q'
	cmp eax, 0x10
	jne dinosaur_kbdDectect_Not_Q
	;----------------------------------------------
		mov [dinosaur_esc], byte 1
	dinosaur_kbdDectect_Not_Q:


	dinosaur_kbdDectect_funcEnd:
	pop eax
	pop ebp
	ret 4

init_game_params:
	; push ebx
	; push ecx

	mov [dinosaur_esc], byte 0
	call dinosaur_restart
	; mov [gameStatus], byte 1
	; mov [player_pos_y], byte 20
	; mov [frame], dword 0

	; mov ebx, obstacles
	; mov ecx, 11
	; dinosaur_restart_L1:
	; 	mov [ebx], byte 0
	; 	add ebx, 1
	; loop dinosaur_restart_L1
	; mov [obstacles], byte 80
	; mov [num_obstacles], byte 1

	; pop ecx
	; pop ebx
	ret

main:
	call init_seed
	call init_game_params
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

    ; push MSG
    ; call kprint
    ; push kbd_handler
    ; call register_kbd_callback
    call clear_screen
    push dinosaur_callback
    call register_tim_callback

    push dinosaur_kbdDectect
    call register_kbd_callback

    dinosaur_loop:
    	cmp [dinosaur_esc], byte 0
    	je dinosaur_loop
    mov [dinosaur_esc], byte 0
	ret

dinosaur_esc db 0
RANDNUM db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
MSG db "Message from kernel 2", 0
KBD db "KBD", 0
infoGameOver db "Game Over!", 0
gameStatus db 0 ; 0 not start
				; 1 playing
				; 2 over
				; 3 paused
obstacles db 80,0,0,0,0,0,0,0,0,0,0
num_obstacles db 1
player_pos_y db 20
player_acc_y db 0
NUM db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
frame dd 0

obstacle_height equ 3
obstacle_width equ 2
player_height equ 4
player_width equ 4
velocity equ 2

times 2048 - ($-$$) db 0