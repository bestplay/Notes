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

	;HEIGHTY equ 240 				; 屏幕高度
	;WIDTHX equ 160 					; 屏幕宽度
	HEIGHTY equ 480 				; 屏幕高度
	WIDTHX equ 320 					; 屏幕宽度
	oldint9 dw 0,0					; 原来的int9处理例程地址

	drawflag db 0 					; 画图标志 1表示正在画图

	boxpoint db WIDTHX/10*HEIGHTY/10 dup (0) 	; 屏幕所有盒子点位。1表示有，0表示空

	part0 db 0,10,0,20,0,30,0,40 	; 4组(x,y)。七种基本零件初始形状
	part1 db 0,10,0,20,0,30,10,10
	part2 db 0,10,0,20,10,10,20,10
	part3 db 0,10,0,20,10,10,10,20
	part4 db 0,10,10,10,10,20,20,20
	part5 db 0,10,0,20,10,20,10,30
	part6 db 0,10,10,10,10,20,20,10

	table dw part0,part1,part2,part3,part4,part5,part6

	; 变形动作程序入口表
	actiontable dw movel,mover,moveu,moved,rotateit

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
			call drawsplit
		startnewgame:
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

	; 游戏结束
	gameover:
		push cx
		push si
			mov drawflag[0],1
			mov cx,3
			gameoverloop0:
				call hideallbox
				call delay
				call showallbox
				call delay
			loop gameoverloop0

			mov si,0
			mov cx,WIDTHX/10*HEIGHTY/10
			gameoverloop1:
				mov byte ptr boxpoint[si],0
				inc si
			loop gameoverloop1



			call checkfullline
			call showallbox
			call createpart 

			mov drawflag[0],0
		pop si
		pop cx
		ret 



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
			push dx

			in al,60h

			pushf 
			pushf
			pop bx
			and bh,11111100b
			push bx
			popf
			call dword ptr oldint9[0] 	; 调用原 int9

			cmp al,1
			je exit 			; ESC 退出

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

			jmp int9ret 		; 其他按键直接忽略

	; <- 向左
	intleft:
			mov bx,0
			jmp int9doorpush
	; -> 向右
	intright:
			mov bx,2
			jmp int9doorpush
	; 向上
	intup:	
			mov bx,4
			jmp int9doorpush
	; 向下
	intdown:
			mov bx,6
			jmp int9doorpush
	; 旋转
	introtate:		
			mov bx,8
		int9doorpush:

			; 调用相应的 action
			mov al,drawflag[0]
			cmp al,1
			je int9ret					; 正在画图，任务放到队列
			call word ptr actiontable[bx] 	; 不在画图，直接执行任务

	int9ret:
			pop dx
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
			call getnextabpart

			; TODO 检测越界
			call checkcollision
			cmp al,0
			jne setpartret

			call updatepart

		setpartret:
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

			mov al,[bx+si+1]
			sub dx,ax


				; 检测 坐标是否有效

				cmp cx,WIDTHX-10
				ja overflowpoint0

				cmp cx,0
				jb overflowpoint0 

				cmp dx,HEIGHTY-10
				ja overflowpoint2

				cmp dx,0
				jb overflowpoint2 

			mov nextabpart[di],cx
			mov nextabpart[di+2],dx

			jmp overflowpoint1

		overflowpoint0:
			mov nextabpart[di],0ffffh
			jmp overflowpoint1
		overflowpoint2:
			mov nextabpart[di+2],0ffffh
		overflowpoint1:

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

				mov di,0
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
						cmp ax,WIDTHX-5
						ja ccsoverflow
						add ax,10  				; 防止负数
						cmp ax,10-5
						jb ccsoverflow 

						cmp dx,HEIGHTY-5
						ja ccsoverflow
						

						;add dx,10 				; 防止负数
						;cmp dx,10-5
						;jb ccsoverflow 



						; 检测新坐标是否被占用
						push cx
						mov cx,nextabpart[si]
						mov dx,nextabpart[si+2]

						call getcolour

						pop cx

						cmp al,0
						jne ccsoverflow

							;cmp al,14
							;je ccsoverflow
							;cmp al,9
							;je ccsoverflow


				; ----------- check end



		ccsnext: 	;开始下一个坐标的检测

			add si,4
			loop ccsloop0
			; 所有新坐标通过检测
			mov al,0 
			jmp ccsret

		ccsoverflow:
			mov al,1

		ccsret:
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			ret

	; 检查是否有放满的行，满则得分
	; 返回值： CL=1 则 表示有改动，需要重新刷新显示
	checkfullline:
			push ax
			push bx
			;push cx
			push dx
			push si

			mov cl,0

			mov bx,0
			mov si,0
			mov dx,0
			checklineloop0:

				mov ax,si
				mov ah,10
				mul ah

				;mov cx,ax

				mov al,boxpoint[bx+si]
				cmp al,0
				je checklinenextline
			
				inc si
				cmp si,WIDTHX/10
			jb checklineloop0

				; 检测到放满的行：
				mov cl,1
				mov al,dl
				call deleteline


		checklinenextline:

			add bx,WIDTHX/10
			mov si,0
			inc dl
			cmp bx,(HEIGHTY/10)*WIDTHX/10
			jb checklineloop0

			;call showallbox

			pop si
			pop dx
			;pop cx
			pop bx
			pop ax
			ret

	; TODO 删除一行盒子
	;参数 al， 要删除的行数
	deleteboxline:
			push ax
			push bx
			push si

				mov ah,WIDTHX/10
				mul ah
				mov bx,ax 				; 删除行

				mov si,0
				dellineloop0:
					mov boxpoint[bx+si],0
					inc si
					cmp si,WIDTHX/10
					jb dellineloop0
			pop si
			pop bx
			pop ax

			ret

	;参数 al， 要删除的行数

	deleteline:
			push ax
			push cx
			push si
			push di
			push ds
			push es

			call deleteboxline


			mov ah,WIDTHX/10
			mul ah
			dec ax
			mov si,offset boxpoint
			mov cx,ax
			add si,ax
			mov di,si
			add di,WIDTHX/10

			mov ax,datasg
			mov ds,ax
			mov es,ax

			std
			rep movsb

			mov al,0
			call deleteboxline  		; 删除第一行

			pop es
			pop ds
			pop di
			pop si
			pop cx
			pop ax

			ret

	; 显示所有盒子
	hideallbox:
			push ax
			push bx
			push cx
			push dx
			push si

			mov bx,0
			mov si,0
			mov dx,0
			hideboxloop0:

				mov ax,si
				mov ah,10
				mul ah

				mov cx,ax

				call delbox

				inc si
				cmp si,WIDTHX/10
			jb hideboxloop0

			add bx,WIDTHX/10
			add dx,10
			mov si,0
			cmp bx,(HEIGHTY/10)*WIDTHX/10
			jb hideboxloop0

			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			ret

	; 显示所有盒子
	showallbox:
			push ax
			push bx
			push cx
			push dx
			push si

			mov bx,0
			mov si,0
			mov dx,0
			showboxloop0:

				mov ax,si
				mov ah,10
				mul ah

				mov cx,ax

				mov al,boxpoint[bx+si]
				cmp al,0
				je showabdel

				call box
				jmp showboxnext
			showabdel:
				call delbox

				showboxnext:
				inc si
				cmp si,WIDTHX/10
			jb showboxloop0

			add bx,WIDTHX/10
			add dx,10
			mov si,0
			cmp bx,(HEIGHTY/10)*WIDTHX/10
			jb showboxloop0

			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			ret

	; 保存坐标
	saveboxpoint:
			push ax
			push bx
			push dx
			push si
			push ds

			mov ax,datasg
			mov ds,ax

			mov si,0
		saveboxloop:
			mov ax,cabpart[si]
			mov bl,10
			div bl
			mov dl,al 					; x 存dl

			mov ax,cabpart[si+2]
			mov bl,10
			div bl
			mov dh,al 					; y 存dh

			mov ah,WIDTHX/10
			mov al,dh
			mul ah
			mov dh,0
			add ax,dx
			mov bx,ax
			mov byte ptr boxpoint[bx],1

			add si,4
			cmp si,16
			jb saveboxloop

			pop ds
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
			push ax
			push si

			mov dl,0

			mov bl,2
			call move
			cmp dl,1 	; 下移到底，创建新的零件
			jne movedend

			; 若此时已到顶点，则 GAMEOVER

				mov si,0
			movedloop0:
				mov ax,cabpart[si+2]
				cmp ax,0
				jb movedgameover
				cmp ax,HEIGHTY-10
				ja movedgameover

				add si,4
				cmp si,16
				jb movedloop0

				
			jmp movedgoon
			movedgameover:
				call gameover
				jmp movedend
			movedgoon:

			; 若当前零件原点在最上面，则不保存当前坐标到 boxpoint
			cmp word ptr cparto[2],0
			jna movedrefreshed
				; 保存当前零件盒子坐标到 boxpoint
				call saveboxpoint
				call checkfullline
				cmp cl,1
				jne movedrefreshed
				call showallbox
		movedrefreshed:
			; TODO
			call createpart
			movedend:

			pop si
			pop ax
			pop bx
			ret
			

	; 移动 
	; 参数 bl 0,1,2,3  左右上下
	; 00 01 10 11
	; 返回值 为 DL=0 可移动。 
	; 返回值 为 DL=1 达到临界，不可移动。
	move:
				; 检查边界值
				;cmp bh,1
				;je mvend

			push ax
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
			mov dl,al

			mov al,0
			call drawpart

			pop bx
			pop ax

		mvend:
			ret



	; 播放

	play:
			push ax
			push bx
			push cx
			push ds

			call createpart 

			; 主循环
		mainloop0:
			call moved
			call delay
			jmp mainloop0

			pop ds
			pop cx
			pop bx
			pop ax
			ret

	; TODO
	; 旋转90度，并显示
	rotateit:
		push ax

		mov al,1
		call drawpart

		call rotate
		mov al,0
		call drawpart

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
					add ax,10 		;y最小为10
					sub ax,dx
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
			mov drawflag[0],1
			push di
			push si
			push ds
			push es
			push bx
			push cx
			pushf
			push ax

		createpartstart:
			mov bx,7 			; 只有0~6 号形状
			call random
			mov word ptr part[0],bx

			mov bx,WIDTHX/10 			; 0~310 X 坐标
			call random
			mov al,bl
			mov ah,10
			mul ah
			mov word ptr cparto[0],ax
			mov word ptr cparto[2],0

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


				mov si,0

			createpartloop0:

				mov ax,nextabpart[si]
				cmp ax,WIDTHX-10
				ja createpartstart

				add si,4
				cmp si,16
				jb createpartloop0


			call updatepart 			; 更新到当前

			pop ax
			popf
			pop cx
			pop bx
			pop es
			pop ds
			pop si
			pop di
			mov drawflag[0],0
			ret

	; 画零件
	; 参数：零件形状 part, al=0 创建 al=1删除
	drawpart:
			push ax
			push bx
			push cx
			push dx

			mov byte ptr drawflag[0],1 			; 开启标志

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

			mov byte ptr drawflag[0],0 			; 关闭标志
			pop dx
			pop cx
			pop bx
			pop ax
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
	; 画分割线
	drawsplit:
			push dx
			push cx
			push ax

			mov dx,0	
			mov cx,WIDTHX+1
			mov al,15
		dsplitloop0:
			call point
			inc dx
			cmp dx,HEIGHTY
			jb dsplitloop0


		mov dx,	HEIGHTY
		mov cx,0
		mov al,15
		dsplitloop1:
			call point
			inc cx
			cmp cx,WIDTHX+2
			jb dsplitloop1

			pop ax
			pop cx
			pop dx
			ret



	; 显示所有颜色
	listcolour:
			push dx
			push cx
			push ax
			push bx

			mov dx,0
	lcdo0:
			mov cx,WIDTHX+10
			mov al,0
	lcdo1:
			mov ah,19 	; 每个颜色画长度8
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
			cmp dx,20
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

				; 检测 坐标是否有效

				cmp cx,0ff00h
				ja boxend

				cmp dx,0ff00h
				ja boxend 


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

		boxend:
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

			;mov dx,1000h   ;;循化10000000h次
			mov dx,10h   ;;循化10000000h次
			mov ax,8h
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
