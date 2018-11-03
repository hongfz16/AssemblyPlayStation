; Author: hongfz16
; Mocked VGA Driver providing two print function
[bits 32]

global clear_screen
global kprint_at
global kprint
global put_char
global print_char

; Define VGA Constants
VIDEO_ADDRESS equ 0xb8000
MAX_ROWS equ 25
MAX_COLS equ 80
VIDEO_SIZE equ 2000
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
	push eax
	
	mov esi, VIDEO_ADDRESS
	mov ecx, VIDEO_SIZE
	clear_screen_loop:
		mov al, ' '
		mov ah, WHITE_ON_BLACK
		mov [esi], ax
		add esi, 2
		sub ecx, 1
		cmp ecx, 0
		je clear_screen_done
		jmp clear_screen_loop
	clear_screen_done:
		push 0
		call set_cursor_offset

	pop eax
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
	push esi
	
	mov esi, [ebx+8]

	mov eax, [ebx+12]
	cmp eax, 0
	jl kprint_illegel 
	mov eax, [ebx+16]
	cmp eax, 0
	jl kprint_illegel

	kprint_legel:
		mov eax, [ebx+16]
		push eax
		mov eax, [ebx+12]
		push eax
		call calc_offset
		mov [ebx-4], eax
		jmp kprint_while
	kprint_illegel:
		call get_cursor_offset
		mov [ebx-4], eax
		push eax
		call calc_row_by_offset
		mov [ebx+16], eax
		mov eax, [ebx-4]
		push eax
		call calc_col_by_offset
		mov [ebx+12], eax


	kprint_while:
		push WHITE_ON_BLACK
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
		; before_print_char:
		push eax
		call print_char
		; after_print_char:
		mov [ebx-4], eax
		add esi, 1
		mov al, [esi]
		cmp al, 0
		je kprint_while_done
		jmp kprint_while

	kprint_while_done:

	pop esi
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
	push eax

	mov eax, -1
	push eax
	push eax
	mov eax, [ebx+8]
	push eax
	call kprint_at

	pop eax
	pop ebx
	ret 4

;----------------------------------
put_char:
;	Print single char on screen for public
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
	push edx
	push esi
	push eax
	push ecx
	;TODO: write more robust codes
	
	mov edx, [ebx+16]
	cmp edx, MAX_ROWS
	jge put_char_print_char_illegel
	mov edx, [ebx+12]
	cmp edx, MAX_COLS
	jge put_char_print_char_illegel
	jmp put_char_print_char_legel

	put_char_print_char_illegel:
		mov esi, VIDEO_ADDRESS
		add esi, VIDEO_SIZE
		add esi, VIDEO_SIZE
		sub esi, 2
		mov dl, 'E'
		mov dh, RED_ON_WHITE
		mov [esi], dx
		mov edx, [ebx+16]
		push edx
		mov edx, [ebx+12]
		push edx
		call calc_offset
		jmp put_char_print_char_finish

	put_char_print_char_legel:
		mov edx, [ebx+16]
		push edx
		mov edx, [ebx+12]
		push edx
		call calc_offset
		mov ecx, [ebx+8]
		mov edx, [ebx+20]
		mov ch, dl
		mov edx, VIDEO_ADDRESS
		add edx, eax
		mov [edx], cx
		add eax, 2
		push eax
		call set_cursor_offset
		put_char_print_char_finish:

	pop ecx
	pop eax
	pop esi
	pop edx
	pop ebx
	ret 16

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
	push edx
	push esi
	;TODO: write more robust codes
	
	mov edx, [ebx+16]
	cmp edx, MAX_ROWS
	jge print_char_illegel
	mov edx, [ebx+12]
	cmp edx, MAX_COLS
	jge print_char_illegel
	jmp print_char_legel

	print_char_illegel:
		mov esi, VIDEO_ADDRESS
		add esi, VIDEO_SIZE
		add esi, VIDEO_SIZE
		sub esi, 2
		mov dl, 'E'
		mov dh, RED_ON_WHITE
		mov [esi], dx
		mov edx, [ebx+16]
		push edx
		mov edx, [ebx+12]
		push edx
		call calc_offset
		jmp print_char_finish

	print_char_legel:
		mov edx, [ebx+16]
		push edx
		mov edx, [ebx+12]
		push edx
		call calc_offset
		mov ecx, [ebx+8]
		mov edx, [ebx+20]
		mov ch, dl
		mov edx, VIDEO_ADDRESS
		add edx, eax
		mov [edx], cx
		add eax, 2
		push eax
		call set_cursor_offset
		print_char_finish:

	pop esi
	pop edx
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
