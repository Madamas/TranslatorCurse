.386; asdadsfasdfsadf
Data Segment
vars db "dbstring"
ddVar dd .13f12423h
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
	mov eax, 22h
	mov kvar, 25h
	mov ah, kvar
	;cmp eax, kvar[eax]
	jcxz near ptr labl1
	idiv bh
	mov ebx,eax
	idiv ebx
	mov bl,al
	idiv al
	xchg byte ptr [ebx*4+eax+6], al
	xchg byte ptr [ebx*4+eax+6], ecx
	idiv eax
	lable:
	int 21h
Code ends
end
; : is divider
; space isn't divider
; db and near/far aren't the same
; const char add