#!/usr/bin/env python
import sys
import re

CODE1 = {
  "add": "0000",
  "sub": "0001",
  "and": "0010",
  "or" : "0011",
  "xor": "0100",
  "cmp": "0101",
  "mov": "0110"
}

CODE2 = {  
  "sll": "1000",
  "slr": "1001",
  "srl": "1010",
  "sra": "1011",
  "in" : "1100",
}

CODE3 = {
  "ld": "00",
  "st": "01"
}

CODE4 = {
  "li": "000",
  "b": "100"
}

CODE5 = {
  "be": "000",
  "blt": "001",
  "ble": "010",
  "bne": "011"
}

def dec_to_bin(x, dcount): return bin(int(x))[2:].zfill(dcount)

print("WIDTH=16;\nDEPTH=4096;\nADDRESS_RADIX=UNS;\nDATA_RADIX=BIN;\nCONTENT BEGIN\n\t[0..4095] : 0;\n")
count = 0

for line in sys.stdin:
  a = re.findall(r"[\w']+", line)
  if not a:
    print("--")
    continue
  res = None
  if a[0] in CODE1:
    assert len(a) == 3, "unmatchd args"
    res = "11" + dec_to_bin(a[2], 3) + dec_to_bin(a[1], 3) + CODE1[a[0]] + "0000"
  if a[0] in CODE2:
    assert len(a) == 3, "unmatchd args"
    res = "11" + "000" + dec_to_bin(a[1], 3) + CODE2[a[0]] + dec_to_bin(a[2], 4)
  if a[0] == "out":
    assert len(a) == 2, "unmatchd args"
    res = "11" + dec_to_bin(a[1], 3) + "000" + "1101" + "0000"
  if a[0] == "hlt":
    assert len(a) == 1, "unmatchd args"
    res = ("1100000011110000");
  if a[0] in CODE3:
    assert len(a) == 4, "unmatchd args"
    res = CODE3[a[0]] + dec_to_bin(a[1], 3) + dec_to_bin(a[3], 3) + dec_to_bin(a[2], 8)
  if a[0] in CODE4:
    assert len(a) == 3, "unmatchd args"
    res = "10" + CODE4[a[0]] + dec_to_bin(a[1], 3) + dec_to_bin(a[2], 8)
  if a[0] in CODE5:
    assert len(a) == 2, "unmatchd args"
    res = "10" + "111" + CODE5[a[0]] + dec_to_bin(a[1], 8)

  assert res is not None, line + " may not be a inst!"
  assert len(res) == 16, line + " -> " + res + " is a iligal inst!"
  print("\t" + str(count) + ":\t" + res + "; -- " + line.strip())
  count+=1

print("END;")
