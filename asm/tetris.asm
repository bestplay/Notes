; Tetris game

assume cs:codesg,ds:datasg
datasg segment
	part dw 0,0,0					; 当前零件形状 (七种,四种变形),x,y 

	part0 db 0,10,0,20,0,30,0,40 	; 4组(x,y)。七种基本零件初始形状
	part1 db 0,10,0,20,0,30,10,10
	part2 db 0,10,0,20,10,10,20,10
	part3 db 0,10,0,20,10,10,10,20
	part4 db 0,10,10,10,10,20,20,20
	part5 db 0,10,0,20,10,20,10,30
	part6 db 0,10,10,10,10,20,20,10

	table dw part0,part1,part2,part3,part4,part5,part6

datasg ends
codesg segment
	start:	
			call cls

			call listcolour

			call play

			call getchar

	; 播放

	play:
			push ax
			push bx
			push cx
			push ds

			mov ax,datasg
			mov ds,ax

			mov cx,10
		ls1:
			mov bx,7 			; 只有0~6 号形状
			call random
			mov word ptr part[0],bx
			mov word ptr part[2],80
			mov word ptr part[4],80

			mov al,0  			; 产生新零件
			call drawpart
			call delay

			mov al,1  			; 删除旧零件
			call drawpart

			loop ls1

			pop ds
			pop cx
			pop bx
			pop ax
			ret



	; 顺时针旋转90度
	rotate:

	; 画零件
	; 参数：零件形状 part, al=0 创建 al=1删除
	drawpart:
			push bx
			push si
			push cx
			push dx
			push ax

			mov ax,datasg
			mov ds,ax

			mov di,part[0]
			add di,di

			mov bx,0
		dp1:

			mov cx,part[2]
			mov dx,part[4]

			mov si,table[di]

			mov ah,0
			mov al,[bx+si]
			add cx,ax

			mov al,[bx+si+1]
			sub dx,ax


			pop ax
			push ax
			cmp al,0
			jne draw1
			call box
			jmp draw2
	draw1:	
			call delbox
	draw2:
			add bx,2

			cmp bx,8
			jnz dp1

			pop ax
			pop dx
			pop cx
			pop si
			pop bx
			ret


	; 获取随机数 最大0~254
	; 参数：范围 bl
	; 结果：随机数 bl
	random:
			push ax
			push dx
			push cx

			mov ah,0
			int 1ah
			mov ax,dx
			and ah,3 	; 清高6位
			mov dl,bl
			div dl
			mov bl,ah 	; bl中放余数

			pop cx
			pop dx
			pop ax
			ret

	; 显示所有颜色
	listcolour:
			push dx
			push cx
			push ax

			mov dx,4
			mov cx,0
			mov al,0
	doing:
			call point
			inc cx
			call point
			inc cx
			call point
			inc cx
			call point
			inc cx
			call point
			inc cx
			call point
			inc cx
			call point
			inc cx
			call point

			add cx,2
			inc al

			cmp al,16
			jnz doing

			pop ax
			pop cx
			pop dx
			ret

	; delete box 删除指定坐标的 box
	; 参数 dx, cx 行号列号

	delbox:
			push dx
			push cx
			push ax
			push bx

			mov bl,10
			mov bh,10
			mov al,0
	delline:
			call point
			inc cx
			dec bl
			cmp bl,0
			jnz delline

			mov bl,10
			sub cx,10
			inc dx
			dec bh
			cmp bh,0
			jnz delline

			pop bx
			pop ax
			pop cx
			pop dx
			ret


	; draw box 在指定坐标画box
	; 参数 dx, cx 行号列号
	box:	
			push bx
			push ax
			push dx
			push cx
			mov bh,10
	ud: 					; 画上下边框
			mov al,9 		; 边框颜色
			call point
			add dx,9
			call point
			sub dx,9
			inc cx
			dec bh
			cmp bh,0
			jnz ud
		    inc dx
			sub cx,10
							; 画中间部分

			mov bl,8
	midd:
			call point
			inc cx

			mov bh,8
	inner:	
			mov al,14 		; 内部颜色
			call point
			dec bh
			inc cx
			cmp bh,0
			jnz inner

			mov al,9 		; 边框颜色
			call point

			dec bl
			inc dx
			sub cx,9
			cmp bl,0
			jnz midd

			pop cx
			pop dx
			pop ax
			pop bx
			ret

	; 参数颜色：al
	point:
			push ax
			push bx

			mov bh,0
			mov ah,0ch		; 写像素点
			int 10h

			pop bx
			pop ax
			ret



	; clear screen
	cls:
			push ax
			mov ax,012h 	; 640*480 16色
			;mov ax,04 		; 320*200 4色
			int 10h
			mov ah,0bh
			mov bh,0
			mov bl,0
			int 10h

			mov ah,0bh
			mov bx,0100h
			int 10h
			pop ax
			ret

	; get char from keyboard
	getchar:
			mov ah,0
			int 16h

			cmp al,'q'
			je short exit

			mov bx,0b800h
			mov ds,bx
			mov bx,0
			mov [bx],al
			mov [bx+2],al
			mov byte ptr [bx+1],01000010b
			mov byte ptr [bx+3],01000010b

			jmp getchar

	exit:
			mov ax,4c00h
			int 21h

	
	; time = AX 

	delay:	
			push dx
			push ax

			mov dx,1000h   ;;循化10000000h次
			mov ax,10h
		sd1:	
			sub dx,1
			cmp dx,0
			jne sd1

			sub ax,1
			cmp ax,0
			jne sd1

			pop ax
			pop dx
			ret

codesg ends
end start
