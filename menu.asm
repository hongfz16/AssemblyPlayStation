[bits 32]
section .text
call main
ret

extern clear_screen
extern kprint_at

extern getchar
extern register_kbd_callback
extern register_tim_callback
extern port_byte_out
extern port_byte_in

main:
    reg_for_kbd:
    mov eax, kbd_callback_menu
    push eax
    call register_kbd_callback
    call menu_render
    jmp $
    ret

menu_render:
    mov ebx, [curGame]
    call clear_screen

    push dword 0
    push dword 0
    push HELP_INFO
    call kprint_at

    pushad
    mov eax, ebx
    inc eax
    push eax
    mov eax, 3
    push eax
    mov eax, SArrow
    push eax
    call kprint_at
    popad

    mov ecx, GAMENUM
    mov esi,NameList + 4
    mov ebx, 2
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
    ret

kbd_callback_menu:
; A: 1E
; S: 1F
; D: 20
; w: 11
; J: 24
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
    jne kbd_call_menu_check_config

    inc ebx
    cmp ebx, GAMENUM + 1
    jne kbd_callback_menu_finish
    mov ebx, 1
    jmp kbd_callback_menu_finish

    kbd_call_menu_check_config:
    cmp eax, 0x24
    jne kbd_callback_menu_finish
    mov eax, [curGame]
    add eax, ebx
    add eax, ebx
    add eax, ebx
    add eax, GameList
    push dword 0
    call register_kbd_callback
    push dword 0
    call register_tim_callback
    pushad
    before_call_clock:
    sti
    call [eax]
    ; jmp $
    cli
    after_call_clock:
    popad
    push kbd_callback_menu
    call register_kbd_callback
    push dword 0
    call register_tim_callback
    jmp kbd_callback_menu_ret

    kbd_callback_menu_finish:
    mov [curGame], ebx

    call menu_render
;    mov ecx, [curGame]
;    mov esi,
;     call clear_screen

;     push dword 0
;     push dword 0
;     push HELP_INFO
;     call kprint_at

;     pushad
;     mov eax, ebx
;     inc eax
;     push eax
;     mov eax, 3
;     push eax
;     mov eax, SArrow
;     push eax
;     call kprint_at
;     popad

;     mov ecx, GAMENUM
;     mov esi,NameList + 4
;     mov ebx, 2
;     kbd_callback_menu_loop:
;     pushad
;     mov edx, [esi]
; ;    mov eax, [edx]
; ;    mov edx, eax
;     mov eax, ebx
;     push eax
;     mov eax, 8
;     push eax
;     mov eax, edx
;     push edx
;     call kprint_at
;     popad
;     dec ecx
;     add esi, 4
;     inc ebx
;     test ecx, 0xffffffff
;     jnz kbd_callback_menu_loop

    kbd_callback_menu_ret:
    pop ebp
    ret 4

; func_game1:
;     call clear_screen
;     mov eax, 3
;     push eax
;     mov eax, 3
;     push eax
;     mov eax, welcome_game1
;     push eax
;     call kprint_at
;     ret

TIMER db "Timer!", 0
kbd_buf times 256 db 0
kbd_head db 255
kbd_tail db 0
kbd_callback dd 0
tim_callback dd 0
scancode_trans db 0,0x1b,"1234567890-+",0x08,0x09,"QWERTYUIOP[]",0x0a,0x0d,"ASDFGHJKL",0x3b,0x27,0x60,".",0x5c,"ZXCVBNM",0x2c,"./.",0,0,0,0,0,0,0,0,0,0

Name1 db "Clock", 0
Name2 db "Dinasour", 0
Name3 db "Stopwatch", 0

HELP_INFO db "Please use 'W' and 'S' to choose; Press 'J' to enter the program;"

curGame dd 1
always0 dd 0
GAMENUM equ 3
NameList dd 0, Name1, Name2, Name3
GameList dd 0, 0x3000, 0x3800, 0x4000

SArrow db "->",0

finish1:
times 4096 - ($-$$) db 0