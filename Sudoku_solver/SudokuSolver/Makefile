
Puzzles = Puzzle_01 Puzzle_02 Puzzle_03 Puzzle_04 Puzzle_05 Puzzle_06 Puzzle_07 Puzzle_08 Puzzle_09 Puzzle_10 \
	  Puzzle_11 Puzzle_12 Puzzle_13 Puzzle_14 Puzzle_15 Puzzle_16 Puzzle_17 Puzzle_18 Puzzle_19 Puzzle_20 \
	  Puzzle_21 Puzzle_22 Puzzle_23 Puzzle_24 Puzzle_25 Puzzle_26 Puzzle_27 Puzzle_28 Puzzle_29 Puzzle_30 \
	  Puzzle_31 Puzzle_32 Puzzle_33 Puzzle_34 Puzzle_35 Puzzle_36 Puzzle_37 Puzzle_38 Puzzle_39 Puzzle_40 \
	  Puzzle_41 Puzzle_42 Puzzle_43 Puzzle_44 Puzzle_45 Puzzle_46 Puzzle_47 Puzzle_48 Puzzle_49 Puzzle_50

echo:
	@echo ${Puzzles}

all:
	for puzzle in $(Puzzles); do \
	  echo making $$puzzle; \
 	  ./bin/sudoku.pl $$puzzle > Puzzles/$${puzzle}_solution.txt || exit 1; \
	done

17-50:
	for puzzle in `countdown -f '%02d  ' 1 50`; do \
	  echo $$puzzle; \
	  ./bin/sudoku.pl "$$puzzle" > Puzzles/sudoku17_$${puzzle}_solution.txt || exit 1; \
	done

solved:
	@echo "solved:   \c"
	@tail -1 Puzzles/sudoku17_* | perl -lane "print if  m'\d{81}';"    | wc -l
	@echo "unsolved: \c"
	@tail -1 Puzzles/sudoku17_* | perl -lane "print if  m'\+------'; " | wc -l

report:
	@tail -1 Puzzles/sudoku17_* | perl -ape " s/ \<==\n/  /; s/==\> Puzzles\/sudoku17_//; s/_solution\.txt/  /; s/(\+\s*|\d)\n/$$1/; "
	@echo " "
