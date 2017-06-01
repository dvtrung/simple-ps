-- pointer s = 1024
li 0 1
sll 0 10

-- pointer l = 1024
mov 1 0

-- pointer r = 1024
mov 2 0

-- pointer w = 0
li 3 0

-- block_size = 1
li 4 1

-- value l = 0
li 5 0

-- value r = 0
li 6 0

-- junk
li 7 0

:start

-- r += size
add 2 4

:compare

-- *l, *r
ld 5 0 1
ld 6 0 2

-- nop
-- nop

-- l == s + size; :l_max
mov 7 0
add 7 4
cmp 1 7
be :l_max

-- r == s + size + size; :use_l
add 7 4
cmp 2 7
be :use_l

-- l < r; :use_l
cmp 5 6
ble :use_l

-- :use_r
b 0 :use_r

:l_max

-- r == s + size + size; :compare_end
add 7 4
cmp 2 7
be :compare_end

-- through from l_max
:use_r

-- *r = *l
st 6 0 3

-- w++, r++
addi 3 1
addi 2 1

b 0 :compare

:use_l

-- *w = *l
st 5 0 3

-- w++, l++
addi 3 1
addi 1 1

-- :compare
b 0 :compare

:compare_end

-- s = r
mov 0 2

-- s == 2048; :next_back
li 7 1
sll 7 11
cmp 0 7
be :next_back

-- s == 1024; :next_foward
li 7 1
sll 7 10
cmp 0 7
be :next_foward

-- l = s ; r += size; :compare
mov 1 0
add 2 4
b 0 :compare

:next_back

-- size <<= 1
sll 4 1

-- s = l = r = 0; w = 1024

li 0 0
li 1 0
li 2 0
li 3 1
sll 3 10

-- :start
b 0 :start

:next_foward

-- size <<= 1
sll 4 1

-- size == 1 << 10; :final
li 7 1
sll 7 10
cmp 4 7
be :final

-- s = l = r = 1024; w = 0

li 0 1
sll 0 10
mov 1 0
mov 2 0
li 3 0

-- :start
b 0 :start

:final

li 7 222
sll 7 8
li 6 173
sll 6 8
srl 6 8
add 6 7
li 7 190
sll 7 8
li 5 175
sll 5 8
srl 5 8
add 5 7
nop
nop
out 6 7 6
hlt
