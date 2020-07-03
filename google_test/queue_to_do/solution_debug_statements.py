# 254:   11111110   254:   11111110
# 255:   11111111     1:          1
# 256:  100000000   257:  100000001
# 257:  100000001     0:          0 <- line_length = 257 - 254 + 1 = 4   % 4 = 0
# 258:  100000010   258:  100000010 <- line_length = 258 - 254 + 1 = 4   % 4 = 1
# 259:  100000011     1:          1 <- line_length = 259 - 254 + 1 = 6   % 4 = 2
# 260:  100000100   261:  100000101 <- line_length = 260 - 254 + 1 = 7   % 4 = 3
# 261:  100000101     0:          0 <- line_length = 261 - 254 + 1 = 8   % 4 = 0

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
#   if line % 1000 == 1:
#   print ("%6d: %d -> %d checksum is %d" % (line, start_id, end_id, checksum))
    return checksum
    
def solution(start, length):
    # wrap_or_end will be "End" or "Wrap"
    # End  - employees will stop lining up after id 2,000,000,000
    # Wrap - employee with id 0 will dutifly line up after the employee with id 2,000,000,000
    wrap_or_end = "End"
    if wrap_or_end == "End":
        print("%s: employees will stop lining up after id 2,000,000,000" % (wrap_or_end))
    elif wrap_or_end == "Wrap":
        print("%s: employee with id 0 will line up after employee with id 2,000,000,000" % (wrap_or_end))
    else:
        print("%s: effects of reaching employee with id 2,000,000,000 will simply be ignored" % (wrap_or_end))
    LINE_TOO_LONG = 100
    NUMBER_OF_EMPLOYEES = 2000000001
    line_handling_threshold = 10001
    # done is flag to terminate outer "line" loop when a condition in inner loop triggers
    done = False
    checksum = 0
    counted = 0
    if length == 1:
        checksum = long(start)
#   elif length == 10000 and start == 0: # test 3 short-cut, remove when 5, 6 and 9 are working
#       checksum = 82460672
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
        print("length: {0} is greater than line_handling_threshold: {1} will use checksum_single_line()".format(length, line_handling_threshold) )
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
                print("line: %6d: Checksum is now: %10d" % (line, checksum) )
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
                print("line: %6d: Checksum is now: %10d" % (line, checksum) )

    return checksum

print(solution(0,3))
# 2
print(solution(17,4))
# 14
print(solution(999,10000))
# 129179904
print(solution(170000001,1))
# print(solution(0,2000000001))
