; Tetris game

assume cs:codesg,ds:datasg
datasg segment

	part dw 0,0 					; 当前零件形状  七种,四种变形

	cparto dw 0,0					; 当前零件形状  x,y 
	crlpart db 0,0,0,0,0,0,0,0 		; 当前零件盒子相对坐标
	cabpart dw 0,0,0,0,0,0,0,0 		; 当前零件盒子绝对坐标

	nextparto dw 0,0 				; 下一个原点坐标，临时存放
	nextrlpart db 0,0,0,0,0,0,0,0 	; 零件盒子下一个相对坐标
	nextabpart dw 0,0,0,0,0,0,0,0 	; 零件盒子下一个绝对坐标

	HEIGHTY equ 480 					; 屏幕高度
	WIDTHX equ 320 					; 屏幕宽度
	oldint9 dw 0,0					; 原来的int9处理例程地址



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

	; 安装新 9号中断，保存旧9号中断，键盘输入
	setup:
			mov ax,datasg
			mov ds,ax

			mov ax,0
			mov es,ax

			push es:[9*4]
			pop oldint9[0]
			push es:[9*4+2]
			pop oldint9[2]			; 保存旧的 int9

			mov word ptr es:[9*4],offset int9
			mov es:[9*4+2],cs 	; 设置新 int9

			; --------------- do
						; -------Do something
						;mov ax,0b800h
						;mov es,ax
						;mov ah,'a'
					s:
						;mov es:[160*12+40*2],ah
						;call delay
						;inc ah
						;cmp ah,'z'
						;jna s

						;mov ax,0
						;mov es,ax
			; ----------------enddo

	;--------end setup


			call cls
			call listcolour

			call play

			;call getchar

		mainloop:
			nop
			jmp mainloop


	; 退出程序，恢复原来的中断
	exit:
		push oldint9[0]
		pop es:[9*4]
		push oldint9[2]
		pop es:[9*4+2] 		; 恢复旧的 int9

		mov ax,4c00h
		int 21h

	; get char from keyboard
	getchar:
			mov ah,0
			int 16h

			cmp al,'q'
			je exit

			jmp getchar


	; int9中断处理程序
	int9: 
			push ax
			push bx
			push es

			in al,60h

			pushf 
			pushf
			pop bx
			and bh,11111100b
			push bx
			popf
			call dword ptr oldint9[0] 	; 调用原 int9

			cmp al,1
			je exit

			; 新的int9

			cmp al,4bh 	 		; <- 向左
			je intleft
			cmp al,4dh 			; -> 向右
			je intright
			cmp al,48h 			; 向上
			je intup
			cmp al,50h 			; 向下
			je intdown
			cmp al,1ch 			; 回车 旋转
			je introtate

			jmp int9ret

	; <- 向左
	intleft:
			call movel
			jmp int9ret
	; -> 向右
	intright:
			call mover
			jmp int9ret
	; 向上
	intup:
			call moveu
			jmp int9ret
	; 向下
	intdown:
			call moved
			jmp int9ret
	; 旋转
	introtate:
			mov al,1
			call drawpart
			
			call rotate

			mov al,0
			call drawpart
			jmp int9ret

	int9ret:
			pop es
			pop bx
			pop ax
			iret


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
			pushf
			push ax
			push ds
			push es

			mov cx,datasg
			mov ds,cx
			mov es,cx

			cmp al,1
			je cptoc
			mov si,offset cparto 				; 
			mov di,offset nextparto 			; 
			jmp cpton
		cptoc:
			mov di,offset cparto 				; 
			mov si,offset nextparto  			; 
		cpton:
			mov cx,14
			cld
			rep movsw 

			pop es
			pop ds
			pop ax
			popf
			pop cx
			pop di
			pop si
			ret


	; 设置next新绝对坐标，并尝试更新
	; 用next原点，相对坐标，计算绝对坐标，存放到 nextabpart 中
	; 检测next绝对坐标是否可行，
	; 可行则将next原点，相对坐标，绝对坐标，更新到当前。
	; !!调用前，准备好next原点，next相对坐标

	; 返回值： AL=0 成功， AL=1 失败，发生碰撞
	setpart:
			push ax

			call getnextabpart

			; TODO 检测越界
			call checkcollision
			cmp al,0
			jne setpartret

			call updatepart

		setpartret:
			pop ax
			ret
 	
	; 用next原点，相对坐标，计算绝对坐标，存放到 nextabpart 中
	getnextabpart:
			push bx
			push cx
			push dx
			push si
			push di

			mov bx,0
			mov si,offset nextrlpart
			mov di,0
		getabloop0:
			mov cx,nextparto
			mov dx,nextparto+2

			mov ah,0
			mov al,[bx+si]
			add cx,ax
			mov nextabpart[di],cx

			mov al,[bx+si+1]
			sub dx,ax
			mov nextabpart[di+2],dx


			add bx,2
			add di,4
			cmp bx,8
			jnz getabloop0
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			ret

	; 碰撞检测
	; 检测零件next绝对坐标是否发生碰撞
	; 返回：AL=0 无碰撞 AL=1 发生碰撞

	checkcollision:
			push bx
			push cx
			push dx
			push si
			push di

			; 获取next绝对坐标

			mov si,0
			mov cx,4
		ccsloop0:

				mov di,offset cabpart
				mov bx,0
			ccsloop1:


				mov ax,nextabpart[si]
				cmp ax,cabpart[di] 				; 比较x
				jne ccsln0
				mov dx,nextabpart[si+2]
				cmp dx,cabpart[di+2] 			; 比较y
				jne ccsln0
				; 新坐标在原坐标中存在，该新坐标通过检测
				jmp ccsnext

			ccsln0: 			; 两坐标不相等，取cabpart中下一个坐标继续比较				
				add di,4
				inc bx
				cmp bx,4
				jb ccsloop1

				; ----------- check
						; 所有原坐标都不等于当前新坐标，继续检测是否越界 ax=x,dx=y


						mov ax,nextabpart[si]
						mov dx,nextabpart[si+2]
						cmp ax,WIDTHX-11
						ja ccsoverflow
						add ax,10  				; 防止负数
						cmp ax,10
						jb ccsoverflow 

						cmp dx,HEIGHTY-1
						ja ccsoverflow
						add dx,10 				; 防止负数
						cmp dx,10
						jb ccsoverflow 



						; 检测新坐标是否被占用
						push cx
						mov cx,ax
						add cx,4
						add dx,4
						call getcolour
						pop cx

						mov ah,0
						mov dl,16
						div dl
						cmp ah,0
						jne ccsoverflow


				; ----------- check end



		ccsnext: 	;开始下一个坐标的检测

			add si,4
			loop ccsloop0
			; 所有新坐标通过检测
			mov al,0 
			jmp ccsret

		ccsoverflow:
			; debug-------------------------
					mov al,14
					mov dx,200
					mov cx,200
					call point
					inc dx
					inc cx
					call point
					inc dx
					inc cx
					call point
					inc dx
					inc cx
					call point
			; debug-------------------------

			mov al,1


		ccsret:
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			ret
	; TODO
	; 检查边界，移动前判断是否可以继续移动
	; 参数 bl 0,1,2,3  左右上下
	; 00 01 10 11
	; 返回值 为 BH=0 可移动。 
	; 返回值 为 BH=1 达到临界，不可移动。 
	checkoverflow:
			push ax
			push cx
			push dx
			push si

			push bx
			mov ax,datasg
			mov ds,ax

			; 根据 方向 给出临界值
			cmp bl,0
			je cofd0
			cmp bl,1
			je cofd1
			cmp bl,2
			je cofd2
			cmp bl,3
			je cofd3

			cofd0:
				mov ax,0
				push ax
				jmp cofd4
			cofd1:
				mov ax,WIDTHX-10
				push ax
				jmp cofd4
			cofd2:
				mov ax,HEIGHTY+10
				push ax
				jmp cofd4
			cofd3:
				mov ax,40
				push ax
			cofd4:

			mov bh,bl
			and bh,00000001b 	; 0表示-10，1表示+10 	即： 左下 最小/右上 最大
			and bl,00000010b 	; 0表示x，1表示y  	即： 左右x/上下y
			shr bl,1

			; 根据方向判断取x还是y

			mov si,offset crlpart
			cmp bl,0
			je cof0
				inc si 				; 设置起始坐标为 x / y
				push part[6]  		; 保存零件起点y
				jmp cof1
		cof0:
			push part[4]
		cof1:


			; 根据方向判断取最大最小值的方式
			cmp bh,0
			je cof2
				mov ax,0
				jmp cof3
		cof2:
			mov ax,0ffffh
		cof3:


			; 根据方向算出 crlpart 中所有点中的最值，存放到 al 中
			mov cx,4
		cofloop:

			mov dl,[si]

			cmp bh,0
			je overflowabove0
				cmp al,dl
				jb overflowabove
				jmp overflowless0
			overflowabove0:
				cmp al,dl
				ja overflowabove
			overflowless0:
					jmp overflowless
				overflowabove:
					mov al,dl
				overflowless:

			add si,2
			loop cofloop

			mov ah,0

			pop dx 				; 取出 起点相对坐标 X 或 Y
			add ax,dx
			pop dx  			; 取出 临界值


			pop bx 				; 回复 bx 是值
			cmp ax,dx
			je cofend0
				mov bh,0
				jmp cofend1
			cofend0:
				mov bh,1 		; 已达到临界值，不可移动
			cofend1:

			pop si
			pop dx
			pop cx
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

	; 上移10
	moveu:
			push bx
			mov bl,3
			call move
			pop bx
			ret
	; 下移10
	moved:
			push bx
			mov bl,2
			call move
			pop bx
			ret
			

	; 移动 
	; 参数 bl 0,1,2,3  左右上下
	; 00 01 10 11
	; 返回值 为 BH=0 可移动。 
	; 返回值 为 BH=1 达到临界，不可移动。
	move:
				; 检查边界值
				;call checkoverflow
				;cmp bh,1
				;je mvend

			push ax
			push dx
			push bx

			call backpart 		; 备份当前

			; 删除旧图形
			mov al,1
			call drawpart

			mov dl,bl
			and dl,00000001b 	; 0表示-10，1表示+10
			and bl,00000010b 	; 0表示x，1表示y
			shr bl,1

			; 若果为 y 则 将dl 取反
			cmp bl,1
			je mv4
			jmp mv5
		mv4:
			not dl
			and dl,00000001b
		mv5:

			mov bh,0
			add bx,bx
			push nextparto[bx]   	; x,y 存在 nextparto 中
			pop ax

			cmp dl,0
			je mv0
			add ax,10
			jmp mv1
		mv0:
			sub ax,10
		mv1:
			push ax
			pop nextparto[bx]

			; 显示新图形
			call setpart

			mov al,0
			call drawpart

			pop bx
			pop dx
			pop ax

		mvend:
			ret


	; 播放

	play:
			push ax
			push bx
			push cx
			push ds

			mov ax,datasg
			mov ds,ax

		ps0:
			call createpart 
			mov al,0  			; 产生新零件

			call backpart
			call updatepart
			call drawpart
			
			call delay

			pop ds
			pop cx
			pop bx
			pop ax
			ret

	; TODO
	; 旋转90度，并显示
	rotateit:
		push ax
			; 检查边界值
			;call checkoverflow
			;cmp bh,1
			;je mvend

		call rotate
		mov al,0
		call drawpart
		call delay

		pop ax

		ret



	; 顺时针旋转90度,但并不显示
	rotate:
			push ax
			push bx
			push dx
			push si
			push cx
			push di


			call backpart 		; 备份当前

			sroting0:
				;旋转90
				;mov bx,offset crlpart
				mov si,offset crlpart
				mov di,offset nextrlpart
				;mov si,0

				mov cx,0ffffh
				mov bx,0
			sroting1:
				mov al,[si]
				mov ah,[si+1]
				mov dl,0
				add dl,ah

					; 获取 x 中最小值
					cmp cl,dl
					ja rabove0
					jmp rless0
				rabove0:
					mov cl,dl 
				rless0:

				mov byte ptr [di],dl 	; 设置旋转后相对 x，存到next
				mov dl,40+20
				sub dl,al


					; 获取 y 中最小值
					cmp ch,dl
					ja rabove1
					jmp rless1
				rabove1:
					mov ch,dl 
				rless1:


				mov byte ptr [di+1],dl 	; 设置旋转后相对 y，存到next

				add si,2
				add di,2
				inc bx
				cmp bx,4
				jnz sroting1

				; 所有坐标减去 x,y 最小值，使图形最靠近原点
				mov di,offset nextrlpart
				mov bx,0
				frotate:
					mov ax,[0+di]
					mov dh,0
					mov dl,cl
					sub ax,dx
					mov [0+di],ax 	;x 

					mov ax,[1+di]
					mov dh,0
					mov dl,ch
					sub ax,dx
					add ax,10
					mov [1+di],ax 	;y

					add di,2
					inc bx
					cmp bx,4
					jnz frotate

			; 计算新绝对左边，并尝试设置
			call setpart

			pop di
			pop cx
			pop si
			pop dx
			pop bx
			pop ax
			ret

	; 创建零件
	createpart:
			push di
			push si
			push ds
			push es
			push bx
			push cx
			pushf

			mov bx,7 			; 只有0~6 号形状
			call random
			mov word ptr part[0],bx

			mov word ptr cparto[0],140
			mov word ptr cparto[2],140

			mov bx,datasg
			mov ds,bx
			mov es,bx

			mov di,part[0]
			add di,di

			mov si,table[di]
			mov di,offset crlpart
			mov cx,8
			cld
			rep movsb  					; 将基本零件形状拷贝到 crlpart 中

			call backpart 				; 备份到next
			call getnextabpart 			; 计算绝对位置
			call updatepart 			; 更新到当前

			popf
			pop cx
			pop bx
			pop es
			pop ds
			pop si
			pop di
			ret


	; 画零件
	; 参数：零件形状 part, al=0 创建 al=1删除
	drawpart:
			push ax
			push bx
			push cx
			push dx

			mov bx,0
		dp1:

			mov cx,cabpart[bx+0]
			mov dx,cabpart[bx+2]

			cmp al,0
			jne draw1
			call box
			jmp draw2
		draw1:	
			call delbox
		draw2:
			add bx,4
			cmp bx,16
			jnz dp1

			pop dx
			pop cx
			pop bx
			pop ax
			ret


	drawpart1:
			push bx
			push si
			push cx
			push dx
			push ax


			mov si,offset crlpart

			mov bx,0
		dp11:

			mov cx,cparto[0]
			mov dx,cparto[2]

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
	draw11:	
			call delbox
	draw22:
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

	; 获取指定点 CX,DX 中的颜色
	; 参数 CX,DX BH=页码 AH=0DH
	; 返回颜色：al
	getcolour:
			push bx

			mov bh,0
			mov ah,0dh		; 读像素点
			int 10h

			pop bx
			ret


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

codesg ends
end start
