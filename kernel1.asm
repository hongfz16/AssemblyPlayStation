[bits 32]
section .text
call main
ret

extern init_seed
extern rand_num
extern clear_screen
extern kprint
extern kprint_at
extern print_char
extern int_to_ascii

keyboard_handler:
    cli
    push eax
    mov ax, 0x20
    push ax
    mov ax, 0x20
    push ax
    call port_byte_out

    ; call clear_screen
    ; push 10
    ; push 10
    ; mov eax, KEYBOARD
    ; push eax
    ; call kprint_at

    mov ax, 0x60
    push ax
    call port_byte_in

    pop eax
    sti
    iret

timer_handler:
    cli
    push eax
    
    mov ax, 0x20
    push ax
    mov ax, 0x20
    push ax
    call port_byte_out

    ; mov eax, TIMER
    ; push eax
    ; call kprint
    
    pop eax
    sti
    iret

port_byte_in:
    push ebp
    mov ebp, esp
    push eax
    push edx

    mov dx, [ebp+8]
    in al, dx

    pop edx
    pop eax
    pop ebp
    ret 2

port_byte_out:
;-------
; dw: port [ebp+8]
; dw: data [ebp+10]
;-------
    push ebp
    mov ebp, esp
    push eax
    push edx

    mov dx, [ebp+8]
    mov ax, [ebp+10]
    out dx, al

    pop edx
    pop eax
    pop ebp
    ret 4

redirect:
    push eax
    mov ax, 0x11
    push ax
    mov ax, 0x20
    push ax
    call port_byte_out
    mov ax, 0x11
    push ax
    mov ax, 0xa0
    push ax
    call port_byte_out
    mov ax, 0x20
    push ax
    mov ax, 0x21
    push ax
    call port_byte_out
    mov ax, 0x28
    push ax
    mov ax, 0xa1
    push ax
    call port_byte_out
    mov ax, 0x04
    push ax
    mov ax, 0x21
    push ax
    call port_byte_out
    mov ax, 0x02
    push ax
    mov ax, 0xa1
    push ax
    call port_byte_out
    mov ax, 0x01
    push ax
    mov ax, 0x21
    push ax
    call port_byte_out
    mov ax, 0x01
    push ax
    mov ax, 0xa1
    push ax
    call port_byte_out
    mov ax, 0x00
    push ax
    mov ax, 0x21
    push ax
    call port_byte_out
    mov ax, 0x00
    push ax
    mov ax, 0xa1
    push ax
    call port_byte_out
    pop eax
    ret

main:
	; mov eax, MSG
	; mov ebx, eax
	; call print_string_pm

    ; push 20
    ; push 20
    ; mov eax, -1
    ; push eax
    ; mov eax, -1
    ; push eax

    ; call clear_screen
    ; push 25
    ; push 25
    ; mov eax, MSG
    ; push eax
    ; call kprint_at
    cli

    call redirect
    
    ;timer

    mov eax, _IDT
    add eax, 32  * 8

    mov ebx, timer_handler
    mov [eax], bx
    add eax, 2

    mov bx, 0x08
    mov [eax], bx
    add eax, 2
    
    mov bl, 0
    mov [eax], bl
    add eax, 1

    mov bl, 0x8E
    mov [eax], bl
    add eax, 1

    mov ebx, timer_handler
    shr ebx, 16
    mov [eax], bx

    ; keyboard

    mov eax, _IDT
    add eax, 33  * 8

    mov ebx, keyboard_handler
    mov [eax], bx
    add eax, 2

    mov bx, 0x08
    mov [eax], bx
    add eax, 2
    
    mov bl, 0
    mov [eax], bl
    add eax, 1

    mov bl, 0x8E
    mov [eax], bl
    add eax, 1

    mov ebx, keyboard_handler
    shr ebx, 16
    mov [eax], bx

    mov eax, IDT_REG
    mov bx, 2047
    mov [eax], bx
    add eax, 2

    mov ebx, _IDT
    mov [eax], ebx

    ; mov ax, 0x11
    ; push ax
    ; mov ax, 0x20
    ; push ax
    ; call port_byte_out
    ; mov ax, 0x11
    ; push ax
    ; mov ax, 0xa0
    ; push ax
    ; call port_byte_out

    lidt [IDT_REG]

    sti

    mov ax, 0x36
    push ax
    mov ax, 0x43
    push ax
    call port_byte_out
    mov ax, 0x37
    push ax
    mov ax, 0x40
    push ax
    call port_byte_out
    mov ax, 0xa0
    push ax
    mov ax, 0x40
    push ax
    call port_byte_out

    ; main1_loop:
    ;     mov eax, MSG
    ;     push eax
    ;     call kprint
    ;     mov ecx, 0xffffff
    ;     kill_time:
    ;         sub ecx, 1
    ;         cmp ecx, 0
    ;         je kill_time_done
    ;         jmp kill_time
    ;     kill_time_done:
    ;     jmp main1_loop

    call init_seed
    mov eax, 0x0
    in_rand_num:
    call rand_num
    out_rand_num:
    push randnumber
    push eax
    call int_to_ascii
    push randnumber
    call kprint

    ret

_IDT times 256 dq 0
IDT_REG times 6 db 0

randnumber db 0,0,0,0,0,0,0,0,0,0,0,0,0,0
KEYBOARD db "This is a message from keyboard interrupt!!", 0
TIMER db "Timer!", 0
MSG db "ha", 0
times 4096 - ($-$$) db 0
finish1: