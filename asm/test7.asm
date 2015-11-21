; 求出 Power idea 公司从1975年到1995年的人均收入
; 已知公司各年的年收入、雇员人数如下


assume cs:codesg

data segment
	db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
	db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
	db '1993','1994','1995'
	; 以上是表示21年的21个字符串

	dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
	dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
	;以上是表示21年公司总收入的21个dword型数据

	dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226,11542,14430,15257,17800
	;以上是表示21年公司雇员人数的21个word型数据

data ends

table segment
	db 21 dup ('year summ ne ?? ')
table ends

codesg segment
	
start: 	mov ax,data
		mov ds,ax

		mov ax,table
		mov es,ax

		; 准备最外层 21 次循环
		mov cx,21
		mov bx,0
		mov di,0
		mov bp,0

s0:		
		; 存入年份
		mov ax,ds:[bp+0]
		mov es:[bx+0],ax
		mov ax,ds:[bp+2]
		mov es:[bx+2],ax

		; 存入公司年收入
		mov ax,ds:[bp+84]
		mov es:[bx+5],ax

		mov dx,ds:[bp+86]
		mov es:[bx+7],dx

		; 求出平均收入
		div word ptr ds:[di+168]
		mov es:[bx+13],ax


		; 存入公司年雇员人数
		mov ax,[di+168]
		mov es:[bx+10],ax



		add bp,4
		add bx,10h
		add di,2

		loop s0

		mov ax,4c00h
		int 21h

codesg ends
end start