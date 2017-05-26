:start

li 0 1
li 1 2
li 2 3
li 3 4
li 4 5
li 5 6
li 6 7
li 7 8

b 0 :next

:next

li 1 0
li 1 1
li 1 2
li 1 3

b 0 :jump

:back


li 2 0
li 2 1
li 2 2
li 2 3

b 0 :end
li 2 4
li 2 5
li 2 6
li 2 7


:jump

b 0 :back
li 3 0
li 3 1
li 3 2
li 3 3

:end

li 4 0
li 4 1
li 4 2
li 4 3


li 0 1
li 1 2
li 2 3
li 3 4
li 4 5
li 5 6
li 6 7
li 7 8


li 2 33
li 0 10
li 1 10
cmp 0 1
be :nexta
hlt

:nexta

li 2 34
li 1 11
cmp 0 1
bne :nextb
hlt

:nextb

li 2 35
cmp 0 1
blt :nextc
hlt

:nextc

li 2 36
cmp 0 1
ble :nextd
hlt

:nextd
li 2 37
cmp 0 1
blt :nexte

hlt

:nexte

li 0 0
addi 0 16
addi 0 -16

li 1 0
li 2 32
addi 0 -1
bne :nexte
hlt

