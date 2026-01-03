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

# Hex paper
semilog = HexPaper(size='letter', hex_size=18, margin=0)
semilog.save('hex.svg')

# Perspective 1pt paper
perspective_1pt = PerspectivePaper(size='letter', perspective_type='1-point')
perspective_1pt.save('perspective_1pt.svg')
print("PerspectivePaper (1-point) - single vanishing point")

# Perspective 2pt paper
perspective_2pt = PerspectivePaper(size='letter', perspective_type='2-point')
perspective_2pt.save('perspective_2pt.svg')
print("PerspectivePaper (2-point) - two vanishing points")

# Perspective 3pt paper
perspective_3pt = PerspectivePaper(size='letter', perspective_type='3-point', horizon_ratio=0.4)
perspective_3pt.save('perspective_3pt.svg')
print("PerspectivePaper (3-point) - three vanishing points")
