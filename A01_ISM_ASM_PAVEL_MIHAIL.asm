.model large

MyDataSeg SEGMENT
	sum dw ?
	vect_1 dw 7, -2, 9, 11
	n1 dw 4 ;$-vect (deplas curent - size vect)
	vect_2 dw 2, -14, 12, 13, 8
	n2 dw 5
	vect_3 dw -1 , -2, -3
	n3 dw 3
MyDataSeg ENDS

MyStack SEGMENT
	dw 16 dup(3) ;32 octeti plini cu 3
	endstack label word			;word->16 biti
MyStack ENDS


MyMainP SEGMENT
	ASSUME CS:MyMainP, DS: MyDataSeg, SS:MyStack
start:
	; init segment registers
	mov AX, seg MyDataSeg
	mov DS, AX
	mov AX, seg MyStack
	mov SS, AX
	mov SP, offset endstack		;pun 32 in sp adica iau capul stivei dupa cele 16 val de 3
		
	; prepare procedure call by pushing params on the stack
	; void addv(short int* sum, short int n, short int* vect)
	mov AX, seg vect_1
	push AX
	mov AX, offset vect_1			;offset vect = 2 deoar sum e decalr inainte
	push AX
	
	mov AX, n1
	push AX
	
	mov AX, seg sum
	push AX
	mov AX, offset sum
	push AX

	; off sum,seg sum,val n1,off vect_1,seg vect_1
	CALL FAR PTR addv			;apelare proc 	;dupa call(aka in proc) off IPcurr,seg MyMainP,off sum,seg sum,val n,off vect,seg vect

	mov AX, seg vect_2
	push AX
	mov AX, offset vect_2
	push AX
	
	mov AX, n2
	push AX
	
	mov AX, seg sum
	push AX
	mov AX, offset sum
	push AX

	; off sum,seg sum,val n2,off vect_2,seg vect_2
	CALL FAR PTR addv

	mov AX, seg vect_3
	push AX
	mov AX, offset vect_3
	push AX
	
	mov AX, n3
	push AX
	
	mov AX, seg sum
	push AX
	mov AX, offset sum
	push AX

	; off sum,seg sum,val n3,off vect_3,seg vect_3
	CALL FAR PTR addv
	
	mov AX, 4c00H
	int 21h
MyMainP ENDS


MyProcs SEGMENT
	ASSUME CS:MyProcs
addv PROC FAR
;dupa call stiva: off IPcurr, seg MyMainP, off sum, seg sum,val n, off vect, seg vect
	;std. prolog
	push BP
	mov BP, SP
	
	;save regs
	push AX 					;salvez registrii
	push CX 					;salvez registrii
	push SI 					;salvez registrii
	push BX 					;salvez registrii
	push DX 					;salvez registrii

	xor AX, AX
	mov CX, SS:[BP+10]			;punem n
	mov SI, 0
	; prepare pointer vect = @vect from stack = seg:offset
	mov BX, SS:[BP+12]			;punem off vect
	mov AX, SS:[BP+14]			;punem @vect (pointer la vector)
	mov DS, AX
	
	xor AX, AX					;clear AX for sum
	while_label:
		add AX, DS:[BX][SI]		;add AX, DS:[BX+SI]
		add SI, 2
	loop while_label
	
	; place value from AX into DS for sum
	;mov DS:[0000], AX
	mov BX, SS:[BP+6]			;punem off sum
	mov DX, SS:[BP+8]			;punem seg sum
	mov DS, DX
	
	mov DS:[BX], AX				;scriu suma
	
	;restore regs
	pop DX						;restaurez registrii
	pop BX						;restaurez registrii
	pop SI						;restaurez registrii
	pop CX						;restaurez registrii
	pop AX						;restaurez registrii
	
	;std. epilog
	pop BP
	retf 10 ;pt a curata stiva de var transmise prin parametrii proc
addv ENDP	
MyProcs ENDS
end start