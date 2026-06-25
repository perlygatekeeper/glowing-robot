PERL := perl5.34
TAR  := gtar
NAME := rpn-oo

SCRIPT    := rpn.pl
MODS      := lib/RPN.pm \
             lib/RPN/Stack.pm \
             lib/RPN/Commands.pm \
             lib/RPN/Commands/Matrix.pm \
             lib/RPN/Commands/Combinatorics.pm \
             lib/RPN/Commands/Financial.pm \
             lib/RPN/Commands/NumberTheory.pm \
             lib/RPN/Commands/Vector.pm \
             lib/RPN/Commands/Tutorials.pm \
             lib/RPN/Commands/Numeric.pm \
             lib/RPN/Commands/Stack.pm \
             lib/RPN/Constants.pm \
             lib/RPN/Functions.pm \
             lib/RPN/Variables.pm \
             lib/RPN/Vector.pm \
             lib/RPN/Matrix.pm
TESTDIR   := t/
CONSTANTS := constants/
EXAMPLES  := examples/
DOCS      := docs/
TUTORIALS := docs/tutorials/
DEVELOPER := docs/Developer/

RELEASE_NOTES := $(shell ls docs/Release_*.txt)
ROADMAP       := $(shell ls docs/Roadmap*.txt)

.PHONY: backup syntax run test clean size size-modules

backup:
	$(TAR) -cvzf ../$(NAME)-`date +%Y%m%d-%H%M`.tgz Makefile $(SCRIPT) $(MODS) \
		$(TESTDIR) \
		$(CONSTANTS) \
		$(EXAMPLES)/*/*.txt \
		$(DOCS)/*.txt \
		$(DEVELOPERS)/*.txt \
		$(TUTORIALS)/*_v[0-9][0-9].txt

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
	git add Makefile $(SCRIPT) \
	$(MODS) \
	$(TESTDIR)/*.t \
	$(DOCS)/*.txt \
	$(DEVELOPER)/*.txt \
	$(TUTORIALS)/*.txt \
	$(CONSTANTS)/*.txt \
	$(EXAMPLES)/*/*
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
	@printf "%-28s %8s\n" "docs" "$$(find docs -type f -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
	@printf "%-28s %8s\n" "examples" "$$(find examples -type f -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
	@echo "-----------------------------"
	@printf "%-28s %8s\n" "TOTAL" "$$(find rpn.pl lib t examples -type f \( -name '*.pl' -o -name '*.pm' -o -name '*.t' -o -name '*.txt' \) -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"

#	@printf "%-28s %8s\n" "examples" "$$(find examples -type f -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"
#	@printf "%-28s %8s\n" "docs/release/roadmap" "$$(find . -maxdepth 1 \( -name 'Roadmap*.txt' -o -name 'Release_notes*.txt' \) -print0 | xargs -0 grep -hcv '^[[:space:]]*$$' | awk '{s+=$$1} END {print s+0}')"

size-modules:
	@echo "Module size, non-blank lines"
	@echo "============================"
	@total=$$(grep -hcv '^[[:space:]]*$$' rpn.pl lib/*.pm lib/RPN/*.pm | awk '{s+=$$1} END {print s}') ; \
	printf "%-35s %8s %8s\n" "Module" "Lines" "%" ; \
	printf "%-35s %8s %8s\n" "------" "-----" "---" ; \
	for f in rpn.pl lib/*.pm lib/RPN/*.pm lib/RPN/Commands/*.pm; do \
		[ -f "$$f" ] || continue ; \
		lines=$$(grep -cv '^[[:space:]]*$$' "$$f") ; \
		pct=$$(awk "BEGIN { printf \"%.1f\", 100 * $$lines / $$total }") ; \
		printf "%-35s %8d %7s%%\n" "$$f" "$$lines" "$$pct" ; \
	done | sort -k2 -n ; \
	echo "-----------------------------------------------" ; \
	printf "%-35s %8d\n" "TOTAL" "$$total"
