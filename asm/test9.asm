; 实验9 
; 在屏幕中间显示三行不同颜色的字符串'welcome to masm!'

assume cs:codesg

data segment
	db "welcome to masm!"

data ends 

codesg segment
start:	
		mov ax,data
		mov ds,ax

		mov ax,0b800h
		mov es,ax

		mov cx,16
		mov bx,0
		mov si,66

s0:		
		mov al,[bx]
		mov es:[si + 6e0h],al
		mov es:[si + 780h],al
		mov es:[si + 820h],al

		inc si
		mov byte ptr es:[si + 6e0h],01000010B
		mov byte ptr es:[si + 780h],10000001B
		mov byte ptr es:[si + 820h],00100100B

		inc bx
		inc si

		loop s0

		mov ax,4c00h
		int 21h
codesg ends 
end start