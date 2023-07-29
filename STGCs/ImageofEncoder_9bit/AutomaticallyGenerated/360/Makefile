GRAYCODE_SVGS := $(shell ls `pwd`/Graycode-[0-9][0-9][0-9].svg)
GRAYCODE_PNGS  = $(GRAYCODE_SVGS:%svg=%png)

.SUFFIXES: .svg .png

.svg.png:
	/Applications/Inkscape.app/Contents/Resources/bin/inkscape -z --export-dpi=180 -D $< --export-png=$@

# Bourne-Shell	Rules		implicit	shell
# Examples	backup		loop		substitution
# Macros	deploy		man		suffixes
# Makefile	if		patches		variables

all: $(GRAYCODE_PNGS)

svgs:
	@echo $(GRAYCODE_SVGS)

pngs:
	@echo $(GRAYCODE_PNGS)

clean:
	rm -f $(GRAYCODE_SVGS) $(GRAYCODE_PNGS)
