-- $0 left
li 0 0
-- $1 right
li 1 32

:qsort
-- $4 left value
-- $5 right value
ld 4 0 0
ld 5 0 1
-- $2 pivot address
-- $3 pivot value
mov 2 1
mov 3 2
sub 3 1
srl 3 1
add 2 4
ld 3 0 2

addi 0 1
ld 4 0 0

addi 1 -1
ld 5 0 1
