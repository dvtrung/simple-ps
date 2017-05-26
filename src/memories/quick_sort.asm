-- $0 stack count
-- left 0..15
-- right 16..31
li 0 0
li 2 4
sll 2 8
addi 2 1
-- $2 = 1025
st 2 0 0

li 2 8
sll 2 8
--addi 2 9
addi 2 -1
st 2 128 0

li 0 1

:partition

li 7 0
cmp 0 7
be :end

addi 0 -1
-- $1: left, $2: right
ld 1 0 0
ld 2 128 0

-- if left >= right
cmp 2 1
ble :partition

-- $3 pivot value: $r3 = a[left]
mov 4 2
sub 4 1
srl 4 1
add 4 1
ld 3 0 4
ld 5 0 1
st 3 0 1
st 5 0 4


-- $4 left value: $r4 = left + 1
-- $5 right value: $r5 = right 
mov 4 1
mov 5 2
addi 4 1

-- $r6 = a[left + 1]
-- $r4: i
:find_left
ld 6 0 4
nop
-- if a[i] > pivot
cmp 3 6
blt :find_right
-- if i > right
cmp 2 4
blt :find_right
addi 4 1
b 0 :find_left

:find_right
ld 7 0 5
nop
-- if a[j] < pivot
cmp 7 3
blt :swap
-- if j < left
cmp 5 1
be :swap
addi 5 -1
b 0 :find_right

:swap
-- swap a[$r4] with a[$r5]
-- $r5: j
cmp 5 4
ble :end_partition
st 6 0 5
st 7 0 4
addi 4 1
addi 5 -1
b 0 :find_left

:end_partition

st 7 0 1
st 3 0 5

-- recursion

addi 5 -1
st 1 0 0
st 5 128 0
addi 0 1

st 4 0 0
st 2 128 0
addi 0 1

b 0 :partition

:end

-- output
li 2 4
sll 2 8

addi 2 1
ld 6 0 2
addi 2 1
ld 7 0 2
out 6 7 0

addi 2 1
ld 6 0 2
addi 2 1
ld 7 0 2
out 6 7 1

addi 2 1
ld 6 0 2
addi 2 1
ld 7 0 2
out 6 7 2

addi 2 1
ld 6 0 2
addi 2 1
ld 7 0 2
out 6 7 3

--b 0 :printing

nop
hlt
