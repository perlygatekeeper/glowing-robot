# Cell and Grid Objects

## Overview

`Cell` and `Grid` are the two foundational model objects in SudokuSolver.

At the current stage of the project, they still contain some legacy solving
behavior. The long-term direction is to make them represent Sudoku state
cleanly, while `Solver` and `Sudoku::Strategy::*` modules perform the solving
work.

This document describes their current responsibilities and the intended
boundaries for future refactoring.

---

## Cell

`Cell` represents one square in the Sudoku grid.

A standard Sudoku puzzle contains 81 cells arranged as:

9 rows
9 columns
9 boxes

Each `Cell` knows:

- whether it was a given clue
- its current value
- its possible candidate values
- its row
- its column
- its box

The current module is:

lib/Cell.pm

---

## Cell Attributes

### `given`

Indicates whether the value came from the original puzzle.

has 'given' => (isa => 'Int', is => 'rw');

Expected values:

1  original clue
0  empty cell or solved later

---

### `value`

The current solved value of the cell.

has 'value' => (isa => 'CellValue', is => 'rw');

Expected values:

0      unsolved
1..9   solved value

The custom `CellValue` type is defined in:

lib/Types.pm

---

### `possibilities`

The candidate list for an unsolved cell.

has 'possibilities' => (isa => 'ArrayRef', is => 'rw');

The current representation is an array where index `0` stores the number of
remaining candidates:

[ count, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]

When a candidate is removed, its slot becomes `0`.

Example:

[ 7, 1, 2, 0, 4, 5, 0, 7, 8, 9 ]

This means seven candidates remain, and candidates `3` and `6` have been
removed.

This representation is compact but fragile. All future candidate removal should
go through `remove_possibility()` rather than directly modifying the array.

---

### `row`, `column`, and `box`

Each cell stores zero-based coordinates:

has 'row'    => (isa => 'CellValue', is => 'rw');
has 'column' => (isa => 'CellValue', is => 'rw');
has 'box'    => (isa => 'CellValue', is => 'rw');

Internal values are:

0..8

User-facing output generally prints them as:

1..9

---

## Cell Methods

### `clue($value)`

Initializes the cell from a puzzle character.

If `$value` is `1..9`, the cell becomes a given clue:

given = 1
value = digit
possibilities = none

If `$value` is anything else, the cell becomes unsolved:

given = 0
value = 0
possibilities = 1..9

This method is used during grid loading.

---

### `remove_possibility($value)`

Removes a candidate from an unsolved cell.

Returns:

1  candidate was removed
0  no change was made

This method should become the only legal candidate-removal mechanism.

Legacy code still sometimes modifies the `possibilities` array directly. Those
direct mutations should be eliminated over time.

---

### `show_my_possibilities()`

Prints a debugging representation of the cell.

Examples:

Cell at ( 4, 5, 6 ) Given:  9
Cell at ( 4, 5, 6 ) Solved: 7
Cell at ( 4, 5, 6 ) Possibilities left: 8 -> 1, 2, 3, 4, 6, 7, 8, 9

This method is useful now, but long-term display logic should probably move out of `Cell`.

---

### Placeholder Mate Methods

The following methods currently exist as placeholders or incomplete legacy stubs:

my_mates()
my_row_mates()
my_column_mates()
my_box_mates()

At present, mate logic is more fully implemented on `Grid`.

Long-term, we should decide whether mate lookup belongs on `Cell`, on `Grid`, or both.

---

## Grid

`Grid` represents the full 9×9 Sudoku board.

The current module is:

lib/Grid.pm

A `Grid` owns:

- all 81 cells
- row groupings
- column groupings
- box groupings
- puzzle state
- some legacy solving methods

Over time, `Grid` should become more focused on board representation and state
mutation, while solving strategies move into `lib/Sudoku/Strategy/`.

---

## Grid Attributes

### `difficulty`

Legacy field for difficulty level.

has 'difficulty' => (isa => 'Difficulty', is => 'rw');

The `Difficulty` type is currently defined in `Types.pm`.

This field is not yet the full future difficulty system. The future direction
is a dedicated module:

lib/Sudoku/Difficulty.pm

---

### `notes`

Free-form notes attached to the grid.

has 'notes' => (isa => 'Str', is => 'rw');

---

### `solved`

Count of solved cells.

has 'solved' => (isa => 'Int', is => 'rw');

This currently increments as cells receive values.

A completed puzzle should have:

solved = 81

---

### `cells`

Array of all cells in board order.

has 'cells' => (isa => 'ArrayRef', is => 'rw');

Cell indexes are zero-based:

0..80

---

### `rows`

Array of nine row arrays.

has 'rows' => (isa => 'ArrayRef', is => 'rw');

Each row contains nine `Cell` objects.

---

### `columns`

Array of nine column arrays.

has 'columns' => (isa => 'ArrayRef', is => 'rw');

Each column contains nine `Cell` objects.

---

### `boxes`

Array of nine box arrays.

has 'boxes' => (isa => 'ArrayRef', is => 'rw');

Each box contains nine `Cell` objects.

Boxes are numbered zero-based, left to right, top to bottom:

0 1 2
3 4 5
6 7 8

---

## Grid Loading

### `load_from_string($string)`

Builds a grid from an 81-character puzzle string.

Characters `1..9` become given clues. Other characters are treated as empty cells.

Common empty-cell characters include:

0
.
-
_
space

During loading, the grid:

1. Initializes `cells`, `rows`, `columns`, and `boxes`.
2. Creates each `Cell`.
3. Assigns row, column, and box coordinates.
4. Stores each cell in all appropriate groupings.
5. Removes each given value from its mates.
6. Updates the solved-cell count.

This means a newly loaded grid already has candidate lists reduced by the original clues.

---

## Grid Coordinate System

Internally, `Grid` uses zero-based row and column indexes:

$grid->cell_from_row_column(0, 0);  # top-left cell
$grid->cell_from_row_column(8, 8);  # bottom-right cell

User-facing output should generally add one when displaying coordinates.

---

## Grid Lookup Methods

### `cell_from_row_column($row, $column)`

Returns the `Cell` object at the given zero-based row and column.

Example:

my $cell = $grid->cell_from_row_column(4, 7);

---

### Mate Lookup

The grid also provides methods for finding related cells, such as row, column,
box, and combined mates.

These are essential for both candidate elimination and strategy implementation.

A cell's mates are the other cells that share its:

- row
- column
- box

Mate methods should not include the original cell itself.

---

## Current Solving Responsibilities

Historically, `Grid.pm` contained most solving methods.

Two value-placement strategies have begun moving into strategy modules:

Sudoku::Strategy::NakedSingles
Sudoku::Strategy::HiddenSingles

The corresponding `Grid` methods currently delegate to those modules:

find_and_set_singletons()
find_and_set_lone_representatives()

Other legacy strategy methods still live in `Grid.pm`, including pair and
advanced strategy logic.

This is transitional.

---

## Future Responsibility Boundary

The intended architecture is:

Cell
    represents one square

Grid
    represents board state and provides lookup/mutation services

Solver
    controls solving flow

Sudoku::Strategy::*
    detect logical patterns

Sudoku::Deduction
    describes logical actions

Sudoku::Explain / Sudoku::Hint / Sudoku::Statistics
    consume deduction logs

---

## What Grid Should Eventually Do

`Grid` should eventually own:

- cells
- rows
- columns
- boxes
- lookup helpers
- candidate state
- safe mutation methods
- validation helpers
- solved-state checks

Examples:

$grid->cell_from_row_column($row, $column);
$grid->row($row);
$grid->column($column);
$grid->box($box);
$grid->mates_of($cell);
$grid->apply_deduction($deduction);

---

## What Grid Should Eventually Stop Doing

`Grid` should eventually stop owning:

- strategy-specific solving algorithms
- user-facing printing
- solver loop orchestration
- difficulty rating
- hint generation
- explanation formatting
- command-line behavior

Those responsibilities belong elsewhere.

---

## Relationship to Deduction Objects

A `Deduction` object describes a logical change to the puzzle.

For example:

Sudoku::Deduction->new(
    strategy    => 'Naked Single',
    action      => 'set_value',
    cell        => $cell,
    value       => 7,
    explanation => 'Only one candidate remains.',
);

A strategy should find the deduction.

The solver or grid should apply it.

This gives the project a clean separation between:

finding logic
applying logic
explaining logic
displaying logic

---

## Current Refactoring Direction

The current refactoring path is:

1. Preserve current behavior.
2. Add tests around existing behavior.
3. Move one strategy at a time into `lib/Sudoku/Strategy/`.
4. Introduce `Deduction` objects.
5. Have strategies return deductions.
6. Have `Solver` collect and apply deductions.
7. Reduce `Grid.pm` until it is primarily a board model.

---

## Developer Notes

When modifying `Cell` or `Grid`, prefer changes that:

- preserve public behavior
- go through tested APIs
- avoid direct candidate-array mutation
- avoid adding new strategy logic to `Grid.pm`
- support eventual `Deduction`-based solving
- keep output separate from state mutation whenever practical

Before changing either object, run:

make check

The most relevant tests are:

t/10_cell.t
t/11_cell_validation.t
t/12_cell_output.t

t/20_grid.t
t/21_grid_load.t
t/22_grid_units.t
t/23_grid_output.t
