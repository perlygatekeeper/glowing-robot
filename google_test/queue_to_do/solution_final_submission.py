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
    # End  - employees will stop lining up after id 2,000,000,000
    NUMBER_OF_EMPLOYEES = 2000000001
    line_handling_threshold = 999
    # done is flag to terminate outer "line" loop when a condition in inner loop triggers
    done = False
    checksum = 0
    counted = 0
    if length == 1:
        checksum = start
    elif length < line_handling_threshold:
#      checksum every id that is considered
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
    elif length >= line_handling_threshold:
#      take advantage that any four consecuative integers starting with an even number XOR to 0
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
    return checksum
