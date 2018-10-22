[bits 32]

global init_seed
global rand_num

extern get_time_int

A equ 1103515245
C equ 12345
MODU  equ 0x80000000

set_seed:
; dd: seed [ebp+8]
	push ebp
	mov ebp, esp
	push eax

	mov eax, [ebp+8]
	mov [seed], eax

	pop eax
	pop ebp
	ret 4

init_seed:
	push eax
	mov eax, 0x0
	call get_time_int
	mov [seed], eax
	pop eax
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