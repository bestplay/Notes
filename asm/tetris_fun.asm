
	; 显示所有颜色
	listcolour:
			push dx
			push cx
			push ax
			push bx

			mov dx,2
	lcdo0:
			mov cx,2
			mov al,0
	lcdo1:
			mov ah,20 	; 每个颜色画长度8
	lcdo2:
			call point
			inc cx
			dec ah
			cmp ah,0
			jnz lcdo2
			inc al

			cmp al,16
			jnz lcdo1

			inc dx
			cmp dx,22
			jnz lcdo0

			pop bx
			pop ax
			pop cx
			pop dx
			ret


	; 顺时针旋转90度
	rotate:
			push ax
			push bx
			push dx
			push si

			sroting0:
				;旋转90
				mov bx,offset part2
				mov si,0
			sroting1:
				mov al,[bx+si]
				mov ah,[bx+si+1]
				mov dl,0
				add dl,ah
				mov byte ptr [bx+si],dl
				mov dl,20
				sub dl,al
				mov byte ptr [bx+si+1],dl 	; 设置旋转后 x,y

				add si,2
				cmp si,8
				jnz sroting1


			pop si
			pop dx
			pop bx
			pop ax
			ret


	; 左移10
	movel:
			push bx
			mov bl,0
			call move
			pop bx
			ret


	; 右移10
	mover:
			push bx
			mov bl,1
			call move
			pop bx
			ret

	; 下移10
	moved:
			push bx
			mov bl,3
			call move
			pop bx
			ret
			

	; 移动 
	; 参数 bl 0,1,2,3  左右上下
	; 00 01 10 11
	move:
			push ax
			push bx
			push dx

			mov dl,bl
			and dl,00000001b 	; 0表示-10，1表示+10
			and bl,00000010b 	; 0表示x，1表示y
			shr bl,1

			mov bh,0
			add bx,bx
			push part[bx+4]   	; x,y 存在part[4][6]中
			pop ax

			cmp dl,0
			je mv0
			add ax,10
			jmp mv1
		mv0:
			sub ax,10
		mv1:
			push ax
			pop part[bx+4]

			pop dx
			pop bx
			pop ax
			ret