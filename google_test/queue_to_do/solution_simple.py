def solution(start, length):
    if length == 1:
        checksum = long(start)
    else:
        checksum = long(0)
        counted = long(0)
        for line in range(length):
            if counted == 2000000001:
                break
            for position in range(length-line):
                id = start + int(line * length) + position
                if id >= 2000000001:
                    id -= 2000000001
                if counted == 2000000001:
                    break
                checksum ^= id
                counted += 1
            counted += (length - line)
    return checksum

print(solution(0,3))
print(solution(17,4))
print(solution(170000001,1))
print(solution(0,2000000001))
