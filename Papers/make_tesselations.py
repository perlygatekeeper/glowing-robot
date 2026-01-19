#!/usr/bin/env python3

from paper_templates import TrianglePaper, DotHexagonPaper, DotTrianglePaper, OctagonSquarePaper, OctagonDiamondPaper, CairoPentagonalPaper, CubePaper

# All the new tessellations

TrianglePaper(triangle_size=25).save('triangles.svg')

DotTrianglePaper(dot_spacing=25).save('triangle_dots.svg')

DotHexagonPaper(dot_spacing=18).save('hexagonal_dots.svg')

OctagonSquarePaper(octagon_size=35).save('octagons.svg')

OctagonDiamondPaper(octagon_size=35).save('octagon-diamonds.svg')

CairoPentagonalPaper(pentagon_size=28).save('cairo.svg')

CubePaper(cube_size=29, show_shading=True).save('cubes_3d.svg')

