avr-gcc -mmcu=attiny10 -Os -o annoyatron.elf annoyatron.c
avr-objcopy -O ihex annoyatron.elf annoyatron.hex
avrdude -c usbasp -p t10 -U flash:w:annoyatron.hex
