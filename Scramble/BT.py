#!/opt/local/bin/python
class BT:
    bt = {
      0x00: { 'bit_string': '00000000', 'hexdecimal': '0x00', 'reversed': 0x00, 'inverted': 0xFF, 'parity': 0, 'ones': 0, '00': 4, '01': 0, '10': 0, '11': 0 }
    }
    def __init__(self, bytearray_data):
        self.data = bytearray_data
    def invert(self):
        for i in range(len(self.data)):
            if self.data[i] in BT.bt:
                # print( type( BT.bt[ self.data[i] ] ) )
                # print( BT.bt[ self.data[i] ] ) 
                self.data[i] = BT.bt[ self.data[i] ][ 'inverted' ]
            else:
                print(type(self.data[i]))
                print(self.data[i])
