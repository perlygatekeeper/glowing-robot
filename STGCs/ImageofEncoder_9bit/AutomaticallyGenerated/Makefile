# I come back to this makefile after years, on
# Mon Jul 24 2023, and will make notes on what I believe this makefile
# is meant to do.
#
# This make file will convert all the svg files into png files to be
# later joined into an animated png by some other command not in this makefile
# The svg files are made with: generate_Graycode_svgs.pl

GRAYCODE_SVGS := $(shell ls `pwd`/Graycode-[0-9][0-9][0-9].svg)
GRAYCODE_PNGS  = $(GRAYCODE_SVGS:%svg=%png)

.SUFFIXES: .svg .png

.svg.png:
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z --export-dpi=180 -D $< --export-png=$@

# What's in ~/etc/makelib
# Bourne-Shell	Rules		implicit	shell
# Examples	backup		loop		substitution
# Macros	deploy		man		suffixes
# Makefile	if		patches		variables

# all: $(GRAYCODE_PNGS)

debug:
	@echo generating debug file, generate_Graycode_debug.txt
	./generate_Graycode_svgs.pl -d > generate_Graycode_debug.txt

svgs:
	@echo $(GRAYCODE_SVGS)
	./generate_Graycode_svgs.pl

pngs:
	@echo $(GRAYCODE_PNGS)

clean:
	@rm -f $(GRAYCODE_SVGS) $(GRAYCODE_PNGS)
