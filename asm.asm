;.386
Data Segment
vars db "dbstring"
ddVar dw 13f12423h
dwvar dw 23h
kvar = 1fh
Data ends
Code Segment
;assume cs:Code, ds:Data
	labl1:
	cli
	mov esi, 23h
	cmp eax, [esi+edi*4h+8h]
	jcxz
	xor byte ptr [eax+ebx*2h+4h], kvar
	mov eax, 22h
	kvar = 25h
	mov ah, kvar
	jcxz
	idiv bh
	mov ebx,eax
	idiv ebx
	mov bl,al
	idiv al
	;mov al, vars
	;mov al, dwvar
	xchg byte ptr [ebx*4h+eax+6h], al
	xchg dword ptr [ebx*4h+eax+6h], ecx
	idiv eax
	lable:
	int 21h
	int "h"
	int lable
	mov al,ecx
Code ends
end
; : is divider
; space isn't divider
; db and near/far aren't the same
; const char add
; short near unneeded
; text const as imm