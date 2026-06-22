PERL := perl5.34
TAR  := gtar
NAME := rpn-oo

SCRIPT    := rpn.pl
MODS      := lib/RPN.pm \
             lib/RPN/Stack.pm \
             lib/RPN/Commands.pm \
             lib/RPN/Constants.pm \
             lib/RPN/Functions.pm \
             lib/RPN/Variables.pm \
             lib/RPN/Vector.pm \
             lib/RPN/Matrix.pm
TESTDIR   := t/
CONSTANTS := constants/
EXAMPLES  := examples/

RELEASE_NOTES := $(shell ls Release_**.txt)

.PHONY: backup syntax run test clean size

backup:
	$(TAR) -cvzf ../$(NAME)-`date +%Y%m%d-%H%M`.tgz Makefile $(SCRIPT) $(MODS) $(TESTDIR) $(CONSTANTS)  $(RELEASE_NOTES) $(EXAMPLES) Roadmap.txt Roadmap_2.txt

syntax:
	$(PERL) -Ilib -c $(SCRIPT)
	@for mod in $(MODS); do \
	  echo "Checking $$mod"; \
	  $(PERL) -Ilib -c $$mod || exit 1; \
	done

run:
	$(PERL) -Ilib rpn.pl

test: syntax
	prove -Ilib t

version:
	-grep -i 'version  *=' rpn.pl lib/RPN.pm

gitadd:
	git add t/*.t lib/RPN/Variables.pm Makefile lib/RPN.pm lib/RPN/*.pm rpn.pl Rel* Roadmap* $(EXAMPLES)/*/*
	git status

clean:
	find . -name '*~' -delete
	find . -name '*.bak' -delete
	find . -name '.DS_Store' -delete

size:
	@echo "Project size, non-blank lines"
	@echo "============================="
	@printf "%-28s %8s\n" "Component" "Lines"
	@printf "%-28s %8s\n" "---------" "-----"
	@printf "%-28s %8s\n" "rpn.pl" "$$(grep -hcv '^[[:space:]]*$$' rpn.pl 2>/dev/null || echo 0)"
	@printf "%-28s %8s\n" "lib" "$$(find lib -type f -name '*.pm' -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
	@printf "%-28s %8s\n" "tests" "$$(find t -type f -name '*.t' -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
	@printf "%-28s %8s\n" "examples" "$$(find examples -type f -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
	@printf "%-28s %8s\n" "docs/release/roadmap" "$$(find . -maxdepth 1 \( -name 'Roadmap*.txt' -o -name 'Release_notes*.txt' \) -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
	@echo "-----------------------------"
	@printf "%-28s %8s\n" "TOTAL" "$$(find rpn.pl lib t examples -type f \( -name '*.pl' -o -name '*.pm' -o -name '*.t' -o -name '*.txt' \) -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
