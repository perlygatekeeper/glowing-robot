#!/usr/bin/env python3

from paper_templates import TrianglePaper, OctagonSquarePaper, CairoPentagonalPaper, CubePaper

# All the new tessellations
TrianglePaper(triangle_size=25).save('triangles.svg')
OctagonSquarePaper(octagon_size=35).save('octagons.svg')
CairoPentagonalPaper(pentagon_size=28).save('cairo.svg')
CubePaper(cube_size=50, show_shading=True).save('cubes_3d.svg')
