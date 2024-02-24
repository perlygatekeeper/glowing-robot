import base64

def output_triples(char, triple = []):
    if (len(triple) <= 1):
        triple.append(char)
    else:
        print( f"{triple[0]}, {triple[1]}, {char}")
        triple.pop()
        triple.pop()


triple = []
for char in ( [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i' ] ):
    output_triples(char, triple)
