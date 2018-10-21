[bits 32]

A equ 1103515245
C equ 12345
MODU  equ 0x80000000

init_seed:
	mov ah, 0x00
	int 1ah
	mov [seed], dx
	mov [seed+2], cx
	ret

rand_num:
;-------------
; return: eax
;------------- 
	push ebp
	mov ebp, esp
	push ebx
	push edx
	
	mov eax, [seed]
	mov ebx, A
	mul ebx
	add eax, C
	mov edx, 0x0
	mov ebx, MODU
	div ebx
	mov eax, edx
	mov [seed], eax
	
	; mov ebx, [ebp+8]
	; div ebx
	; mov eax, edx

	pop edx
	pop ebx
	pop ebp
	ret 4

seed dd 0x0