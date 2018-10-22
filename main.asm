[bits 32]
section .text

MENU_ENTRY equ 0x2000

call main
call MENU_ENTRY
jmp $
ret

extern init_seed
extern rand_num
extern clear_screen
extern kprint
extern kprint_at
extern print_char
extern int_to_ascii

global getchar
global register_kbd_callback
global register_tim_callback
global port_byte_out
global port_byte_in

; keyboard_handler:
;     cli
;     pushad
;     mov ax, 0x20
;     push ax
;     mov ax, 0x20
;     push ax
;     call port_byte_out

; ;    call clear_screen
; ;    push 10
; ;    push 10
; ;    mov eax, KEYBOARD
; ;    push eax
; ;    call kprint_at

;     mov ax, 0x60
;     push ax
;     mov eax, 0
;     call port_byte_in
;     mov esi, eax
; ;    push eax ; to give arg. to kbd_callback
;     mov ebx, 0
;     mov bl, [kbd_tail]
;     cmp bl, [kbd_head]
;     je do_nothing

;     add ebx, kbd_buf
;     cmp al, 0x30
;     ja do_nothing
;     mov edx, scancode_trans
;     add edx, eax
;     mov al, [edx]
;     mov [ebx], al
;     mov bl, [kbd_tail]
;     inc bl
;     mov [kbd_tail], bl

;     mov ebx, [kbd_callback]
;     test ebx, 0xffffffff
;     jz do_nothing
;     pushad
;     push esi
;     mov eax, esi
;     call [kbd_callback]
;     popad

;     do_nothing:

;     popad
;     sti
;     iret

keyboard_handler:
    cli
    pushad
    mov ax, 0x20
    push ax
    mov ax, 0x20
    push ax
    call port_byte_out

;    call clear_screen
;    push 10
;    push 10
;    mov eax, KEYBOARD
;    push eax
;    call kprint_at

    mov ax, 0x60
    push ax
    mov eax, 0
    call port_byte_in
    mov esi, eax
;    push eax ; to give arg. to kbd_callback
    mov ebx, 0
    mov bl, [kbd_tail]
    cmp bl, [kbd_head]
    je do_nothing

    add ebx, kbd_buf
    cmp al, 0x30
    ja do_nothing
    mov edx, scancode_trans
    add edx, eax
    mov al, [edx]
    mov [ebx], al
    mov bl, [kbd_tail]
    inc bl
    mov [kbd_tail], bl

    do_nothing:
    mov ebx, [kbd_callback]
    test ebx, 0xffffffff
    jz do_nothing
    pushad
    push esi
    mov eax, esi
    call [kbd_callback]
    popad

    popad
    sti
    iret

timer_handler:
    cli

    pushad
    mov ax, 0x20
    push ax
    mov ax, 0x20
    push ax
    call port_byte_out

    ; mov eax, TIMER
    ; push eax
    ; call kprint

    mov ebx, [tim_callback]
    test ebx, 0xffffffff
    jz timer_handler_finish
    call [tim_callback]
    timer_handler_finish:
    popad

    sti
    iret

register_kbd_callback:
; dd: kbd_callback_address [ebp+8]
    cli
    push ebp
    mov ebp, esp
    push eax

    mov eax, [ebp+8]
    mov [kbd_callback], eax

    pop eax
    pop ebp
    sti
    ret 4

register_tim_callback:
; dd: timer_callback_address [ebp+8]
    ; cli
    cli
    push ebp
    mov ebp, esp
    push eax

    mov eax, [ebp+8]
    mov [tim_callback], eax

    pop eax
    pop ebp
    sti
    ret 4

; getchar:
; ;    pushad
; ;    cli
;     push ebx
;     mov ebx, 0
;     mov bl, [kbd_head]
;     inc bl,
;     cmp bl, [kbd_tail]
;     je empty_buffer
;     mov [kbd_head], bl
;     add ebx, kbd_buf
;     mov al, [ebx]
;     jmp getchar_finish
;     empty_buffer:
;     mov al, 0
;     jmp getchar_finish

;     getchar_finish:
;     pop ebx
; ;    sti
;  ;   popad
;     ret
getchar:
;    pushad
;    cli
    push ebx
    mov ebx, 0
    mov bl, [kbd_head]
    inc bl,
    cmp bl, [kbd_tail]
    je empty_buffer
    mov [kbd_head], bl
    add ebx, kbd_buf
    mov al, [ebx]
    jmp getchar_finish
    empty_buffer:
    mov al, 0
    jmp getchar_finish

    getchar_finish:
    pop ebx
;    sti
 ;   popad
    ret


port_byte_in:
; dw: port [ebp+8]
; return: al
    push ebp
    mov ebp, esp
    push edx

    mov dx, [ebp+8]
    in al, dx

    pop edx
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
    cli

    call redirect
    
    ;set timer ivt

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

    ; set keyboard ivt

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

    lidt [IDT_REG]

    sti

    ; something os tutorial has done to init
    ; timer but it seems useless
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

    ret


_IDT times 256 dq 0
IDT_REG times 6 db 0

KEYBOARD db "This is a message from keyboard interrupt!!", 0
TIMER db "Timer!", 0
MSG db "msg from kernel 111111", 0
kbd_buf times 256 db 0
kbd_head db 255
kbd_tail db 0
kbd_callback dd 0
tim_callback dd 0
scancode_trans db 0,0x1b,"1234567890-+",0x08,0x09,"QWERTYUIOP[]",0x0a,0x0d,"ASDFGHJKL",0x3b,0x27,0x60,".",0x5c,"ZXCVBNM",0x2c,"./.",0,0,0,0,0,0,0,0,0,0
times 4096 - ($-$$) db 0
