汇编笔记
=======

- **cpu运算器：**

	PN 结 --> 二极管/三极管 --> 逻辑门电路（与或非）--> 加法器 -->加减乘除逻辑运算

- **段地址+偏移地址：** 

	8086 CPU为16位结构。地址总线20位。
	为达到20位的寻址能力，使用两个16位地址合成20位地址。一个段地址SA，一个偏移地址EA。

	一个段 最大地址范围是 64 KB

	- 段寄存器 CS、DS、SS、ES

		CS 和 IP 合成指令地址。其值不能使用MOV改变，而是其他转移指令，如jmp

		jmp 1000:3	同时修改 CS IP

		jmp bx		修改 IP 为 BX 的值

	8086 CPU 可以将小于 64KB 的空间定义为代码段。

- **debug**

	- -D   查看内存
	- -U   将内存翻译为汇编
	- -A   向内存中写入汇编指令
	- -E   修改内存内容
	- -R   查看或修改寄存器内容
	- -T   单步执行内存中的指令

	主板ROM生产日期：FFF00H ~ FFFFFH
	
	显存：B8000H ~

- **寄存器（内存访问）**

	段寄存器：DS,CS,SS,ES.
	8086 CPU 不支持将数据直接送入段寄存器。需要通用寄存器中转

	AX 累加。DIV MUL 根据长度配合 DX
	
	BX 偏移寻址。MOV AX,[BX]
	
	CX LOOP时，若CX值为0跳出，否则CX-1继续
	
	DX DIV MUL 时配合AX
- **栈**

	SS:SP
	空栈时，SS:SP指向栈空间最高地址的下一个单元。
	
	push: sp-2; 向SS:SP指向的字单元送入数据。
	
	pup: 从SS:SP指向的字单元读数据; sp+2

	一个栈最大为 SP的表示范围，64KB。
	SP 在0-FFFF中循环

	DEBUG的T命令在执行 MOV SS,* 时，它的下一条命令也紧接着被执行了

- **编译连接生产exe**

	exe 中的机器码包含两部分信息：
		- 描述信息（程序的大小等）
		- 程序部分

	exe 载入内存的过程：
		- 找到足够空间的连续内存区域
		- 在开头的256字节中创建 PSP（与DOS通信）
		- 在 SA+10H:0 将程序装入
		(**CX中存放程序的长度**)
		- 设置 DS=SA，CS:IP->SA+10H:0

		空闲内存区：SA:0
			PSP 区：SA:0
			程序区：SA+10H:0

- **loop和[BX]**

在汇编源程序中：
	- 数据不能以字母开头（添0）
	- 指定内存单元地址有两种：
		- DS:[0]
		- [BX]  == DS:[BX]

DEBUG 中 

	G 命令直接执行到指定地址
	
	P 命令执行完LOOP

	一般情况 0:200 ~ 0:2ff 没有使用
	

- **CPU实模式和保护模式**

	cpu 加电后进入实模式，操作系统接管并加载 GDT，LDT 后，进入保护模式

	GDT LDT 

- **多个段的程序**

		assume cs:code
		code segment
			dw 0123h,0456h,0789,0abch,0defh,0fedh,0cbah,0987h

			start:	mov bx,0
					mov ax,0

					mov cx,8
				s:	add ax,cs:[bx]
					add bx,2
					loop s

					mov ax,4c00h
					int 21h
		code ends
		end start
	'end 标号' 指明程序的开始，和结束位置

	[利用多个段，让程序中的数据逆序存放]：段名标号代表了段地址的立即数

		assume cs:code,ds:data,ss:stack

		data segment
			dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
		data ends

		stack segment
			dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		stack ends

		code segment

		start:	mov ax,stack
				mov ss,ax
				mov sp,20h
				mov ax,data
				mov ds,ax
				mov bx,0
				mov cx,8
			s:	push [bx]
				add bx,2
				loop s

				mov bx,0
				mov cx,8

			s0:	pop [bx]
				add bx,2
				loop s0

				mov ax,4c00h
				int 21h

		code ends
		end start

	一个 segment 占用空间最小粒度为 16 字节

- **第七章 更灵活的定位内存地址的方法**

	and 和 or 与或
	
	mov ax,[200+bx]		为高级语言实现数组提供了便利。

		C 语言：a[i], b[i]
		汇编： 0[bx], 5[bx]

	- SI 和 DI 	

	[bx+si] 和 [bx+di]
	[bx+si+idata] 和 [bx+di+idata]

	- 问题 7.6 将 datasg 段中每个单词的头一个字母改为大写字母

		循环嵌套，保存 cx 值，还原 cx 值. 可以保存到 内存 中

		**一般来说，需要暂存数据的时候，都应该使用栈**


- **第八章 数据处理的两个基本问题**

	（1）处理的数据在什么地方（2）要处理的数据有多长

	bx si di 和 bp 四个寄存器 可以用 [...] 来进行内存单元的寻址

	[bx/bp + si/di]

	bp 默认段地址为 ss

	8.2 要处理的数据：1. CPU 内部 2. 内存 3. 端口

	8.3 汇编中数据位置的表达：

		（1）立即数 （执行前在 CPU 的指令缓冲器中）
		（2）寄存器
		（3）段地址（SA）和偏移地址（EA）（内存中）

	8.4 寻址方式

		直接寻址：		[idata]
		寄存器间接寻址：	[bx] [si] [di] [bp]
		寄存器相对寻址：	[bx+idata] [si+idata] [di+idata] [bp+idata]
		基址变址寻址：		[bx+si] [bx+di] [bp+si] [bp+di]
		相对基址变址：		[bx+si+idata] [bx+di+idata] [bp+si+idata] [bp+di+idata]

	8.5 指令要处理的数据有多长 byte 和 word

		(1) 通过寄存器名指明 ： 16位寄存器指明 word，8 为寄存器指明 byte
		(2) 使用 word/byte ptr 指明内存单元长度
			mov word ptr ds:[0],1
			mov byte ptr ds:[0],1
		(3) 其他 
			push 只进行字操作

	8.6 寻址方式的综合应用
		**跳过**

	8.7 div 指令

		除数：8 / 16 位

		被除数：16 / 32 位 。存 AX，不够时用 DX 存高位

		结果：AL / AX 存商。 AH / DX 存余数 

		










