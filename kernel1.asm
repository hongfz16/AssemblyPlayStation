[bits 32]
section .text
call main
ret

%include "./utils/vga_driver.asm"

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

    mov ebx, [kbd_callback]
    test ebx, 0xffffffff
    jz do_nothing
    pushad
    push esi
    mov eax, esi
    call [kbd_callback]
    popad

    do_nothing:

    popad
    sti
    iret


kbd_hdl:
; dd: esi [ebp+8]
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]
    
    cmp eax, 0x2d
    jne kbd_hdl_finish
;    mov eax, TIMER
;    push eax
;    call kprint
    call print_buff
    kbd_hdl_finish:
    
    pop ebp
    ret 4

print_buff:
    print_buff_loop:
    mov eax, 0
    call getchar
    cmp al, 0
    je print_buff_done
    mov [szFmt], al
    push szFmt
    call kprint
    jmp print_buff_loop
    print_buff_done:
    ret

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


register_kbd_callback: ; eax: address, it can be 0
    mov [kbd_callback], eax
    ret

register_tim_callback: ; eax: address
    mov [tim_callback], eax
    ret

timer_handler:
    cli
;    push eax
    pushad
    mov ax, 0x20
    push ax
    mov ax, 0x20
    push ax
    call port_byte_out

;    mov eax, TIMER
;    push eax
;    call kprint
    mov ebx, [tim_callback]
    test ebx, 0xffffffff
    jz timer_handler_finish
    call tim_callback
    timer_handler_finish:
    popad
;    pop eax
    sti
    iret

port_byte_in:
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

    ; INT 33

    ;jmp $
    reg_for_kbd:
    push eax
    mov eax, kbd_callback_menu
    call register_kbd_callback
    pop eax

    ret


kbd_callback_menu:
; A: 1E
; S: 1F
; D: 20
; w: 11
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]
    mov ebx, [curGame]
    kbd_call_menu_check_up:
    cmp eax, 0x11
    jne kbd_call_menu_check_down

    dec ebx
    cmp ebx, 0
    jne kbd_callback_menu_finish
    mov ebx, GAMENUM
    jmp kbd_callback_menu_finish

    kbd_call_menu_check_down:
    cmp eax, 0x1f
    jne kbd_callback_menu_finish

    inc ebx
    cmp ebx, GAMENUM + 1
    jne kbd_callback_menu_finish
    mov ebx, 1
;    jmp kbd_callback_menu_finish
    kbd_callback_menu_finish:
    mov [curGame], ebx


;    mov ecx, [curGame]
;    mov esi,
    call clear_screen

    pushad
    mov eax, ebx
    push eax
    mov eax, 3
    push eax
    mov eax, SArrow
    push eax
    call kprint_at
    popad

    mov ecx, GAMENUM
    mov esi,NameList + 4
    mov ebx, 1
    kbd_callback_menu_loop:
    pushad
    mov edx, [esi]
;    mov eax, [edx]
;    mov edx, eax
    mov eax, ebx
    push eax
    mov eax, 8
    push eax
    mov eax, edx
    push edx
    call kprint_at
    popad
    dec ecx
    add esi, 4
    inc ebx
    test ecx, 0xffffffff
    jnz kbd_callback_menu_loop


    pop ebp
    ret 4


_IDT times 256 dq 0
IDT_REG times 6 db 0


szFmt db 0,0
KEYBOARD db "This is a message from keyboard interrupt!!", 0
TIMER db "Timer!", 0
MSG db "msg from kernel 111111", 0
kbd_buf times 256 db 0
kbd_head db 255
kbd_tail db 0
kbd_callback dd 0
tim_callback dd 0
scancode_trans db 0,0x1b,"1234567890-+",0x08,0x09,"QWERTYUIOP[]",0x0a,0x0d,"ASDFGHJKL",0x3b,0x27,0x60,".",0x5c,"ZXCVBNM",0x2c,"./.",0,0,0,0,0,0,0,0,0,0

Name1 db "game1", 0
Name2 db "game2", 0
Name3 db "game3", 0
Name4 db "game3", 0
Name5 db "game3", 0
curGame dd 1
GAMENUM equ 5
NameList dd 0, Name1, Name2, Name3, Name3, Name5
SArrow db "->",0

finish1:
times 4096 - ($-$$) db 0