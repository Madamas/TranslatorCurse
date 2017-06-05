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
	cmp eax, [esi+edi*4h+8h]
	jcxz lable
	xor byte ptr [eax+ebx*2h+4h], kvar
	mov eax, 22h
	kvar = 25h
	mov ah, kvar
	jcxz labl1
	idiv bh
	mov ebx,eax
	idiv ebx
	mov bl,al
	idiv al
	mov al, vars
	xchg byte ptr [ebx*4h+eax+6h], al
	xchg byte ptr [ebx*4h+eax+6h], ecx
	idiv eax
	lable:
	int 21h
Code ends
end
; : is divider
; space isn't divider
; db and near/far aren't the same
; const char add
; short near unneeded
; text const as imm