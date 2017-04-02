".386" wrong_lexem

"data" identifier
"segment" segment

"vars" identifier
"db" type
"dbstring" identifier

"ddvar" identifier
"dd" type
".13f12423h" wrong_lexem

"dwvar" identifier
"dw" type
"23h" hexadecimal

"kvar" identifier
"=" single_char
"1fh" hexadecimal

"data" identifier
"ends" segment

"code" identifier
"segment" segment

"labl1:" identifier

"cli" command

"mov" command
"esi" reg32
"," single_char
"23h" hexadecimal

"cmp" command
"eax" reg32
"," single_char
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
"short" type
"lable" identifier

"xor" command
"byte" type
"ptr" operator
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
"kvar" identifier

"mov" command
"eax" reg32
"," single_char
"22h" hexadecimal

"mov" command
"kvar" identifier
"," single_char
"25h" hexadecimal

"mov" command
"ah" reg8
"," single_char
"kvar" identifier


"jcxz" command
"near" type
"ptr" operator
"labl1" identifier

"idiv" command
"bh" reg8

"mov" command
"ebx" reg32
"," single_char
"eax" reg32

"idiv" command
"ebx" reg32

"mov" command
"bl" reg8
"," single_char
"al" reg8

"idiv" command
"al" reg8

"xchg" command
"byte" type
"ptr" operator
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
"al" reg8

"xchg" command
"byte" type
"ptr" operator
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
"ecx" reg32

"idiv" command
"eax" reg32

"lable:" identifier

"int" command
"21h" hexadecimal

"code" identifier
"ends" segment

"end" segment





