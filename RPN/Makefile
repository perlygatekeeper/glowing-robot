PERL ?= perl5.34
TAR  := gtar
NAME := rpn-oo

SCRIPT    := rpn.pl
MODS      := lib/RPN.pm \
             lib/RPN/Stack.pm \
             lib/RPN/CodeBlock.pm \
             lib/RPN/CodeBlocks.pm \
             lib/RPN/Commands.pm \
             lib/RPN/Commands/CodeBlocks.pm \
             lib/RPN/Commands/Combinatorics.pm \
             lib/RPN/Commands/Constants.pm \
             lib/RPN/Commands/Conversion.pm \
             lib/RPN/Commands/Examples.pm \
             lib/RPN/Commands/Financial.pm \
             lib/RPN/Commands/Functions.pm \
             lib/RPN/Commands/Matrix.pm \
             lib/RPN/Commands/NumberTheory.pm \
             lib/RPN/Commands/Numeric.pm \
             lib/RPN/Commands/Random.pm \
             lib/RPN/Commands/Stack.pm \
             lib/RPN/Commands/Statistics.pm \
             lib/RPN/Commands/Stack.pm \
             lib/RPN/Commands/Strings.pm \
             lib/RPN/Commands/Trig.pm \
             lib/RPN/Commands/Tutorials.pm \
             lib/RPN/Commands/Variables.pm \
             lib/RPN/Commands/Vector.pm \
             lib/RPN/Constants.pm \
             lib/RPN/Functions.pm \
             lib/RPN/Matrix.pm \
             lib/RPN/Variables.pm \
             lib/RPN/Vector.pm \
             t/lib/RPN/TestOutput.pm
TESTDIR   := t/
CONSTANTS := constants/
EXAMPLES  := examples/
DOCS      := docs/
TOOLS     := tools/
TUTORIALS := docs/tutorials/
DEVELOPER := docs/Developer/

RELEASE_NOTES := $(shell ls docs/Release_*.txt)
ROADMAP       := $(shell ls docs/Roadmap*.txt)

.PHONY: backup syntax run test docs-check catalog examples-catalog clean size size-modules

tarball: backup

backup:
	$(TAR) -cvzf ../$(NAME)-`date +%Y%m%d-%H%M`.tgz Makefile $(SCRIPT) $(MODS) \
		$(TESTDIR) \
		$(CONSTANTS) \
		$(TOOLS) \
		$(EXAMPLES)/*/*.txt \
		$(DOCS)/*.txt \
		$(DEVELOPER)/*.txt \
		$(TUTORIALS)/*_v[0-9][0-9].txt

syntax:
	$(PERL) -Ilib -c $(SCRIPT)
	@for mod in $(MODS); do \
	  echo "Checking $$mod"; \
	  $(PERL) -Ilib -c $$mod || exit 1; \
	done

run:
	$(PERL) -Ilib rpn.pl

test: 
	prove -Ilib t

check: syntax test 

docs-check:
	$(PERL) -Ilib tools/tutorial_audit.pl
	$(PERL) -Ilib tools/generate_command_catalog.pl --check
	$(PERL) -Ilib tools/generate_examples_catalog.pl --check

catalog:
	$(PERL) -Ilib tools/generate_command_catalog.pl

examples-catalog:
	$(PERL) -Ilib tools/generate_examples_catalog.pl

version:
	-grep -i 'version  *=' rpn.pl lib/RPN.pm

gitadd:
	git add Makefile $(SCRIPT) \
	$(MODS) \
	$(TOOLS) \
	$(TESTDIR)*.t \
	$(DOCS)*.txt \
	$(DEVELOPER)*.txt \
	$(TUTORIALS)*.txt \
	$(CONSTANTS)*.txt \
	$(EXAMPLES)*/*
	git status

perl-version:
	$(PERL) -v

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
