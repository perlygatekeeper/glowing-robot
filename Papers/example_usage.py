#!/usr/bin/env python3

from printable_papers import *

# Calligraphy practice for fountain pen
calligraphy = CalligraphyPaper(x_height=48)
calligraphy.save('calligraphy.svg')

# Engineering drawing with 1/8" grid
eng = EngineeringPaper(minor_grid=9, major_grid=5)
eng.save('engineering.svg')

# Bullet journal page
dots = DotGridPaper(dot_spacing=20, dot_size=1.5)
dots.save('bullet_journal.svg')

# Polar coordinates for trig
polar = PolarPaper(size='letter', circles=20, divisions=36, margin=20)
polar.save('polar.svg')

# Semi-log for exponential data
semilog = LogarithmicPaper(x_log=False, y_log=True, cycles=4)
semilog.save('semilog.svg')
