#!/usr/bin/env python3

from paper_templates import OrnamentalBorder

# Simple folded corner page
folded = OrnamentalBorder(size='letter', style='looped-corner')
folded.save('looped_corner_page.svg')

# With custom margin
folded_wide = OrnamentalBorder(style='looped-corner', 
                               border_width='thick', 
                               margin=50)
folded_wide.save('looped_corner_wide_margin.svg')

# A4 size
folded_a4 = OrnamentalBorder(size='a4', style='looped-corner')
folded_a4.save('looped_cornerfolded_a4.svg')
