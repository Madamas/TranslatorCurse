.386 wrong_lexem

data seg_identifier
segment segment

vars identifier
db size_type
"dbstring" string

ddvar identifier
dd size_type
13f13h hexadecimal

dwvar identifier
dw size_type
23h hexadecimal

kvar const
= directive
1fh hexadecimal

data seg_identifier
ends segment

code seg_identifier
segment segment

assume identifier
cs:code identifier
, divider
ds:data identifier

labl1: label

cli command

mov command
esi reg32
, divider
23h hexadecimal

cmp command
eax reg32
, divider
[esi*4h+edi+8h] equation

jcxz command

xor command
byte size_type
ptr operator
[ebx+ebx*2h+4h] equation
, divider
kvar const

mov command
eax reg32
, divider
22h hexadecimal

kvar const
= directive
25h hexadecimal

mov command
ah reg8
, divider
kvar const

jcxz command

idiv command
bh reg8

mov command
ebx reg32
, divider
eax reg32

idiv command
ebx reg32

mov command
bl reg8
, divider
al reg8

idiv command
al reg8

xchg command
byte size_type
ptr operator
[ebx*4h+ebx+6h] equation
, divider
al reg8

xchg command
dword size_type
ptr operator
[ebp*4h+eax+6h] equation
, divider
ecx reg32

idiv command
eax reg32

lable: label

int command
byte size_type
ptr operator
21h hexadecimal

kvar const
= directive
22h hexadecimal

int command
kvar const

int command
"asdsadah" string

code seg_identifier
ends segment

end segment

