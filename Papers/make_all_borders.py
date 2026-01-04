#!/usr/bin/env python3

from paper_templates import OrnamentalBorder

styles = ['simple', 'double-line', 'art-deco', 'celtic', 
          'floral', 'academic', 'victorian', 'corners-only']

for style in styles:
    border = OrnamentalBorder(size='letter', style=style, 
                             border_width='medium', margin=40)
    border.save(f'border_{style}.svg')
    print(f"Created border_{style}.svg")
