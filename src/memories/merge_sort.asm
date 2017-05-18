-- pointer s
li 0 32

-- pointer l
li 1 32

-- pointer r
li 2 32

-- pointer w
li 3 64

-- block_size
li 4 1

li 5 0
-- value l

li 6 0
-- value r

li 7 0
-- junk

:start

-- s = l = r = 32; w = 64

li 0 32
li 1 32
li 2 32
li 3 64

-- r += size
add 2 4

:compare

-- *l, *r
ld 5 0 1
ld 6 0 2
nop
nop

-- l == s + size; :l_max
mov 7 0
add 7 4
cmp 1 7
be :l_max
nop
nop

-- r == s + size + size; :use_l
add 7 4
cmp 2 7
be :use_l
nop
nop

-- l < r; :use_l
cmp 5 6
ble :use_l
nop
nop

-- :use_r
b 0 :use_r
nop
nop

:l_max

-- r == s + size + size; :compare_end
add 7 4
cmp 2 7
be :compare_end
nop
nop

:use_l

-- *w = *l
st 5 0 3

-- w++, l++
li 7 1
add 3 7
add 1 7

-- :compare
b 0 :compare
nop
nop

:use_r

-- *r = *l
st 6 0 3

-- w++, r++
li 7 1
add 3 7
add 2 7

b 0 :compare
nop
nop

:compare_end

-- s = r
mov 0 2

-- s == 64; :next
li 7 64
cmp 0 7
be :next
nop
nop

-- l = s ; r += size; :compare
mov 1 0
add 2 4
b 0 :compare
nop
nop

:next

-- size <<= 1
sll 4 1

-- s = 32, w = 64
li 0 32
li 3 64

:moving

-- *s = *w
ld 7 0 3
nop
nop
st 7 0 0

out 0 7 0

-- s++; w++
li 7 1
add 0 7
add 3 7

-- s != 64; :moving
li 7 64
cmp 0 7
bne :moving
nop
nop

-- size != 1 << 5; :start
li 7 1
sll 7 5
cmp 4 7
bne :start
nop
nop

b 0 :end
nop
nop

:end

li 7 170
out 7 7 7

b 0 :end
