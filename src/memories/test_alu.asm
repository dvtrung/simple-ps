:start
in 0 1
in 1 0

mov 2 0
add 2 1
mov 3 0
sub 3 1
out 0 1
out 1 2
out 2 4
out 3 5

mov 2 0
sll 2 1
mov 3 0
srl 3 1
out 2 8
out 3 9

mov 2 0
slr 2 1
mov 3 0
sra 3 1
out 2 10
out 3 11

bal :mul
nop
bal :div
nop
out 2 6
out 3 7

b 0 :start

:mul
li 7 0
li 2 0
:loop_mul
add 2 1
addi 7 1
cmp 7 0
bne :loop_mul
nop
bs

:div
nop
li 3 0
nop
li 7 0
:loop_div
addi 3 1
add 7 1
cmp 7 0
ble :loop_div
addi 3 -1
bs
