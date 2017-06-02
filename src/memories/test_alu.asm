:start
in 0 0
in 1 1
out 0 1
out 1 2

mov 2 0
sll 2 1
out 2 4

mov 2 0
srl 2 1
out 2 5

mov 2 0
slr 2 1
out 2 6

mov 2 0
sra 2 1
out 2 7

mov 2 0
add 2 1
out 2 8
mov 2 0
sub 2 1
out 2 9

mov 2 0
addi 2 1
out 2 10
mov 2 0
addi 2 -1
out 2 11

mov 4 0
mov 5 1
bal :mul
out 6 12
bal :div
out 6 13

mov 4 0
mov 5 1
bal :gcd
out 6 14
mov 4 0
mov 5 1
bal :lcm
out 6 15

b 0 :start

:mul
li 7 0
li 6 0
:loop_mul
add 6 5
addi 7 1
cmp 7 4
bne :loop_mul
bs

:div
li 7 0
li 6 0
:loop_div
addi 6 1
add 7 5
cmp 7 4
ble :loop_div
addi 6 -1
bs

:gcd
li 6 0
cmp 4 5
blt :a_lt_b
sub 4 5
b 0 :check_res
:a_lt_b
sub 5 4
:check_res
cmp 4 6
be :return_b
cmp 5 6
be :return_a
b 0 :gcd_continue
:return_a
mov 6 4
bs
:return_b
mov 6 5
bs
:gcd_continue
bal :gcd
bs

:lcm
bal :mul
mov 7 6
bal :gcd
mov 4 7
mov 5 6
bal :div
bs
