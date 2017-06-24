;.386
Data segment
vars db "dbstring"
ddVar dd 13f13h
dwvar dw 23h
kvar = 1fh
Data ends
Code segment
;assume cs:Code, ds:Data
	labl1:
	int "h"
	cli
	mov esi, 23h
	cmp eax, [esi*4h+edi+8h]
	jcxz
	xor byte ptr [ebx+ebx*2h+4h], kvar
	xor gs:[ebx*4h+ebx+6h],2222h
	mov eax, 22h
	kvar = 25h
	mov ah, kvar
	jcxz
	idiv bh
	mov ebx,eax
	idiv ebx
	mov bl,al
	mov eax,ebx
	mov ecx,al
	mov al,edx
	idiv al
	mov eax,25h
	mov eax,kvar
	mov eax,labl1
	;kvar = "kekek"
	kvar = "k"
	xor dwvar,kvar
	xor byte ptr dwvar,kvar
	xor dword ptr dwvar,kvar
	;xor dwvar,labl1
	;mov al, vars
	;mov al, dwvar
	xor gs:[ebx*4h+ebx+6h],2222h
	xchg ddVar,al
	xchg ddVar,eax
	xchg dword ptr ddVar,al
	xchg byte ptr ddVar,eax
	xchg [ebx*4h+ebx+6h], al
	xchg [ebx*4h+ebx+6h], ecx
	xchg byte ptr es:[ebx*4h+ebx+6h], ecx
	xchg es:[ebx*4h+ebx+6h], al
	xchg ds:[ebx*4h+ebx+6h], ecx
	xchg byte ptr [ebx*4h+ebx+66666h], al
	xchg dword ptr [ebp*4h+eax+6h], ecx
	xchg byte ptr [ebx*4h+ebx+6h], ecx
	xchg dword ptr [ebp*4h+eax+6h], al
	;xor byte ptr dwvar,"string"
	;xor dword ptr dwvar,"string"
	xor dwvar, 2222h
	xor byte ptr dwvar, 22h
	xor dword ptr dwvar, 22h
	xor dwvar,kvar
	xor byte ptr dwvar,kvar
	xor byte ptr dwvar,"2"
	xor dword ptr dwvar,kvar
	xor dword ptr dwvar,"22"
	xor dword ptr gs:[ebx*4h+ebx+66h],22h
	xor dword ptr gs:[ebx*4h+ebx+66h],"2"
	cmp al,ddVar
	cmp al,gs:[ebx*4h+ebx+66666h]
	cmp eax,gs:[ebx*4h+ebx+66666h]
	cmp eax,ddVar
	idiv eax
	lable:
	int byte ptr 21h
	kvar = 22h
	int kvar
Code ends
end
; : is divider
; space isn't divider
; db and near/far aren't the same
; const char add
; short near unneeded
; text const as imm