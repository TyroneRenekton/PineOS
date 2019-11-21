TI_GDT equ 0
RPL0 equ 0
SELECTOR_VIDEO equ (0x0003<<3) + TI_GDT + RPL0

[bits 32]
section .text

;--------------------- put_char --------------
;功能描述：把stack中的一个字符写入光标所在处
;--------------------------------------------
global put_char
put_char:
	pushad	; to save all 双字寄存器             
	mov ax, SELECTOR_VIDEO
	mov gs, ax
	
	;获取光标位置
	mov dx, 0x03d4
	mov al, 0x0e
	out dx, al
	mov dx, 0x03d5
	in al, dx
	mov ah, al

	mov dx, 0x03d4
	mov al, 0x0f
	out dx, al
	mov dx, 0x03d5
	in al, dx

	;将光标存入寄存器
	mov bx, ax
	mov ecx, [esp+36]

	cmp cl, 0xd
	jz .is_carriage_return
	cmp cl, 0xa
	jz .is_line_read
	cmp cl, 0x8
	jz .is_backspace
	jmp .put_other
	
.is_backspace:
	dec bx
	shl bx, 1 
	
	mov byte [gs:bx], 0x20
	inc bx		
	mov byte [gs:bx], 0x07
	shr bx, 1
	jmp .set_cursor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.put_other:
	shl  bx, 1
	mov [gs:bx], cl
	inc bx
	mov byte [gs:bx], 0x07
	shr  bx, 1
	inc bx
	cmp bx, 2000
	jl .set_cursor

.is_line_read:
.is_carriage_return:
	xor dx, dx
	mov ax, bx
	mov si, 80
	div si 
	sub bx, dx
			
.is_carriage_return_end:
	add bx, 80
	cmp bx, 2000
.is_line_feed_end:
	jl .set_cursor

.roll_screen:
	cld
	mov ecx, 960
	
	mov esi, 0xc00b80a0
	mov edi, 0xc00b8000
	rep movsd

	mov ebx, 3840
	mov ecx, 80

.cls:
	mov word [gs:ebx], 0x0720
	add ebx, 2
	loop .cls
	mov bx, 1920

.set_cursor:

	mov dx, 0x03d4
	mov al, 0x0e
	out dx, al
	mov dx, 0x03d5
	mov al, bh
	out dx, al

	mov dx, 0x03d4
	mov al, 0x0f
	out dx, al
	mov dx, 0x03d5
	mov al, bl
	out dx, al
.put_char_done:
	popad
	ret 

global put_str
put_str:
	pushad
	push ebp
	mov ebp, [esp+40]
.goon:
	mov ecx, [ebp]
	cmp ecx, 0
	jz .put_str_end
	push ecx
	call put_char
	add esp, 4
	inc ebp
	jmp .goon

.put_str_end:
	popad	
	pop ebp
	ret
global put_int
put_int:
	pushad 
	mov ecx, [esp+36]
	mov ebx, 0	; 记录数字位数

.goon_int:

	mov eax, ecx

	and eax, 0x0000ffff

	mov edx, ecx

	and edx, 0xffff0000

	mov cx, 10

	div cx 
	
	add edx, 48	; ascii

	push edx 

	inc ebx

	cmp ax, 0
	jz .put_int_end

	mov ecx, eax
	jmp .goon_int


.put_int_end:

.print_int:

	call put_char

	add esp, 4

	dec ebx

	cmp ebx, 0
	jnz .print_int
	
	popad	
	ret
