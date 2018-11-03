[bits 32]

global int_to_ascii
global int_to_hex_ascii

int_to_ascii:
;--------------
; dd: int [ebp+8]
; dd: string [ebp+12]
;--------------
	push ebp
	mov ebp, esp
	sub esp, 4

	push ecx
	push eax
	push ebx
	push edx
	push esi

	mov ecx, 0x0 ;counter
	mov eax, [ebp+8] ;int
	mov esi, [ebp+12] ;addr of str
	mov edx, 0x0 ;store mod num
	mov [ebp-4], dword 0x1 ;store when to record
	itoa_loop:
		add ecx, itoa_divisor
		
		mov ebx, [ecx]
		div ebx
		add eax, '0'

		cmp [ebp-4], dword 0x0
		je itoa_store_char
		cmp eax, '0'
		je itoa_not_store_char
		mov [ebp-4], dword 0x0

		itoa_store_char:
			mov [esi], al
			add esi, 1
		itoa_not_store_char:

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

	add esp, 4
	pop ebp
	ret 8

int_to_hex_ascii:
;--------------
; dd: int [ebp+8]
; dd: string [ebp+12]
; dd: how many bytes to convert [ebp+16]
;--------------
	push ebp
	mov ebp, esp
	push ecx
	push eax
	push ebx
	push edx
	push esi

	mov ecx, [ebp+16]
	mov eax, [ebp+8]
	mov esi, [ebp+12]
	add esi, ecx
	sub esi, 1
	mov edx, itoa_hex_table

	itoa_hex_loop:
		mov ebx, 0x0F
		and bx, ax
		shr eax, 4

		add edx, ebx
		mov bl, [edx]
		mov [esi], bl
		mov edx, itoa_hex_table
		
		sub esi, 1
		sub ecx, 1
		cmp ecx, 0
		je itoa_hex_done
		jmp itoa_hex_loop
	
	itoa_hex_done:

	pop esi
	pop edx
	pop ebx
	pop eax
	pop ecx
	pop ebp
	ret 12

itoa_hex_table db '0123456789ABCDEF', 0

itoa_divisor dd 1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1
itoa_loop_size dd 40