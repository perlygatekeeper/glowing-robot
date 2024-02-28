import random

def unpack_salt(salt, debug=1):
    parameters = bytearray(24)
    # Unpack 15-byte Salt or Anti_Salt 
    # into 24 numbers 5 bits each, ready for use as parameters for transforms
    bit_sensor = [ 0b00000001, 0b00000010, 0b00000100, 0b00001000, 0b00010000, 0b00100000, 0b01000000, 0b10000000 ]
    if (debug):
      print("Bytes passed in:")
    for batch in range(3):
        for batch_row in range(5):
            bytes_row = batch * 5 + batch_row
            if (debug):
                print(f"{salt[bytes_row]:08b}")
            for bit in range(8):
                row = batch * 8 + bit
                if (salt[bytes_row] & bit_sensor[bit]):
                   parameters[row] |= 1 << batch_row
        if (debug):
            print("")
    if (debug):
        line = 0
        separator = "\nSalt returned:"
        for byte in parameters:
            if (not line):
                print(separator)
                separator = ""
            print(f"{byte:05b}")
            line = (line + 1) % 8
    return parameters

def pack_salt(parameters, debug=1):
    salt = bytearray(15)
    # Pack 24 5-bit numbers (parameters for transforms) into 15-byte salt
    bit_sensor = [ 0b00000001, 0b00000010, 0b00000100, 0b00001000, 0b00010000, 0b00100000, 0b01000000, 0b10000000 ]
    if (debug):
        line = 0
        separator = "Salt-based transform parameters passed in:"
        for byte in parameters:
            if (not line):
                print(separator)
                separator = ""
            print(f"{byte:05b}")
            line = (line + 1) % 8
    for number in range(24):
        packed_bit = number % 8
        batch = int(number/8)
        for unpacked_bit in range(5):
            packed_byte = batch * 5 + unpacked_bit
            set_bit = 1 << packed_bit
            if ( parameters[number] & bit_sensor[unpacked_bit] ):
                salt[packed_byte] |= set_bit
    if (debug):
        print("Salt derived from the given parameters:")
        for bytes_row in range(15):
            print(f"{salt[bytes_row]:08b}")
    return salt

def pack_anti_salt(parameters, debug=1):
    anti_parameters = bytearray(24)
    anti_salt = bytearray(15)
    # Pack 24 5-bit numbers (parameters for transforms) into 15-byte anti_salt
    bit_sensor = [ 0b00000001, 0b00000010, 0b00000100, 0b00001000, 0b00010000, 0b00100000, 0b01000000, 0b10000000 ]
    if (debug):
        line = 0
        separator = "Salt-based parameters passed in:"
        for byte in parameters:
            if (not line):
                print(separator)
                separator = ""
            print(f"{byte:05b}")
            line = (line + 1) % 8
    # 4 5 6 7 0 1 2 3  - 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
    # Checkerboard
    # Anti-X: X                    if  X <= 8
    #         X + 1 + 2((x%2)-1)   if  X >= 9
    # Whirlpool
    # 0  26 - X
    # 1  18 - X
    # 2  10 - X
    # 3  Anti - Checkerboard
    i = 0
    for number in ( 4, 5, 6, 7, 0, 1, 2, 3, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23):
        if ( number <= 7 and ( number % 4 ) != 3 ):
            if ( ( number % 4 ) == 0 ):
                anti_parameters[i] = 26 - parameters[number]
            if ( ( number % 4 ) == 1 ):
                anti_parameters[i] = 18 - parameters[number]
            if ( ( number % 4 ) == 2 ):
                anti_parameters[i] = 10 - parameters[number]
        else:
            if ( parameters[number] <= 8 ):
                anti_parameters[i] = parameters[number]
            else:
                X = parameters[number]
                anti_parameters[i] = X + 1 + 2 * ( ( X % 2 ) -1 )
        i += 1
    for number in range(24):
        packed_bit = number % 8
        batch = int(number/8)
        for unpacked_bit in range(5):
            packed_byte = batch * 5 + unpacked_bit
            set_bit = 1 << packed_bit
            if ( anti_parameters[number] & bit_sensor[unpacked_bit] ):
                anti_salt[packed_byte] |= set_bit
    if (debug):
        print("Anti-Salt derived from the given parameters:")
        for bytes_row in range(15):
            print(f"{anti_salt[bytes_row]:08b}")
    return anti_salt

def random_parameters(debug=1):
    parameters = bytearray(24)
    for number in ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23):
        if ( number <= 7 and ( number % 4 ) != 3 ):
            if ( ( number % 4 ) == 0 ):
                parameters[number] = random.randint(0, 26)  # Generates a random integer between 0 (inclusive) and 23 (inclusive)
            if ( ( number % 4 ) == 1 ):
                parameters[number] = random.randint(0, 18)
            if ( ( number % 4 ) == 2 ):
                parameters[number] = random.randint(0, 10)
        else:
            parameters[number] = random.randint(0, 23)
    return parameters

parameters = random_parameters()
pack_salt(parameters, 1)
pack_anti_salt(parameters, 1)

# unpack_salt( bytearray('Steven_ Parker:', 'utf-8' ) )

'''

 btyes_row  bytes                      batch  batch_row
            7  6  5  4  3  2  1  0
   0        a  f  k  p  u  0  5  A     0      0
   1        b  g  l  q  v  1  6  B     0      1
   2        c  h  m  r  w  2  7  C     0      2
   3        d  i  n  s  x  3  8  D     0      3
   4        e  j  o  t  y  4  9  E     0      4
   5        a  f  k  p  u  0  5  A     1      0
   6        b  g  l  q  v  1  6  B     1      1
   7        c  h  m  r  w  2  7  C     1      2
   8        d  i  n  s  x  3  8  D     1      3
   9        e  j  o  t  y  4  9  E     1      4
  10        a  f  k  p  u  0  5  A     2      0
  11        b  g  l  q  v  1  6  B     2      1
  12        c  h  m  r  w  2  7  C     2      2
  13        d  i  n  s  x  3  8  D     2      3
  14        e  j  o  t  y  4  9  E     2      4
            ----------------------
 bit ->     7  6  5  4  3  2  1  0

meanings of 24 salt numbers

2x2 square  0 1
            3 2

  N  Transform 
Not used  0  0 1 2 3    Null Transform   Reverse Transform
     0    2  1 0 2 3    Swap Top         0
     1	  2  0 1 3 2    Swap Bottom      1
     2	  2  0 2 1 3    Swap Right       2
     3	  2  2 1 0 3    Swap \           3
     4	  2  3 1 2 0    Swap Left        4
     5	  2  0 3 2 1    Swap /           5
     6	  4  1 0 3 2    Flip Vert        6
     7	  4  3 2 1 0    Flip Hori        7
     8	  4  2 3 0 1    X                8

     9	  3  0 3 1 2    TL -  CW        10
    10	  3  0 2 3 1    TL - CCW         9

    11	  3  3 1 0 2    TR -  CW        12
    12	  3  2 1 3 0    TR - CCW        11

    13	  3  1 3 2 0    BR -  CW        14
    14	  3  3 0 2 1    BR - CCW        13

    15	  3  2 0 1 3    BL -  CW        16
    16	  3  1 2 0 3    BL - CCW        15

    17	  4  3 0 1 2     CW             18
    18	  4  1 2 3 0    CCW             17

    19	  4  2 3 1 0    B/ \B  Tv vT    20
    20	  4  3 2 0 1    T\ /T  B| |B    19

    21	  4  2 0 3 1    L- L-  R/ R\    22
    22	  4  1 3 0 2    L/ L\  R- R-    21

--------------------------                                       
    Whirlpool
    0  26 - X
    1  18 - X
    2  10 - X
    3  Anti - Checkerboard
    4  26 - X
    5  18 - X
    6  10 - X
    7  Anti - Checkerboard

    Checkerboard
8..23  Anti - Checkerboard

Anti - Checkerboard:
    Anti-X: X                    if  X <= 8
            X + 1 + 2((x%2)-1)   if  X >= 9
--------------------------


Whirlpool
R                                       
O         COLUMN                        
W    7 6 5 4 3 2 1 0                    
     - - - - - - - -                    
0 |  A B C D E F G H       _ _ _ _ _ _ _ _       _ _ _ _ _ _ _ _      _ _ _ _ _ _ _ _
1 |  2 _ _ _ _ _ _ I       _ A B C D E F _       _ _ _ _ _ _ _ _      _ _ _ _ _ _ _ _
2 |  1 _ _ _ _ _ _ J       _ T _ _ _ _ G _       _ _ A B C D _ _      _ _ _ _ _ _ _ _
3 |  0 _ _ _ _ _ _ K       _ S _ _ _ _ H _       _ _ L _ _ E _ _      _ _ _ A B _ _ _
4 |  Z _ _ _ _ _ _ L       _ R _ _ _ _ I _       _ _ K _ _ F _ _      _ _ _ D C _ _ _
5 |  Y _ _ _ _ _ _ M       _ Q _ _ _ _ J _       _ _ J I H G _ _      _ _ _ _ _ _ _ _
6 |  X _ _ _ _ _ _ N       _ P O N M L K _       _ _ _ _ _ _ _ _      _ _ _ _ _ _ _ _
7 |  V U T S R Q P O       _ _ _ _ _ _ _ _       _ _ _ _ _ _ _ _      _ _ _ _ _ _ _ _
                                           
     28 bit locations      20 bit locations      12 bit locations     4 bit locations
                                         
Rotations should be between 1 and N-1.  
                                         
        27 rotations       19 rotations          11 rotations       23 unique trasnforms

     0  rotate  1 CW  26   rotate  1 CW  18      rotate  1 CW  10
     1	rotate  2 CW  25   rotate  2 CW  17      rotate  2 CW   9
     2	rotate  3 CW  24   rotate  3 CW  16      rotate  3 CW   8
     3	rotate  4 CW  23   rotate  4 CW  15      rotate  4 CW   7
     4	rotate  5 CW  22   rotate  5 CW  14      rotate  5 CW   6
     5	rotate  6 CW  21   rotate  6 CW  13      rotate  6 CW   5
     6	rotate  7 CW  20   rotate  7 CW  12      rotate  7 CW   4
     7	rotate  8 CW  19   rotate  8 CW  11      rotate  8 CW   3
     8	rotate  9 CW  18   rotate  9 CW  10      rotate  9 CW   2
     9	rotate 10 CW  17   rotate 10 CW   9      rotate 10 CW   1
    10	rotate 11 CW  16   rotate 11 CW   8      rotate 11 CW   0
    11	rotate 12 CW  15   rotate 12 CW   7     
    12	rotate 13 CW  14   rotate 13 CW   6     
    13	rotate 14 CW  13   rotate 14 CW   5     
    14	rotate 15 CW  12   rotate 15 CW   4     
    15	rotate 16 CW   1   rotate 16 CW   3     
    16	rotate 17 CW   0   rotate 17 CW   2     
    17	rotate 18 CW   9   rotate 18 CW   1     
    18	rotate 19 CW   8   rotate 19 CW   0     
    19	rotate 20 CW   7  
    20	rotate 21 CW   6  
    21	rotate 22 CW   5  
    22	rotate 23 CW   4  
    23	rotate 24 CW   3  
    24	rotate 25 CW   2  
    25	rotate 26 CW   1  
    26	rotate 27 CW   0  

'''                                     
