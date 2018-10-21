[bits 32]

int_to_ascii:
;--------------
; dd: int [ebp+8]
; dd: string [ebp+12]
;--------------
	push ebp
	mov ebp, esp
	push ecx
	push eax
	push ebx
	push edx
	push esi

	mov ecx, 0
	mov eax, [ebp+8]
	mov esi, [ebp+12]
	mov edx, 0x0
	itoa_loop:
		add ecx, itoa_divisor
		
		mov ebx, [ecx]
		div ebx
		add eax, '0'
		new_int_out:
		mov [esi], al
		after_mov_int:
		add esi, 1
		mov eax, edx
		mov edx, 0
		
		sub ecx, itoa_divisor
		add ecx, 4
		cmp ecx, [itoa_loop_size]
		je itoa_loop_end
		jmp itoa_loop
	itoa_loop_end:

	pop esi
	pop edx
	pop ebx
	pop eax
	pop ecx
	pop ebp
	ret 8

itoa_divisor dd 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1
itoa_loop_size dd 40