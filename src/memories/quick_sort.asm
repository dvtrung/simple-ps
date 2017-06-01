-- $0 stack count
-- left 0..15
-- right 16..31
li 0 0
li 1 4
sll 1 8
-- addi 2 1
-- $2 = 1024
st 1 0 0

li 2 8
sll 2 8
--addi 2 9
addi 2 -1
st 2 128 0

:bubble_sort
mov 3 1
li 7 0
li 0 0

-- r0: swapped?, r3: i
:bbs_loop
mov 4 3
ld 5 0 4
addi 3 1
ld 6 0 3
cmp 3 2
be :end_bubble
cmp 5 6
ble :bbs_loop
li 0 1
st 5 0 3
st 6 0 4
:end_bubble

cmp 0 7
be :end

li 0 1

:partition

-- if r0 < 0 end
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

-- $4 left value: $r4 = left + 1
-- $5 right value: $r5 = right 
mov 4 1
addi 4 1
cmp 4 2
bne :choose_pivot
ld 6 0 1
ld 7 0 2
cmp 6 7
blt :partition
st 6 0 2
st 7 0 1
b 0 :partition

:choose_pivot
mov 5 2

-- $3 pivot value: $r3 = a[left]
-- r6: pivot, r3 = a[pivot], r5 = a[left]
mov 6 2
sub 6 1
srl 6 1
add 6 1
-- swap a[pivot] and a[left]
ld 3 0 6
ld 7 0 1
st 3 0 1
st 7 0 6

-- $r6 = a[left + 1]
-- $r4: i
:find_left
ld 6 0 4
-- if a[i] > pivot
cmp 3 6
blt :find_right
-- if i > j
cmp 5 4
blt :end_partition
addi 4 1
b 0 :find_left

:find_right
ld 7 0 5
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

-- recursion (add to stack)

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

ld 6 0 2
sll 2 1
addi 2 -1
ld 7 0 2
out 6 7 0

--b 0 :printing

hlt
