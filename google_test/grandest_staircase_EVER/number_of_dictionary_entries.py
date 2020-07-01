trianle_number_indices = {}
trianle_number_indices[  3]=  2
trianle_number_indices[  6]=  3
trianle_number_indices[ 10]=  4
trianle_number_indices[ 15]=  5
trianle_number_indices[ 21]=  6
trianle_number_indices[ 28]=  7
trianle_number_indices[ 36]=  8
trianle_number_indices[ 45]=  9
trianle_number_indices[ 55]= 10
trianle_number_indices[ 66]= 11
trianle_number_indices[ 78]= 12
trianle_number_indices[ 91]= 13
trianle_number_indices[105]= 14
trianle_number_indices[120]= 15
trianle_number_indices[136]= 16
trianle_number_indices[153]= 17
trianle_number_indices[171]= 18
trianle_number_indices[190]= 19

entries = 0
for i in range(3,201):
    if i in trianle_number_indices:
        number = trianle_number_indices[i]
    entries += number
    print( "%4d - %5d:%5d" % (i, number, entries) )

