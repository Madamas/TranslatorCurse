.386; asdadsfasdfsadf ; ;
Data Segment
vars db "dbstring"
ddVar dd 13f12423h
dwvar dw 23h
kvar = 1fh
Data ends
Code Segment
	labl1:
	cli
	mov esi, 23h
	cmp eax, [esi+edi*4+8]
	jcxz short lable
	xor byte ptr [eax+ebx*2+4], kvar
	xor ddvar, 22h
	mov eax, 22h
	mov ah, kvar
	cmp eax, kvar[eax]
	jcxz near ptr labl1
	idiv bh
	mov ebx,eax
	idiv ebx
	mov bl,al
	idiv al
	xchg byte ptr [ebx*4+eax+6], al
	idiv eax
	lable:
	int 21h
Code ends
end