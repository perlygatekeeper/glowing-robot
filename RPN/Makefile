PERL := perl5.34
TAR  := gtar
NAME := rpn-oo

SCRIPT    := rpn.pl
MODS      := lib/RPN.pm \
             lib/RPN/Stack.pm \
             lib/RPN/Commands.pm \
             lib/RPN/Constants.pm \
             lib/RPN/Variables.pm
TESTDIR   := t/
CONSTANTS := constants/

RELEASE_NOTES := $(shell ls Release_**.txt)

.PHONY: backup syntax run test clean

backup:
	$(TAR) -cvzf ../$(NAME)-`date +%Y%m%d-%H%M`.tgz Makefile $(SCRIPT) $(MODS) $(TESTDIR) $(CONSTANTS)  $(RELEASE_NOTES) Roadmap.txt Roadmap_2.txt

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

clean:
	find . -name '*~' -delete
	find . -name '*.bak' -delete
	find . -name '.DS_Store' -delete

