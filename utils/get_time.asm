[bits 32]

global get_second
global get_minute
global get_hour
global get_weekday
global get_dayofmonth
global get_month
global get_year
global get_century
global get_time_int
global get_time_str

extern port_byte_in
extern port_byte_out
extern int_to_hex_ascii

get_time:
; dw: data [ebp+8]
	push ebp
	mov ebp, esp
	push ebx

	mov ax, [ebp+8]
	push ax
	mov ax, 0x70
	push ax
	call port_byte_out

	mov eax, 0x0
	mov bx, 0x71
	push bx
	call port_byte_in

	pop ebx
	pop ebp
	ret 2

get_second:
	mov ax, 0x00
	push ax
	call get_time
	ret

get_minute:
	mov ax, 0x02
	push ax
	call get_time
	ret

get_hour:
	mov ax, 0x04
	push ax
	call get_time
	ret

get_weekday:
	mov ax, 0x06
	push ax
	call get_time
	ret

get_dayofmonth:
	mov ax, 0x07
	push ax
	call get_time
	ret

get_month:
	mov ax, 0x08
	push ax
	call get_time
	ret

get_year:
	mov ax, 0x09
	push ax
	call get_time
	ret

get_century:
	mov ax, 0x32
	push ax
	call get_time
	ret

get_time_int:
	push ebx

	mov ebx, 0x0
	call get_dayofmonth
	add ebx, eax
	shl ebx, 8
	
	call get_hour
	add ebx, eax
	shl ebx, 8

	call get_minute
	add ebx, eax
	shl ebx, 8

	call get_second
	add ebx, eax

	mov eax, ebx

	pop ebx
	ret

get_time_str:
; dd: straddr [ebp+8]
	push ebp
	mov ebp, esp
	sub esp, 4
	push esi
	push eax
	push ebx
	push edx

	mov esi, [ebp+8]

	mov eax, 0x0
	call get_century
	mov ebx, 2
	push ebx
	push buffer
	push eax
	call int_to_hex_ascii

	mov bl, [buffer]
	mov [esi], bl
	mov bl, [buffer+1]
	mov [esi+1], bl
	add esi, 2

	mov eax, 0x0
	call get_year
	mov ebx, 2
	push ebx
	push buffer
	push eax
	call int_to_hex_ascii

	mov bl, [buffer]
	mov [esi], bl
	mov bl, [buffer+1]
	mov [esi+1], bl
	add esi, 2

	mov [esi], byte '/'
	add esi, 1

	mov eax, 0x0
	call get_month
	mov ebx, 2
	push ebx
	push buffer
	push eax
	call int_to_hex_ascii

	mov bl, [buffer]
	mov [esi], bl
	mov bl, [buffer+1]
	mov [esi+1], bl
	add esi, 2

	mov [esi], byte '/'
	add esi, 1

	mov eax, 0x0
	call get_dayofmonth
	mov ebx, 2
	push ebx
	push buffer
	push eax
	call int_to_hex_ascii

	mov bl, [buffer]
	mov [esi], bl
	mov bl, [buffer+1]
	mov [esi+1], bl
	add esi, 2

	mov [esi], byte '  '
	add esi, 1

	mov eax, 0x0
	call get_hour
	; TODO: fix hour that is late 8h
	mov ebx, 2
	push ebx
	push buffer
	push eax
	call int_to_hex_ascii

	mov bl, [buffer]
	mov [esi], bl
	mov bl, [buffer+1]
	mov [esi+1], bl
	add esi, 2

	mov [esi], byte ':'
	add esi, 1

	mov eax, 0x0
	call get_minute
	mov ebx, 2
	push ebx
	push buffer
	push eax
	call int_to_hex_ascii

	mov bl, [buffer]
	mov [esi], bl
	mov bl, [buffer+1]
	mov [esi+1], bl
	add esi, 2

	mov [esi], byte ':'
	add esi, 1

	mov eax, 0x0
	call get_second
	mov ebx, 2
	push ebx
	push buffer
	push eax
	call int_to_hex_ascii

	mov bl, [buffer]
	mov [esi], bl
	mov bl, [buffer+1]
	mov [esi+1], bl
	add esi, 2

	pop edx
	pop ebx
	pop eax
	pop esi
	add esp, 4
	pop ebp
	ret 4

buffer db 0,0,0,0