.386
Data segment
vars db "dbstring"
ddVar dd 13f13h
dwvar dw 23h
kvar = 1fh
Data ends
Code segment
assume cs:Code, ds:Data
	labl1:
	cli
	mov esi, 23h
	cmp eax, [esi*4h+edi+8h]
	jcxz
	xor byte ptr [ebx+ebx*2h+4h], kvar
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
	xchg byte ptr [ebx*4h+ebx+6h], al
	xchg dword ptr [ebp*4h+eax+6h], ecx
	idiv eax
	lable:
	int byte ptr 21h
	kvar = 22h
	int kvar
	int "asdsadah"
Code ends
end
; : is divider
; space isn't divider
; db and near/far aren't the same
; const char add
; short near unneeded
; text const as imm