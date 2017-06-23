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

labl1: label

int command
"h" string

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

xor command
gs:[ebx*4h+ebx+6h] prefix
, divider
2222h hexadecimal

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

mov command
eax reg32
, divider
ebx reg32

mov command
ecx reg32
, divider
al reg8

mov command
al reg8
, divider
edx reg32

idiv command
al reg8

mov command
eax reg32
, divider
25h hexadecimal

mov command
eax reg32
, divider
kvar const

mov command
eax reg32
, divider
labl1 label

kvar const
= directive
"k" string

xor command
dwvar identifier
, divider
kvar const

xor command
byte size_type
ptr operator
dwvar identifier
, divider
kvar const

xor command
dword size_type
ptr operator
dwvar identifier
, divider
kvar const

xor command
dword size_type
ptr operator
gs:[ebx*4h+ebx+66666h] prefix
, divider
22h hexadecimal

xor command
gs:[ebx*4h+ebx+6h] prefix
, divider
2222h hexadecimal

xchg command
ddvar identifier
, divider
al reg8

xchg command
ddvar identifier
, divider
eax reg32

xchg command
dwvar identifier
, divider
eax reg32

xchg command
dword size_type
ptr operator
ddvar identifier
, divider
al reg8

xchg command
byte size_type
ptr operator
ddvar identifier
, divider
eax reg32

xchg command
[ebx*4h+ebx+6h] equation
, divider
al reg8

xchg command
[ebx*4h+ebx+6h] equation
, divider
ecx reg32

xchg command
byte size_type
ptr operator
es:[ebx*4h+ebx+6h] prefix
, divider
ecx reg32

xchg command
es:[ebx*4h+ebx+6h] prefix
, divider
al reg8

xchg command
ds:[ebx*4h+ebx+6h] prefix
, divider
ecx reg32

xchg command
ds:[ebp*4h+ebx+6h] prefix
, divider
ecx reg32

xchg command
ds:[ebp*4h+esp+6h] prefix
, divider
ecx reg32

xchg command
ds:[ebx*4h+ebx+6h] prefix
, divider
al reg8

xchg command
cs:[ebx*4h+ebx+6h] prefix
, divider
ecx reg32

xchg command
cs:[ebx*4h+ebx+6h] prefix
, divider
al reg8

xchg command
ss:[ebp*4h+ebp+6h] prefix
, divider
ecx reg32

xchg command
ss:[ebx*4h+ebp+6h] prefix
, divider
ecx reg32

xchg command
ss:[ebx*4h+eax+6h] prefix
, divider
ecx reg32

xchg command
ss:[esi*4h+esi+6h] prefix
, divider
al reg8

xchg command
ss:[esi*4h+esi+6h] prefix
, divider
ecx reg32

xchg command
ss:[ebp*4h+ebp+6h] prefix
, divider
al reg8

xchg command
fs:[ebx*4h+ebx+6h] prefix
, divider
ecx reg32

xchg command
fs:[ebx*4h+ebx+6h] prefix
, divider
al reg8

xchg command
gs:[ebx*4h+ebx+6h] prefix
, divider
ecx reg32

xchg command
gs:[ebx*4h+ebx+6h] prefix
, divider
al reg8

xchg command
byte size_type
ptr operator
[ebx*4h+ebx+66666h] equation
, divider
al reg8

xchg command
dword size_type
ptr operator
[ebp*4h+eax+6h] equation
, divider
ecx reg32

xchg command
byte size_type
ptr operator
[ebx*4h+ebx+6h] equation
, divider
ecx reg32

xchg command
dword size_type
ptr operator
[ebp*4h+eax+6h] equation
, divider
al reg8

xor command
dwvar identifier
, divider
2222h hexadecimal

xor command
byte size_type
ptr operator
dwvar identifier
, divider
22h hexadecimal

xor command
dword size_type
ptr operator
dwvar identifier
, divider
22h hexadecimal

xor command
dwvar identifier
, divider
kvar const

xor command
byte size_type
ptr operator
dwvar identifier
, divider
kvar const

xor command
byte size_type
ptr operator
dwvar identifier
, divider
"2" string

xor command
dword size_type
ptr operator
dwvar identifier
, divider
kvar const

xor command
dword size_type
ptr operator
dwvar identifier
, divider
"22" string

xor command
dword size_type
ptr operator
dwvar identifier
, divider
"222" string

xor command
dword size_type
ptr operator
gs:[ebx*4h+ebx+66h] prefix
, divider
22h hexadecimal

xor command
dword size_type
ptr operator
gs:[ebx*4h+ebx+66h] prefix
, divider
"2" string

cmp command
al reg8
, divider
ddvar identifier

cmp command
al reg8
, divider
gs:[ebx*4h+ebx+66666h] prefix

cmp command
eax reg32
, divider
gs:[ebx*4h+ebx+66666h] prefix

cmp command
eax reg32
, divider
ddvar identifier

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

code seg_identifier
ends segment

end segment

