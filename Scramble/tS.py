#!/opt/local/bin/python
import BT
data = bytearray(b'\x00\x00\x00\x00\x00\x00\x00\x00')
print("Object initialized:")
t = BT.BT(data)
t.invert()
print(t.data)
