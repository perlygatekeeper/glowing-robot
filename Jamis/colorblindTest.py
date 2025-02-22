import random

def init():
    style = input("Style: normal or rainbow: ")
    if style == "rainbow":
        neural_net = [[[0,[]], [0,[]], [0,[]]], [[0,[1, 0, 0]], [0,[0, 1, 0]], [0,[0, 0, 1]], [0,[1, 1, 0]], [0,[1, 0, 1]], [0,[0, 1, 1]], [0,[1, 1, 1]]]]
        range_max = 255
        layer_count = int(input("Number of Layers after rainbow layers: "))
        for layer in range(layer_count):
            neural_net.append(layer_create(layer+2, len(neural_net[layer+1])))
        rainbow(neural_net)
    else:
        layer_count = int(input("Number of Layers: "))
        neural_net = []
        for layer in range(layer_count):
            if layer == 0:
                neural_net.append(layer_create(0, 0))
            else:
                neural_net.append(layer_create(layer, len(neural_net[layer-1])))
        #print(neural_net)
        range_max = int(input("Input Range: "))
        casting = True
        while casting:
            node_index = 0
            for input_node in neural_net[0]:
                input_node[0] = input_update(node_index, range_max)
                node_index += 1
            for layer_index in range(1, len(neural_net)):
                layer_update(neural_net[layer_index], neural_net[layer_index-1])
            print(neural_net)
            output_display(neural_net[len(neural_net) - 1])
            input("Press Enter")

def node_create(node_count, parent_layer_size):
    layer = []
    for node in range(node_count):
        layer.append([])
        layer[node].append(0)
        connections = []
        for connection in range(parent_layer_size):
            connections.append(round(random.random(), 2))
        layer[node].append(connections)
    return layer

# Asks user for new inputs, maybe set the range of values examples: 0-100, 0-10, 0-255.
def input_update(node_index, range_max):
    return int(input("Node: " + str(node_index+1) + " Enter Value: ")) / range_max


# This will change the input to run through all hues (rgb), preset with 3 inputs
def rainbow(neural_net):
    rgb_values = [255,0,255]
    for rgb_index in range(3):
        while rgb_values[(rgb_index-1) % 3] > 0:
            for input_index in range(3):
                neural_net[0][input_index][0] = rgb_values[input_index]/255
            for layer_index in range(1, len(neural_net)):
                layer_update(neural_net[layer_index], neural_net[layer_index - 1])
            #output_display(neural_net[len(neural_net) - 1])
            print([round(output[0], 2) for output in neural_net[len(neural_net) - 1]])
            rgb_values[(rgb_index-1) % 3] -= 5
            #print(rgb_values)
        while rgb_values[(rgb_index+1) % 3] < 255:
            for input_index in range(3):
                neural_net[0][input_index][0] = rgb_values[input_index]/255
            for layer_index in range(1, len(neural_net)):
                layer_update(neural_net[layer_index], neural_net[layer_index - 1])
            #output_display(neural_net[len(neural_net) - 1])
            print([round(output[0], 2) for output in neural_net[len(neural_net) - 1]])
            rgb_values[(rgb_index+1) % 3] += 5
            #print(rgb_values)
    # Create the Rainbow layer (create a new node *Black*), (Single connection paths: *Red*, *Green*, *Blue*), (Paired connection paths: *Cyan*, *Yellow*, *Magenta*), 
    # (All connection path *White*); all paths are set to 1.00 for connection values

    #R,G,B,Y,C,M


def layer_create(layer_index, prior_layer_size):
    node_count = int(input("Number of nodes in layer: " + str(layer_index+1) + ": "))
    return node_create(node_count, prior_layer_size)

# Updates all the nodes in a layer, when the prior layer is updated.
def layer_update(layer, prior_layer):
    for node in layer:
        node[0] = 0
        weight = 0
        index = 0
        for connection in node[1]:
            node[0] += connection * prior_layer[index][0]
            weight += connection
            index += 1
        if weight == 0:
            node[0] = 0
        else:
            node[0] /= weight
    return layer


# def output_display(output_layer):
    # for output_node in output_layer:
