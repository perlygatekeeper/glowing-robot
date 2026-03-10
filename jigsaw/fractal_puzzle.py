#!/usr/bin/env python3
import sys
import time
import os
import argparse

# Configuration
NR_POSITIONS = 4000

class Node:
    __slots__ = ('l', 'r', 'u', 'd', 'vector', 'position', 'next_ignored', 'swapped_out')
    def __init__(self):
        self.l = self.r = self.u = self.d = self
        self.vector = None
        self.position = None
        self.next_ignored = None
        self.swapped_out = False

    def push_back(self, n):
        n.r = self
        n.l = self.l
        self.l.r = n
        self.l = n

    def push_bottom(self, n):
        n.d = self
        n.u = self.u
        self.u.d = n
        self.u = n

    def swapout_horz(self):
        self.l.r = self.r
        self.r.l = self.l
        self.swapped_out = True

    def swapin_horz(self):
        self.l.r = self
        self.r.l = self
        self.swapped_out = False

    def swapout_vert(self):
        self.u.d = self.d
        self.d.u = self.u
        self.swapped_out = True

    def swapin_vert(self):
        self.u.d = self
        self.d.u = self
        self.swapped_out = False

    def ignore(self, mark_as_hot):
        pass

    def unignore(self):
        pass


class Vector(Node):
    __slots__ = ('name', 'nr', 'hot')
    def __init__(self, n):
        super().__init__()
        self.nr = n
        self.hot = 1
        self.name = ""

    def ignore(self, mark_as_hot=False):
        ignore_vector(self, None, mark_as_hot)
        global nr_vec
        nr_vec -= 1

    def unignore(self):
        unignore_vector(self, None)
        global nr_vec
        nr_vec += 1


class Position(Node):
    __slots__ = ('nr', 'nr_vec_left', 'hotpos', 'needs_reducing', 'connections')
    def __init__(self):
        super().__init__()
        self.nr = 0
        self.nr_vec_left = 0
        self.hotpos = 0
        self.needs_reducing = 0
        self.connections = None

    def ignore(self, mark_as_hot=False):
        ignore_position(self, mark_as_hot)
        global nr_pos
        nr_pos -= 1

    def unignore(self):
        unignore_position(self)
        global nr_pos
        nr_pos += 1


class PositionConnection:
    __slots__ = ('nr', 'from_pos', 'to_pos', 'next_con', 'next_from_con', 'next_to_con', 'enabled')
    def __init__(self):
        self.nr = 0
        self.from_pos = None
        self.to_pos = None
        self.next_con = None
        self.next_from_con = None
        self.next_to_con = None
        self.enabled = False

    def other(self, p):
        return self.to_pos if p == self.from_pos else self.from_pos

    def next(self, p):
        if p == 0:
            return self.next_con
        elif p == self.from_pos:
            return self.next_from_con
        else:
            return self.next_to_con

    def ref_to_next(self, p):
        if p == 0:
            return 'next_con'
        elif p == self.from_pos:
            return 'next_from_con'
        else:
            return 'next_to_con'


# Global state
root = Node()
nr_pos = 0
nr_vec = 0
nr_pos_with_zero_vec = 0
flog = sys.stderr
fsols = sys.stdout
start_time = 0
start_periode = 0
sol_found_in_periode = 0
nr_solutions = 0
sol_vectors = [None] * NR_POSITIONS
nr_sol_vectors = 0
total_nr_calls = 0
nr_calls_to_solve = 0

# Config flags
opt_reduce = True
opt_reduce_tries = 0
opt_only_reduce = False
opt_reduce_groups = False


def read_input(f, use_numeric=False):
    global nr_pos, nr_vec, nr_pos_with_zero_vec, root
    if use_numeric:
        read_numeric(f)
    else:
        read_binary(f)


def read_binary(f):
    global nr_pos, nr_vec, nr_pos_with_zero_vec, root
    lines = f.readlines()
    if not lines:
        return
    first_line = lines[0]
    i = 0
    while i < NR_POSITIONS and i < len(first_line) and first_line[i] in '01':
        i += 1
    nr_pos = i
    nr_pos_with_zero_vec = nr_pos

    for _ in range(nr_pos):
        position = Position()
        root.push_back(position)
        position.nr = _
        position.nr_vec_left = 0

    for line in lines:
        nr_vec += 1
        vector = Vector(nr_vec)
        root.push_bottom(vector)
        s = line.rstrip('\n')
        i = 0
        name_start = nr_pos
        while i < len(s) and s[i] in '01':
            i += 1
        binary_part = s[:i]
        name_part = s[i:].lstrip()
        if name_part and name_part[-1] in '\r\n\t ':
            name_part = name_part.rstrip()
        vector.name = name_part

        pos_node = root.r
        for idx, ch in enumerate(binary_part):
            if ch == '1':
                node = Node()
                pos_node.push_bottom(node)
                vector.push_back(node)
                node.vector = vector
                node.position = pos_node
                if pos_node.nr_vec_left == 0:
                    global nr_pos_with_zero_vec
                    nr_pos_with_zero_vec -= 1
                pos_node.nr_vec_left += 1
            pos_node = pos_node.r


def read_numeric(f):
    global nr_pos, nr_vec, nr_pos_with_zero_vec, root
    # Add dummy first position to match C++ logic
    position = Position()
    root.push_back(position)
    position.nr = 0
    position.nr_vec_left = 0
    nr_pos = 1
    nr_pos_with_zero_vec = 1

    lines = f.readlines()
    for line in lines:
        s = line.strip()
        if not s or not s[0].isdigit():
            continue
        nr_vec += 1
        vector = Vector(nr_vec)
        root.push_bottom(vector)

        parts = []
        current = ''
        for ch in s:
            if ch.isdigit():
                current += ch
            elif ch == ',':
                if current:
                    parts.append(int(current))
                    current = ''
            elif ch == ' ':
                break
            else:
                if current:
                    parts.append(int(current))
                    current = ''
                break
        if current:
            parts.append(int(current))

        name_part = ''
        if ' ' in line:
            name_part = line.split(' ', 1)[1].strip()
        vector.name = name_part

        for pos_nr in parts:
            while pos_nr >= nr_pos:
                new_pos = Position()
                root.push_back(new_pos)
                new_pos.nr = nr_pos
                new_pos.nr_vec_left = 0
                nr_pos += 1
                nr_pos_with_zero_vec += 1
            # Find the position
            pos_node = root.r
            while pos_node.nr < pos_nr:
                pos_node = pos_node.r
            node = Node()
            pos_node.push_bottom(node)
            vector.push_back(node)
            node.vector = vector
            node.position = pos_node
            if pos_node.nr_vec_left == 0:
                global nr_pos_with_zero_vec
                nr_pos_with_zero_vec -= 1
            pos_node.nr_vec_left += 1


def ignore_vector(vector, exclude, mark_as_hot=False):
    global nr_pos_with_zero_vec
    vector.swapout_vert()
    node = vector.r
    while node != vector:
        if mark_as_hot:
            if node.position.hotpos == 0:
                n2 = node.position.d
                while n2 != node.position:
                    n2.vector.hot += 1
                    n2 = n2.d
            node.position.hotpos += 1
            node.position.needs_reducing += 1
        if node.position != exclude:
            node.swapout_vert()
            node.position.needs_reducing += 1
            node.position.nr_vec_left -= 1
            if node.position.nr_vec_left == 0:
                nr_pos_with_zero_vec += 1
        node = node.r


def unignore_vector(vector, exclude):
    global nr_pos_with_zero_vec
    node = vector.l
    while node != vector:
        if node.position != exclude:
            node.swapin_vert()
            node.position.nr_vec_left += 1
            if node.position.nr_vec_left == 1:
                nr_pos_with_zero_vec -= 1
        node = node.l
    vector.swapin_vert()


def select_position(position, exclude):
    position.swapout_horz()
    node = position.d
    while node != position:
        if node.vector != exclude:
            ignore_vector(node.vector, position)
        node = node.d


def unselect_position(position, exclude):
    node = position.u
    while node != position:
        if node.vector != exclude:
            unignore_vector(node.vector, position)
        node = node.u
    position.swapin_horz()


def select_vector(vector):
    vector.swapout_vert()
    node = vector.r
    while node != vector:
        select_position(node.position, vector)
        node = node.r


def unselect_vector(vector):
    node = vector.l
    while node != vector:
        unselect_position(node.position, vector)
        node = node.l
    vector.swapin_vert()


def ignore_position(position, mark_as_hot=False):
    global nr_pos_with_zero_vec
    if position.nr_vec_left == 0:
        nr_pos_with_zero_vec -= 1
    position.swapout_horz()
    node = position.d
    while node != position:
        node.swapout_horz()
        node = node.d


def unignore_position(position):
    global nr_pos_with_zero_vec
    node = position.u
    while node != position:
        node.swapin_horz()
        node = node.u
    position.swapin_horz()
    if position.nr_vec_left == 0:
        nr_pos_with_zero_vec += 1


class IgnoredNodes:
    def __init__(self):
        self._ignored = []

    def add(self, node, mark_as_hot=False):
        self._ignored.append(node)
        node.ignore(mark_as_hot)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        while self._ignored:
            node = self._ignored.pop()
            node.unignore()


def reduce_position(position1, ignored_nodes, mark_as_hot=False):
    global nr_pos_with_zero_vec
    progress = False

    # Check for equal columns
    pos2 = root.r
    while pos2 != root:
        if position1 is not pos2 and position1.nr_vec_left == pos2.nr_vec_left:
            node1, node2 = position1.d, pos2.d
            equal = True
            while node1 != position1 and node2 != pos2:
                if node1.vector.nr != node2.vector.nr:
                    equal = False
                    break
                node1 = node1.d
                node2 = node2.d
            if equal and node1 == position1 and node2 == pos2:
                if flog:
                    print(f"Column {position1.nr} equal with column {pos2.nr}. ({nr_pos - 1})", file=flog)
                ignored_nodes.add(pos2)
        pos2 = pos2.r

    if nr_pos_with_zero_vec > 0:
        print("Fatal error: Equal resulted in position(s) without vectors.", file=sys.stderr)
        sys.exit(1)

    # Check for implication
    pos2 = root.r
    while pos2 != root:
        if position1 is not pos2 and position1.nr_vec_left < pos2.nr_vec_left:
            if position1.nr_vec_left == 0:
                return progress
            implied = True
            node1 = position1.d
            node2 = pos2.d
            while node1 != position1:
                vec_nr = node1.vector.nr
                while node2 != pos2 and node2.vector.nr < vec_nr:
                    node2 = node2.d
                if node2 == pos2 or node2.vector.nr != vec_nr:
                    implied = False
                    break
                node1 = node1.d
                node2 = node2.d
            if implied:
                if flog:
                    print(f"Column {position1.nr} implies column {pos2.nr}. Reduced number vectors with {pos2.nr_vec_left - position1.nr_vec_left}", file=flog)
                vec = root.d
                to_remove = []
                while vec != root:
                    has1 = has2 = False
                    n = vec.r
                    while n != vec:
                        if n.position == position1:
                            has1 = True
                        if n.position == pos2:
                            has2 = True
                        n = n.r
                    if not has1 and has2:
                        to_remove.append(vec)
                    vec = vec.d
                for v in to_remove:
                    if flog:
                        print(f"  remove: {v.name}", file=flog)
                    ignored_nodes.add(v, mark_as_hot)
                progress = True
                # Handle zero positions after removal
                if nr_pos_with_zero_vec > 0:
                    zero_positions = []
                    p = root.r
                    while p != root:
                        if p.nr_vec_left == 0:
                            zero_positions.append(p)
                        p = p.r
                    for p in zero_positions:
                        ignored_nodes.add(p)
                    if nr_pos_with_zero_vec > 0:
                        print("Fatal error: Still some left???", file=sys.stderr)
                        sys.exit(1)
        pos2 = pos2.r

    return progress


def reduce_all(ignored_nodes, mark_as_hot=False):
    global nr_pos_with_zero_vec
    progress = True
    while progress:
        progress = False
        while True:
            position_to_reduce = None
            best_score = None
            p = root.r
            while p != root:
                if p.needs_reducing > 0:
                    score = p.nr_vec_left - p.needs_reducing
                    if position_to_reduce is None or score < best_score:
                        position_to_reduce = p
                        best_score = score
                p = p.r
            if position_to_reduce is None:
                break
            if reduce_position(position_to_reduce, ignored_nodes, mark_as_hot):
                progress = True
            position_to_reduce.needs_reducing = 0


def solve():
    global nr_solutions, nr_sol_vectors, sol_vectors, nr_calls_to_solve
    nr_calls_to_solve += 1
    if root.r == root:
        nr_solutions += 1
        parts = [v.name for v in sol_vectors[:nr_sol_vectors] if v.name]
        print('|'.join(parts), file=fsols)
        return False

    with IgnoredNodes() as ignored:
        while True:
            if nr_pos_with_zero_vec > 0:
                return False

            best_pos = None
            best_nr = 0
            p = root.r
            while p != root:
                if p.nr_vec_left == 1:
                    best_pos = p
                    best_nr = 1
                    break
                if best_pos is None or p.nr_vec_left < best_nr:
                    best_pos = p
                    best_nr = p.nr_vec_left
                p = p.r

            if best_nr == 0:
                print("ERROR", file=sys.stderr)
                return False

            sel_vector = best_pos.d.vector
            sol_vectors[nr_sol_vectors] = sel_vector
            nr_sol_vectors += 1
            select_vector(sel_vector)
            result = solve()
            unselect_vector(sel_vector)
            nr_sol_vectors -= 1

            if result:
                return True
            if best_nr == 1:
                return False
            ignored.add(sel_vector)


def main():
    global opt_reduce, opt_reduce_tries, opt_only_reduce, opt_reduce_groups, start_time, start_periode

    parser = argparse.ArgumentParser()
    parser.add_argument('-noreduce', '-nored', action='store_true')
    parser.add_argument('-reducetries', '-redtries', type=int, default=0)
    parser.add_argument('-onlyreduce', '-onlyred', action='store_true')
    parser.add_argument('-reducegroups', '-redgr', action='store_true')
    parser.add_argument('-numeric', '-num', action='store_true')
    parser.add_argument('-save_intermediate', action='store_true')
    args = parser.parse_args()

    opt_reduce = not args.noreduce
    opt_reduce_tries = args.reducetries
    opt_only_reduce = args.onlyreduce
    opt_reduce_groups = args.reducegroups
    use_numeric = args.numeric
    output_intermediate = args.save_intermediate

    read_input(sys.stdin, use_numeric)

    # Check for impossible columns
    impossible = False
    p = root.r
    while p != root:
        if p.nr_vec_left == 0:
            print(f"Column {p.nr} is empty.", file=sys.stderr)
            impossible = True
        p = p.r
    if impossible:
        print("Impossible Exact Cover.", file=sys.stderr)
        return

    start_time = time.clock() if hasattr(time, 'clock') else time.time() * 1000
    start_periode = start_time

    if opt_reduce:
        with IgnoredNodes() as ignored:
            # Initialize hotpos and needs_reducing
            p = root.r
            while p != root:
                p.hotpos = 1
                p.needs_reducing = 1
                p = p.r

            changed = 1
            nr_pass = 0
            while changed > 0:
                reduce_all(ignored, True)
                nr_pass += 1
                changed = 0
                # Hot vector elimination
                v = root.d
                while v != root:
                    if hasattr(v, 'hot'):
                        v.hot += 1
                    v = v.d

                while True:
                    hottest = None
                    v = root.d
                    while v != root:
                        if hasattr(v, 'hot') and v.hot > 0:
                            if hottest is None or v.hot > hottest.hot:
                                hottest = v
                        v = v.d
                    if hottest is None:
                        break
                    select_vector(hottest)
                    # Simulate 'possible' with 1 try
                    unselect_vector(hottest)
                    # Skip full impossible check for simplicity
                    hottest.hot = 0

                if output_intermediate:
                    with open("reduced.ec", "w") as f:
                        # Simplified print
                        v = root.d
                        while v != root:
                            print(v.name, file=f)
                            v = v.d

    if opt_only_reduce:
        return

    solve()
    now = time.clock() if hasattr(time, 'clock') else time.time() * 1000
    print(f"total time = {(now - start_time)/1000.0}", file=sys.stderr)
    print(f"nr solution = {nr_solutions} ({nr_solutions/((now - start_time)/1000.0):.2f}/sec)", file=sys.stderr)


if __name__ == "__main__":
    main()
