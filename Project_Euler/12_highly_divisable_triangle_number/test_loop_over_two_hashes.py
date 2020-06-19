#!/opt/local/bin/python
# Python program to test looping over keys of two dictionaries


dict1 =  {
    "ant": "insect",
    "bee": "insect",
    "cat": "mammal",
    "dog": "mammal",
    "eel": "fish",
}

dict2 =  {
    "Ant": "insect",
    "Bee": "insect",
    "Cat": "mammal",
    "Dog": "mammal",
    "Eel": "fish",
}

print("-------")
for animal in dict1:
    print(animal)

print("-------")
for animal in dict2:
    print(animal)

print("-------")
for animal in dict1, dict2:
    print(animal)

