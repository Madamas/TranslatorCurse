".386" wrong_lexem

"data" identifier
" " single_char
"segment" segment

"vars" identifier
" " single_char
"db" type
" " single_char
"dbstring" identifier

"ddvar" identifier
" " single_char
"dd" type
" " single_char
".13f12423h" wrong_lexem

"dwvar" identifier
" " single_char
"dw" type
" " single_char
"23h" hexadecimal

"kvar" identifier
" " single_char
"=" single_char
" " single_char
"1fh" hexadecimal

"data" identifier
" " single_char
"ends" segment

"code" identifier
" " single_char
"segment" segment

"labl1:" identifier

"cli" command

"mov" command
" " single_char
"esi" reg32
"," single_char
" " single_char
"23h" hexadecimal

"cmp" command
" " single_char
"eax" reg32
"," single_char
" " single_char
"[" single_char
"esi" reg32
"+" single_char
"edi" reg32
"*" single_char
"4" identifier
"+" single_char
"8" identifier
"]" single_char

"jcxz" command
" " single_char
"short" type
" " single_char
"lable" identifier

"xor" command
" " single_char
"byte" type
" " single_char
"ptr" operator
" " single_char
"[" single_char
"eax" reg32
"+" single_char
"ebx" reg32
"*" single_char
"2" identifier
"+" single_char
"4" identifier
"]" single_char
"," single_char
" " single_char
"kvar" identifier

"mov" command
" " single_char
"eax" reg32
"," single_char
" " single_char
"22h" hexadecimal

"mov" command
" " single_char
"kvar" identifier
"," single_char
" " single_char
"25h" hexadecimal

"mov" command
" " single_char
"ah" reg8
"," single_char
" " single_char
"kvar" identifier

"cmp" command
" " single_char
"eax" reg32
"," single_char
" " single_char
"kvar" identifier
"[" single_char
"eax" reg32
"]" single_char

"jcxz" command
" " single_char
"near" type
" " single_char
"ptr" operator
" " single_char
"labl1" identifier

"idiv" command
" " single_char
"bh" reg8

"mov" command
" " single_char
"ebx" reg32
"," single_char
"eax" reg32

"idiv" command
" " single_char
"ebx" reg32

"mov" command
" " single_char
"bl" reg8
"," single_char
"al" reg8

"idiv" command
" " single_char
"al" reg8

"xchg" command
" " single_char
"byte" type
" " single_char
"ptr" operator
" " single_char
"[" single_char
"ebx" reg32
"*" single_char
"4" identifier
"+" single_char
"eax" reg32
"+" single_char
"6" identifier
"]" single_char
"," single_char
" " single_char
"al" reg8

"xchg" command
" " single_char
"byte" type
" " single_char
"ptr" operator
" " single_char
"[" single_char
"ebx" reg32
"*" single_char
"4" identifier
"+" single_char
"eax" reg32
"+" single_char
"6" identifier
"]" single_char
"," single_char
" " single_char
"ecx" reg32

"idiv" command
" " single_char
"eax" reg32

"lable:" identifier

"int" command
" " single_char
"21h" hexadecimal

"code" identifier
" " single_char
"ends" segment

"end" segment

