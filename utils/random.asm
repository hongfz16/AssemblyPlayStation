[bits 32]

global init_seed
global rand_num

A equ 1103515245
C equ 12345
MODU  equ 0x80000000

init_seed:
	mov ah, 0x00
	; int 1ah
	mov [seed], word 0xf0
	mov [seed+2], word 0xf5
	ret

rand_num:
;-------------
; return: eax
;------------- 
	push ebp
	mov ebp, esp
	push ebx
	push edx
	
	before_rand_calc:
	mov eax, [seed]
	mov ebx, A
	mul ebx
	add eax, C
	mov edx, 0x0
	mov ebx, MODU
	div ebx
	mov eax, edx
	mov [seed], eax
	
	after_rand_calc:
	; mov ebx, [ebp+8]
	; div ebx
	; mov eax, edx

	pop edx
	pop ebx
	pop ebp
	ret

seed dd 0x0