汇编笔记
=======

## cpu运算器：**

	PN 结 --> 二极管/三极管 --> 逻辑门电路（与或非）--> 加法器 -->加减乘除逻辑运算

## 段地址+偏移地址：** 

	8086 CPU为16位结构。地址总线20位。
	为达到20位的寻址能力，使用两个16位地址合成20位地址。一个段地址SA，一个偏移地址EA。

	一个段 最大地址范围是 64 KB

	- 段寄存器 CS、DS、SS、ES

		CS 和 IP 合成指令地址。其值不能使用MOV改变，而是其他转移指令，如jmp

		jmp 1000:3	同时修改 CS IP

		jmp bx		修改 IP 为 BX 的值

	8086 CPU 可以将小于 64KB 的空间定义为代码段。

## debug**

	- -D   查看内存
	- -U   将内存翻译为汇编
	- -A   向内存中写入汇编指令
	- -E   修改内存内容
	- -R   查看或修改寄存器内容
	- -T   单步执行内存中的指令

	主板ROM生产日期：FFF00H ~ FFFFFH
	
	显存：B8000H ~

## 寄存器（内存访问）**

	段寄存器：DS,CS,SS,ES.
	8086 CPU 不支持将数据直接送入段寄存器。需要通用寄存器中转

	AX 累加。DIV MUL 根据长度配合 DX
	
	BX 偏移寻址。MOV AX,[BX]
	
	CX LOOP时，若CX值为0跳出，否则CX-1继续
	
	DX DIV MUL 时配合AX
## 栈**

	SS:SP
	空栈时，SS:SP指向栈空间最高地址的下一个单元。
	
	push: sp-2; 向SS:SP指向的字单元送入数据。
	
	pup: 从SS:SP指向的字单元读数据; sp+2

	一个栈最大为 SP的表示范围，64KB。
	SP 在0-FFFF中循环

	DEBUG的T命令在执行 MOV SS,* 时，它的下一条命令也紧接着被执行了

## 编译连接生产exe**

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

## loop和[BX]**

	在汇编源程序中：
		- 数据不能以字母开头（添0）
		- 指定内存单元地址有两种：
			- DS:[0]
			- [BX]  == DS:[BX]

	DEBUG 中 

		G 命令直接执行到指定地址
		
		P 命令执行完LOOP

		一般情况 0:200 ~ 0:2ff 没有使用
	

## CPU实模式和保护模式**

	在新的更大寄存器的CPU出现后。有了**实模式** 和 **保护模式**

	保护模式提供了更安全的CPU管理机制。启动保护模式前，需要准备好 GDT LDT 等。

## 包含多个段的程序**
	- 在加载程序的时候为程序分配
	- 在执行的过程向系统申请。

		assume cs:code
		code segment
			dw 0123h,0456h,0789h,0abch,0defh,0fedh,0cbah,0987h
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

## 第七章 更灵活的定位内存地址的方法**

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


## 第八章 数据处理的两个基本问题**

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

		**待加强**

	8.8 伪指令 db dw dd (byte word double) 

			data segment
				dd 100001
				dw 100
				dw 0
			data ends

			mov ax,data
			mov ds,ax
			mov ax,ds:[0]		;ds:0 字单元中的低 16 位存储在 ax 中
			mov dx,ds:[2]		;ds:2 字单元中的高16位存在dx中
			div word ptr ds:[4]	;用dx:ax中的32位数据除以ds:4字单元中的数据
			mov ds:[6],ax 		;将商存储在 ds:6 字单元中 

	8.9 dup

		db/dw/dd N dup (Value)

		定义一个200字节的栈：
		dw 200 dup (0)

		**实验7**

## 第九章 转移指令的原理
	
	- 无条件转移指令，如 jmp
	- 条件转移指令
	- 循环指令，如 loop
	- 过程
	- 中断

	### 操作符 offset （由编译器处理，取得标号的偏移地址）

		assume cs:codesg
		codesg segment
			s:	mov ax,bx
				mov si,offset s
				mov di,offset s0
				mov ax,cs:[si]
				mov cs:[di],ax
			s0:	nop		; nop 的机器码占一个字节
				nop
		codesg ends
		end s
	
	### 9.3 根据位移进行转移的 jmp 指令

		- 段内短转移 jmp short 标号 （-128 ~ 127)

			IP = IP + (8位位移)

		- 段内近转移 jmp near ptr 标号 （-32768~32767）

			IP = IP + (16位位移)

	### 9.4 转移目的地址在指令中的 jmp 指令

		jmp far ptr 标号 (实现段间转移，远转移)

	### 9.5 转移地址在寄存器中的 jmp

		jmp ax (jmp 16位reg)

	### 9.6 转移地址在内存中的jmp

		- jmp word ptr 内存单元地址（段内转移）

			jmp word ptr ds:[0]

			jmp word ptr [bx]

		- jmp dword ptr 内存单元地址（段间转移）

			功能：从内存单元地址处开始存放着两个字，高地址处段地址，地地址为偏移地址

			jmp dword ptr ds:[0]	; 将 ds:[0] 内存中的值作为 CS:IP

	### 9.7 jcxz 指令 条件转移指令 （短转移）

		jcxz 标号 （当cx 为 zero 时才跳转）

			if(cx != 0) jmp short 标号

	### 9.8 loop 指令（短转移）

		loop 标号

			(cx)--;

			if(cx != 0) jmp short 标号

	### 9.9 根据位移进行转移的意义

		相对位移，可让程序在内存中不同位置正确执行

	### 9.10 编译器对转移位移超界的检测

		debug 中使用的 jmp 2000:0100 。在源程序中编译器不认识。

		jmp short, jcxz, loop 等短转移越界会报错

	### 实验八 分析一个奇怪的程序



	### 实验九 根据材料编程 

		在屏幕中间分别显示绿色、绿底红色、白底蓝色的字符串'welcome to masm!'
## 第十章 CALL 和 RET 指令

	- ret 用栈中的数据，修改 IP 的内容，实现近转移 		[pop IP]
	- retf 用栈中的数据，修改 CS:IP 的内容，实现远转移	[pop IP pop CS]

	- call ：将当前 IP 或 CS:IP 压入栈中 ==》转移

		call 指令不能实现短转移，除此，call 和 jmp 转移的原理相同。

		- 依据位移进行转移的 call 指令 

			call 标号 == [push IP jmp near ptr 标号]

		- 转移的目的地址在指令中的 call 指令（段间转移）

			call far ptr 标号 == [push CS push IP jmp far ptr 标号]
		- 转移地址在寄存器中 call

			call 16位reg == [push IP jmp 16位reg]
		- 转移地址在内存中的 call

			- call word ptr 内存单元地址 ==[push IP jmp word ptr 内存单元地址]
			- call dword ptr 内存单元地址 == [push CS push IP jmp dword ptr 内存单元地址]

	- call 和 ret 的配合使用 （10.7）

	- mul 乘法指令
		- 两个相乘的数，都是8/16位。一个放AL/AX中。另一个放在8/16位reg或者内存byte/word单元中
		- 结果，8位乘法放AX，16位乘法高位放DX，低位AX。

		mul reg
		mul 内存单元

		**计算 100*10000** 10000 大于 255，必须做16位乘法：

			mov ax,100
			mov bx,10000
			mul bx

			结果： (ax) = 4240H, (dx) = 000FH  (F42400H) 

	- 模块化，参数和结果传递的问题

		- 少量数据，参数和结果可以存到寄存器中
		- 批量数据，存放到内存中，内存空间的首地址存放到寄存器中
		- 用栈来传递参数。（附注4）

		**寄存器冲突问题**

			子程序设计时，将子程序用到的寄存器入栈，返回前出栈

	- 实验10 编写子程序

		**未完**

	- 课程设计1

		**未完**

## 第十一章 标志寄存器 （程序状态字 PSW ）
	- 用来存储相关指令的某些执行结果
	- 用来为CPU 执行相关指令提供依据
	- 用来控制CPU相关工作方式

	### ZF 零标志位，相关指令执行结果为 0时，ZF=1，否则为0

		add, sub, mul, div, inc, or, and 等
	### PF 奇偶标志位，相关指令结果所有1的个数为偶数，PF=1，否则为0

	### SF 符号标志位，相关指令结果为负数，SF=1, 否则为0

	### CF 进位标志位，（无符号运算）向更高位进位/向更高位借位，CF=1，否则为0

	### OF 溢出标志位，（有符号运算）溢出 OF=1, 否则为0
		mov al,0f0h
		add al,78h

		结果：CF=1, OF=0
		无符号运算：0f0h+78h 有进位， CF = 1
		有符号运算：0f0h+78h 不溢出， OF = 0

	### adc 带进位加法指令 （对更大数据进行运算）

		adc A,B  ==> (A = A+B+CF)

		#### 对两个 128 位数据相加

			add128:	push ax
					push cx
					push si
					push di

					sub ax,ax

					mov cx,8
				s:	mov ax,[si]
					adc ax,[di]
					mov [si],ax
					inc si
					inc si
					inc di
					inc di
					loop s

					pop di
					pop si
					pop cx
					pop ax
					ret

	### sbb 带借位减法

		sbb A,B  ==> (A = A-B-CF)

	### cmp 比较指令（相当于减法，但不保存结果）

		根据标志寄存器得出结果

		无符号考察 ZF CF

		有符号考察 ZF SF OF

	### 检测比较结果的条件转移指令 和 cmp 配合使用

		**无符号数**

			je 		等于则转移		zf=1
			jne 	不等于			zf=0
			jb 		低于below		cf=1
			jnb 	不低于			cf=0
			ja 		高于above		cf=0 且 zf=0
			jna 	不高于			cf=1 或 zf=1

		**有符号数**

			**未完待查手册**

	### DF 方向标志和串传送指令

		串处理指令中，控制 si, di 的增减

		df=0 每次操作后 si, di 递增

		df=1 递减

		- movsb 按字节将 ds:si 内容送入 es:di, 并si,di递增/递减
		- movsw 按字
		- rep 和 movsb/movsw 配合使用

			rep movsb ==》 (s:movsb  loop s) 

			rep 根据cx的值重复执行后面的串传送指令

		#### 设置 DF

			- cld 将 DF 置 0
			- std 将 DF 置 1

	### pushf 和 popf 

		将标志寄存器压栈出栈

	### 标志寄存器在 debug 中的表示 （11.12）

	### 实验11 编写子程序
		**未完**

## 第十二章 内中断
	
	- 除法错误，比如溢出	0
	- 单步执行 			1
	- 执行 into 指令 		4
	- 执行 int 指令 		n

	### 12.2 中断处理程序

		CPU 根据中断类型码 定位 中断处理程序 ：

			CPU 通过**中断向量表**找到中断处理程序入口。

			8086PC 中断向量表存放在内存 0000:0 到 0000:03FF 的1024个单元。每个CS:IP占4字节。一共256个表项。
	### 12.4 中断过程 （由硬件自动执行）
		- 取得中断类型码
		- 标志寄存器的值入栈 pushf
		- 设置标志寄存器第8，9位的 TF, IF 的值为0
		- CS 入栈
		- IP 入栈
		- 从内存中获取入口地址，设置 CS:IP

	### 12.5 中断处理程序和 iret 指令

		编写中断处理程序：
			- 保存用到的寄存器
			- 处理中断
			- 恢复用到的寄存器
			- 用 iret 指令返回

		iret ==>  pop IP;  pop CS;  popf

		**编写0号中断处理框架**

			assume cs:code
			code segment
			start:	mov ax,cs
					mov ds,ax
					mov si,offset do0
					mov ax,0
					mov es,ax
					mov di,200h			;设置es:di指向目的地址

					mov cx,offset do0end-offset do0 ;设置长度

					cld
					rep movsb
					设置中断向量表

					mov ax,4c00h
					int 21h

			do0:	显示字符串"overflow"
					mov ax,4c00h
					int 21h

			do0end:	nop

			code ends
			end start

			"-" 是编译器识别的运算符号，两个常量减法：

				- mov ax,8-4
				- mov ax,(5+3)*5/10

			**do0 程序**
			do0:
					jmp short do0start
					db "overflow"		;不可执行代码jmp
			do0start:
					mov ax,cs
					mov ds,ax
					mov si,202h 		;设置ds:si指向字符串

					mov ax,0b800h
					mov es,ax
					mov di,12*160+36*2 	;设置es:di指向显存中间位置

					mov cx,9
			s:		mov al,[si]
					mov es:[di],al
					inc si
					add di,2
					loop s

					mov ax,4c00h
					int 21h

			do0end:	nop
			code ends
			end start
	### 12.11 单步中断 (检测到 TF 为1。则产生单步中断)
		- 取得中断类型码1；
		- 标志寄存器入栈，TF，IF 设置为0；
		- CS:IP 入栈
		- (IP)=(1*4), (CS)=(1*4+2)

	### 12.12 响应中断的特殊情况

		一般，执行完当前指令，检测到中断就响应中断。

		有些情况即便发生中断，也不响应。

		其中设置ss时。与其紧邻的下一条指令执行后才响应。

	### 实验12 编写0号中断的处理程序

		**未完待续**

## 第十三章 int 指令（int N）

	### 13.2 编写供应用程序调用的中断例程

		**未完**

	### 13.3 对 int, iret 和栈的深入理解

		**未完**

	### 13.4 BIOS 和 DOS 所提供的中断例程

		**BIOS**
			- 硬件系统的检测和初始化程序
			- 外部中断和内部中断的中断例程
			- 用于对硬件设备进行I/O操作的中断例程
			- 其他和硬件系统相关的中断例程

		和硬件设备相关的**DOS**中断例程中，一般都调用了BIOS中断例程

		int N 直接调用BIOS和DOS提供的中断例程

	### 13.5 BIOS 和 DOS 中断例程的安装过程
		— 开机后，初始化(CS)=0FFFFH, (IP)=0, FFFF:0处有条跳转指令，CPU 执行该指令后，转去执行BIOS中的硬件系统检测和初始化程序
		- 初始化程序将建立BIOS所支持的中断向量，即将BIOS提供的中断例程的入口地址登记在中断向量表中。（BIOS固化在ROM中，一直存在）
		- 硬件系统检测和初始化完成后，调用int 19h 进行操作系统引导。从此控制权交给操作系统
		- DOS 启动后，除完成其他工作外，还将它提供的中断例程装入内存，并建立相应的中断向量

	### 13.6 BIOS 中断例程应用

		中断例程中往往包括多个子程序，BIOS 和 DOS 都用 ah 来传递内部子程序编号

	### 13.7 DOS 中断例程应用

		mov ah,4ch 		;4c程序返回
		mov al,0 		;返回值
		int 21h
	### 实验13 编写应用中断例程

		**未完**

## 第十四章 端口
	
	在PC机系统中，和CPU通过总线相连的芯片除了各种存储器外，还有：
	- 各种接口卡（网卡、显卡等）上的接口芯片
	- 主板上的接口芯片，CPU通过他们对部分外设进行访问
	- 其他芯片，用来存储相关系统信息，或进行相关输入输出处理

	它们都有一组可以由CPU读写的寄存器。他们有两点相同：
	- 都和CPU总线相连
	- CPU对他们进行读或写的时候都通过控制线所在的芯片发出端口读写命令

	CPU可以直接读写3个地方的数据：
	- CPU内部的寄存器
	- 内存单元
	- 端口

	### 14.1 端口的读写
		
		CPU最多可以定位64KB个不同的端口。范围 0~65535

		对端口的读写指令只有：只能使用寄存器 AL/AX 存放数据
			- in 	读
			- out 	写

								;端口号 0~255
				in al,20h
				out 20h,al

				mov dx,3f8h 	;端口号 256~65535
				in al,dx
				out dx,al

	### 14.2 CMOS RAM 芯片
		- 70h 为地址端口
		- 71h 为数据端口
		
		比如 读取 CMOS RAM 的2号单元

			- 将2送入端口70h
			- 从端口71h读出2号单元的内容

	### 14.3 shl 和 shr 逻辑位移指令
		mov al,01001000b
		shl al,1 			; (shift left)
			- 将寄存器或内存单元中的数据向左移位
			- 将最后移出的一位写入CF
			- 最低位用0补充

		如果移动位数大于1，则必须将移动位数放在cl中
			mov al,01010001b
			mov cl,3
			shl al,cl

	### 14.4 CMOS RAM 中存储的时间信息
		
		用 BCD（4位二进制表示十进制）码存放

	### 实验14 访问 CMOS RAM

		**未完**

## 第十五章 外中断 （CPU除了运算能力，还要有I/O能力）

	- CPU 和外设通信，通过了接口芯片的**端口**作为桥梁
	- 外设输入到达，需要处理，相关芯片向CPU发出中断信息

	### 可屏蔽中断 IF

			sti 设置 IF=1
			cli 设置 IF=0

		IF=1, 时CPU相应可屏蔽中断，否则不相应

		在进入中断处理程序后，IF 设为0，屏蔽其他可屏蔽中断

	### 不可屏蔽中断 

		8086 不可屏蔽中断类型码固定为 2.

		几乎所有由外设引发的外中断，都是可屏蔽的。

	### 15.3 PC 机键盘的处理过程

		键盘按下松开都产生一个扫描码，被键盘中的一个芯片送入60h端口

		扫描码长1字节，通码第7位为0，断码第7位为1

		#### 键盘输入引发9号可屏蔽中断

			- BIOS 键盘缓冲区15个键盘输入，高字节扫描码，低字节字符码ASCII
			- 0040:17 字节存放键盘状态。shift,ctrl,alt,等等

	### 15.4 编写 int 9 中断例程
		- 键盘产生扫描码
		- 扫描码送入60h端口
		- 引发9号中断
		- CPU 执行 int 9 中断例程

		**未完**编程屏幕中间显示a-z中间有间隔，esc改变颜色

		**注意设置IF，屏蔽其他中断**

		改写int9中断例程。保存原来int9地址，调佣它以完成其他硬件细节

	### 15.5 安装新的 int 9 中断例程

		**未完**

		端口和中断机制，是CPU进行IO的基础

	### 实验15 安装新的 int 9 中断例程

		**未完**

	### 指令系统总结
		- 数据传送指令

			mov, push, pop, pushf, popf, xchg 等实现寄存器和内存、寄存器和寄存器间的单个数据传送

		- 算数运算指令

			add, sub, adc, sbb, inc, dec, cmp, imul, idiv, aaa 等都是算数运算指令。执行结果影响 SF,ZF,OF,CF,PF,AF

		- 逻辑指令

			and, or, not, xor, test, shl, shr, sal, sar, rol, ror, rcl, rcr 等，除了not外，其他执行结果都影响相关标志位

		- 转移指令

			修改 IP, 或同时修改 CS:IP

			- 无条件转移指令，如：	jmp
			- 条件转移指令，如： 	jcxz, je, jb, ja, jnb, jna
			- 循环指令，如：		loop
			- 过程，如： 			call, ret, retf
			- 中断，如： 			int, iret

		- 处理机控制指令

			对标识寄存器或其他处理机状态设置，如：cld, std, cli, sti, nop, clc, cmc, stc, hlt, wait, esc, lock

		- 串处理指令

			对内存中的批量数据处理，如：movsb, movsw, cmps, scas, lods, stos 配合 rep, repe, repne 等前缀

## 第十六章 直接定址表

	### 16.1 描述了单元长度的标号
		
		a db 1,2,3,4,5,6,7,8
		b dw 0

		a,b代表一个段中的内存单元，标记了单元的地址和长度

	### 16.2 在其他段中使用数据标号

		- 在代码段以外的其他段中不能使用“:”的地址标号
		- 如要再代码段中直接用数据标号访问数据，则assume需将标号所在段和段寄存器联系起来。

		数据标号c处存储a,b的偏移地址：(c dw offset a,offset b)
			data segment
				a db 1,2,3,4,5,6,7,8
				b dw 0
				c dw a,b
			data ends

			若使用 dd 则存 段地址+偏移地址
			(c dd a,b) == (c dw offset a,seg a,offset b,seg b)

	### 16.3 直接定址表

		table db '0123456789ABCDEF' 	;0~15对应'0'~'F'

			- 为了算法清晰和简洁
			- 为了加快运算速度
			- 为了使程序易于扩充

			乘除执行时间大约是加法比较等指令的5倍

	### 16.4 程序入口地址的直接定址表

		在直接定址表中存放子程序的地址。从而方便调用

	### 实验16 编写包括多个功能的子程序的中断例程

		**未完**

## 第十七章 使用 BIOS 进行键盘输入和磁盘读写

	### 17.1 int 9 中断例程对键盘输入的处理

		键盘缓冲区  和  键盘状态字节

	### 17.2 使用 int 16h 中断例程读取键盘缓冲区

		mov ah,0

		int 16h

		int 16h 中功能编号0：从键盘缓冲区读取一个键盘输入

			- 检测键盘缓冲区中是否有数据
			- 没有则继续做第一步
			- 读取缓冲区第一个字单元中的键盘输入
			- 将读取的扫描码送入ah,ASCII码送入al
			- 将已读取的键盘输入从缓冲区删除

		BIOS 的 int 9 中断和 int 16h 中断是一对互相配合的程序

			- int 16h 是在应用程序调用时读取数据
			- int 9h 是键盘按下

	### 17.3 字符串的输入

		**未完**

	### 17.4 应用 int 13h 中断对磁盘进行读写

		**未完**

	### 实验17 编写包含多个功能子程序的中断例程

		**未完**

	### 课程设计2

		**未完**
## 综合研究
	- 认识到汇编语言对于深入理解其他领域知识的重要性
	- 对前面学习的汇编知识进行融汇
	- 对用研究的方法进行学习进行体验























