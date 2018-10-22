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
extern WHITE_ON_BLACK
EXTERN RED_ON_WHITE


;==============================
print_obstacle:
; print obstacle on screen
; Params:
;		dd row [ebx+8]
;		dd col [ebx+12]
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

		cmp eax, 0
		jl print_obstacle_L1_continue

		mov ebx, [ebp+12]
		mov ecx, dword obstacle_width
		; print_obstacle_debug2:
		print_obstacle_L1_L1:
			cmp ebx, 0
			jl print_obstacle_L1_L1_continue

			;--------------------------------------------
			; push params
			mov edx, dword WHITE_ON_BLACK
			push edx
			push eax
			push ebx
			mov edx, '#'
			push edx
			;--------------------------------------------
			; call function
			call put_char
			;--------------------------------------------
			; print_obstacle_debug1:


			print_obstacle_L1_L1_continue:
			inc ebx
			cmp ebx, 80
			jge print_obstacle_L1_L1_end
			; cmp ebx, 0
			; jl print_obstacle_L1_L1_end
		loop print_obstacle_L1_L1
		print_obstacle_L1_L1_end:


		print_obstacle_L1_continue:
		inc eax
		pop ecx
		cmp eax, 25
		jge print_obstacle_L1_end
		; cmp eax, 0
		; jl print_obstacle_L1_end
	loop print_obstacle_L1
	print_obstacle_L1_end:

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
;		dd row [ebx+8]
;       dd col [ebx+12]
;==============================
	push ebx
	mov ebx, esp
	push ecx
	push eax
	push edx

	mov eax, [ebx+8]
	mov ecx, 0
	print_player_L1:
		cmp ecx, player_height
		je print_player_L1_end

		inc eax

		push ecx
		mov ecx, 0
		
		mov edx, [ebx+12]
		print_player_L1_L1:
			cmp ecx, player_width
			je print_player_L1_L1_end

			push ecx
			;--------------------------------------------
			; push params
			mov ecx, WHITE_ON_BLACK
			push ecx
			push eax
			push edx
			inc edx
			mov ecx, '*'
			push ecx
			;--------------------------------------------
			; call function
			call put_char
			;--------------------------------------------
			pop ecx

			inc ecx
			jmp print_player_L1_L1
		print_player_L1_L1_end:

		pop ecx
		inc ecx
		jmp print_player_L1
	print_player_L1_end:

	pop edx
	pop eax
	pop ecx
	pop ebx
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
	dinosaur_gameOver_debug:
	mov [frame], dword 0
	
	dinosaur_gameOver_funcEnd:
	pop eax
	ret

dinosaur_callback:
	push eax
	push ebx

	mov eax, [frame]
	inc eax
	mov [frame], eax
	cmp eax, 2
	jne dinosaur_callback_funcEnd

	mov [frame], dword 0
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

	dinosaur_kbdDectect_funcEnd:
	pop eax
	pop ebp
	ret 4

main:
	call init_seed
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
    jmp $
	ret

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
obstacle_width equ 3
player_height equ 4
player_width equ 4
velocity equ 2

times 2048 - ($-$$) db 0