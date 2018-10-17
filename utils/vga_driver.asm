; Author: hongfz16
; Mocked VGA Driver providing two print function
[bits 32]

; Define VGA Constants
VIDEO_ADDRESS equ 0xb8000
MAX_ROWS equ 25
MAX_COLS equ 80
WHITE_ON_BLACK equ 0x0f
RED_ON_WHITE equ 0xf4

; Define VGA related I/O ports
REG_SCREEN_CTRL equ 0x3d4
REG_SCREEN_DATA equ 0x3d5

;==================================
; Public kernel VGA API
;==================================

;----------------------------------
clear_screen:
;	Clear whole screen
;----------------------------------
	ret

;----------------------------------
kprint_at:
;	Print str at certain col and row
;	If col or row is not valid,
;	simply print at current cursor
;	Params: dd: str_addr, [ebx+8]
;			dd: col, [ebx+12]
;			dd: row, [ebx+16]
;----------------------------------
	push ebx
	mov ebx, esp
	sub esp, 4
	push eax
	push ecx
	push edx

	mov esi, [ebx+8]
	mov eax, [ebx+16]
	push eax
	mov eax, [ebx+12]
	push eax
	call calc_offset
	mov [ebx-4], eax
	kprint_while:
		push RED_ON_WHITE
		mov eax, [ebx-4]
		push eax
		call calc_row_by_offset
		push eax
		mov eax, [ebx-4]
		push eax
		call calc_col_by_offset
		push eax
		mov eax, 0
		mov al, [esi]
		push eax
		call print_char
		mov [ebx-4], eax
		add esi, 1
		mov al, [esi]
		cmp al, 0
		je kprint_while_done
		jmp kprint_while

	kprint_while_done:

	pop edx
	pop ecx
	pop eax
	add esp, 4
	pop ebx
	ret 12

;----------------------------------
kprint:
;	Kernel print str at current
;	cursor place
;	Params: dd: str_addr, [ebx+8]
;----------------------------------
	push ebx
	mov ebx, esp

	pop ebx
	ret 4

;==================================
; Private VGA utils
;==================================

;----------------------------------
print_char:
;	Print single char on screen
;	at certain place
;	If col or row is invalid
;	then will print at current cur
;	Attr means the color info
;	Params: dd: chr, [ebx+8]
;			dd: col, [ebx+12]
;			dd: row, [ebx+16]
;			dd: attr, [ebx+20]
;	Return: eax
;----------------------------------
	push ebx
	mov ebx, esp
	;TODO: write more robust codes
	mov edx, [ebx+16]
	push edx
	mov edx, [ebx+12]
	push edx
	call calc_offset
	;push eax
	;call set_cursor_offset
	mov ecx, [ebx+8]
	mov edx, [ebx+20]
	mov ch, dl
	mov edx, VIDEO_ADDRESS
	add edx, eax
	mov [edx], cx
	add eax, 2
	push eax
	call set_cursor_offset
	pop ebx
	ret 16

;----------------------------------
get_cursor_offset:
;	Use VGA ports to get offset
;	Return: eax
;----------------------------------
	push ebx
	push ecx
	push edx
	
	mov eax, 0
	
	mov al, 14
	mov dx, REG_SCREEN_CTRL
	out dx, al
	
	mov dx, REG_SCREEN_DATA
	in al, dx
	
	mov ah, al
	mov al, 15
	mov dx, REG_SCREEN_CTRL
	out dx, al
	
	mov dx, REG_SCREEN_DATA
	in al, dx
	
	mov ebx, 2
	mul ebx
	
	pop edx
	pop ecx
	pop ebx
	
	ret

;----------------------------------
set_cursor_offset:
;	Use VGA ports to set offset
;	Params: dd: offset, [ebx+8]
;----------------------------------
	push ebx
	mov ebx, esp
	
	push eax
	push edx
	push ecx
	
	mov eax, [ebx+8]
	mov ecx, 2
	mov edx, 0
	div ecx
	
	mov ecx, eax
	mov al, 14
	mov dx, REG_SCREEN_CTRL
	out dx, al
	
	mov al, ch
	mov dx, REG_SCREEN_DATA
	out dx, al
	
	mov al, 15
	mov dx, REG_SCREEN_CTRL
	out dx, al

	mov al, cl
	mov dx, REG_SCREEN_DATA
	out dx, al
	
	pop ecx
	pop edx
	pop eax
	
	pop ebx
	
	ret 4

;----------------------------------
calc_offset:
;	Use col and row to calc offset
;	Params: dd: col, [ebx+8]
;			dd: row, [edx+12]
;	Return: eax
;----------------------------------
	push ebx
	mov ebx, esp
	
	push ecx
	
	mov eax, [ebx+12]
	mov ecx, MAX_COLS
	mul ecx
	add eax, [ebx+8]
	mov ecx, 2
	mul ecx
	
	pop ecx
	pop ebx
	ret 8

;----------------------------------
calc_row_by_offset:
;	Use offset to calc row
;	Params: dd: offset, [ebx+8]
;	Return: eax
;----------------------------------
	push ebx
	mov ebx, esp
	push ecx
	push edx
	
	mov eax, MAX_COLS
	mov ecx, 2
	mul ecx
	mov ecx, eax
	mov eax, [ebx+8]
	div ecx
	
	pop edx
	pop ecx
	pop ebx
	ret 4

;----------------------------------
calc_col_by_offset:
;	Use offset to calc col
;	Params: dd: offset, [ebx+8]
;	Return: eax
;----------------------------------
	push ebx
	mov ebx, esp
	push ecx
	push edx

	mov edx, [ebx+8]
	push edx
	call calc_row_by_offset
	mov ecx, 2
	mul ecx
	mov ecx, MAX_COLS
	mul ecx
	mov edx, [ebx+8]
	sub edx, eax
	mov eax, edx
	mov ecx, 2
	mov edx, 0
	div ecx
	
	pop edx
	pop ecx
	pop ebx
	ret 4
