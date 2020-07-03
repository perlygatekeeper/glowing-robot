def checksum_single_line(line, start_id, end_id):
#   is there a time limit on the checksum calculation
#   take advantage that any four consecuative integers starting with an even number XOR to 0
    if start_id & 1 == 1:
        checksum = start_id
        start = start_id + 1
    else:
        start = start_id
        checksum = 0
    line_length = end_id - start + 1
    if   line_length % 4 == 0:
       pass
    elif line_length % 4 == 1:
        checksum ^= end_id
    elif line_length % 4 == 2:
        checksum ^= 1
    elif line_length % 4 == 3:
        checksum ^= end_id
        checksum ^= 1
    return checksum
    
def solution(start, length):
    # wrap_or_end will be "End" or "Wrap"
    # End  - employees will stop lining up after id 2,000,000,000
    # Wrap - employee with id 0 will dutifly line up after the employee with id 2,000,000,000
    wrap_or_end = "End"
#   LINE_TOO_LONG = 100
    NUMBER_OF_EMPLOYEES = 2000000001
    line_handling_threshold = 1000
    # done is flag to terminate outer "line" loop when a condition in inner loop triggers
    done = False
    checksum = 0
    counted = 0
    if length == 1:
        checksum = start
#   elif length >= LINE_TOO_LONG:
#       return None # short circut really large lengths
    elif length < line_handling_threshold:
#       checksum every id that is considered
        if wrap_or_end == "End":
            for line in range(length):
                # check to see if we have counted all employees 0 .. 2,000,000,000 inclusive
                # also break if termination condition triggers in inner 'id' loop
                if done:
                    break
                for position in range(length-line):
                    id = start + int(line * length) + position
                    if id >= NUMBER_OF_EMPLOYEES:
                        done = True
                        break
                    checksum ^= id
                    if counted >= NUMBER_OF_EMPLOYEES:
                        done = True
                        break
        elif wrap_or_end == "Wrap":
            for line in range(length):
                # check to see if we have counted all employees 0 .. 2,000,000,000 inclusive
                # also break if termination condition triggers in inner 'id' loop
                if done or counted >= NUMBER_OF_EMPLOYEES:
                    break
                for position in range(length-line):
                    id = start + int(line * length) + position
                    if id >= NUMBER_OF_EMPLOYEES:
                        id -= NUMBER_OF_EMPLOYEES
                    checksum ^= id
                    counted += 1
                    if counted >= NUMBER_OF_EMPLOYEES:
                        done = True
                        break
                counted += line

        else:
            for line in range(length):
                for position in range(length-line):
                    id = start + int(line * length) + position
                    checksum ^= id

    elif length >= line_handling_threshold:
#       take advantage that any four consecuative integers starting with an even number XOR to 0
        if wrap_or_end == "End":
            for line in range(length):  # 0 .. length-1
                # check to see if we have counted all employees 0 .. 2,000,000,000 inclusive
                # counted >= NUMBER_OF_EMPLOYEES:
                start_id =  min(start + int( line * length ), 2000000000 )
                if start_id >= NUMBER_OF_EMPLOYEES:
                    break
                end_id   = min(start_id + ( length - line ) - 1, 2000000000 )
                checksum ^= checksum_single_line(line, start_id, end_id)
                if end_id >= NUMBER_OF_EMPLOYEES:
                    break

        elif wrap_or_end == "Wrap":
            for line in range(length):
                # check to see if we have counted all employees 0 .. 2,000,000,000 inclusive
                # also break if termination condition triggers in inner 'id' loop
                if done or counted >= NUMBER_OF_EMPLOYEES:
                    break
                checksum ^= checksum_single_line(line, start_id, end_id)
                counted += line

        else:
            for line in range(length):
                for position in range(length-line):
                    id = start + int(line * length) + position
                    checksum ^= id
               
    return checksum


test   = 1 # 1
start  = 0
length = 3
print("Test %2d: start is %d length is %5d: " % (test, start, length))
print(solution(start,length))
# 2

test  += 1 # 2
start  = 17
length = 4
print("Test %2d: start is %d length is %5d: " % (test, start, length))
print(solution(start,length))
# 14

test  += 1 # 3
start  = 999
length = 10000
print("Test %2d: start is %d length is %5d: " % (test, start, length))
print(solution(start,length))
# 129179904
test  += 1 # 4
test  += 1 # 5
test  += 1 # 6

test  += 1 # 7
start  = 999
length = 1000
print("Test %2d: start is %d length is %5d: " % (test, start, length))
print(solution(start,length))
# 89472

test  += 1 # 8
start  = 999
length = 100
print("Test %2d: start is %d length is %5d: " % (test, start, length))
print(solution(start,length))
# 7690
test  += 1 # 9

test  += 1 # 10
start  = 999
length = 10
print("Test %2d: start is %d length is %5d: " % (test, start, length))
print(solution(start,length))
# 1150
