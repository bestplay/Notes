
	part dw 0,0
	cparto dw 0,0					; 当前零件形状  七种,四种变形,x,y 
	crlpart db 0,0,0,0,0,0,0,0 		; 当前零件盒子相对坐标
	cabpart dw 0,0,0,0,0,0,0,0 		; 当前零件盒子绝对坐标


	nextparto dw 0,0 				; 下一个原点坐标，临时存放
	nextcrlpart db 0,0,0,0,0,0,0,0 	; 零件盒子下一个相对坐标
	nextcabpart dw 0,0,0,0,0,0,0,0 	; 零件盒子下一个绝对坐标


	; 备份到 next
	backpart:
			push ax
			mov al,0
			call copypart
			pop ax
			ret

	; 还原到 cpart
	; 更新到 当前 part
	updatepart:
			push ax
			mov al,1
			call copypart
			pop ax
			ret

	; 拷贝part
	; 参数 al = 0 当前拷贝到next
	; 参数 al = 1 next拷贝到当前
	copypart:
			push si
			push di
			push cx
			cmp al,1
			je cptoc
			mov si,cparto
			mov di,nextparto
			jmp cpton
		cptoc:
			mov di,cparto
			mov si,nextparto
		cpton:

			mov cx,14
			cld
			rep movsw 
			pop cx
			pop di
			pop si
			ret

	; 计算绝对坐标
	; 存放到 nextcabpart 中
	setpart:
			push ax
			push bx
			push cx
			push dx
			push si
			push di

			mov bx,0
			mov si,offset nextcrlpart
			mov di,0
		getabloop0:
			mov cx,nextparto
			mov dx,nextparto+2

			mov ah,0
			mov al,[bx+si]
			add cx,ax
			mov nextcabpart[di],cx

			mov al,[bx+si+1]
			sub dx,ax
			mov nextcabpart[di+2],dx


			add bx,2
			add di,4
			cmp bx,8
			jnz getabloop0

			; TODO 检测越界
			call updatepart

			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			ret
