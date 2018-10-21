; This is a simple dinosaur game
[bits 32]
section .text
call main_dinosaur
ret

%include "./utils/vga_driver.asm"

;==============================
print_player:
; print player on screen
; Params:
;		dd row [ebx+8]
;       dd colon [ebx+12]
;==============================
	push ebx
	mov ebx, esp
	push ecx
	push eax
	push edx

	mov eax, [ebx+8]

	mov ecx, 0
print_player_L1:
	cmp ecx, 3
	je print_player_L1_end

	inc eax

	push ecx
	mov ecx, 0
	
	mov edx, [ebx+8]
print_player_L1_L1:
	cmp ecx, 3
	je print_player_L1_L1_end

	push ecx
	mov ecx, WHITE_ON_BLACK
	push ecx
	push eax
	inc edx
	push edx
	mov ecx, '*'
	push ecx
	call print_char
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

main_dinosaur:
	call clear_screen

	mov eax, 10
	push eax
	mov eax, 20
	push eax
	call print_player

	jmp $
	ret

times 1024 - ($-$$) db 0