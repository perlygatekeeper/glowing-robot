#!/usr/bin/env python3

from paper_templates import WritingPaper, OrnamentalBorder

# Create writing paper
writing = WritingPaper(ruling='college', margin_left=90, margin_top=60)
writing_svg = writing.generate()

# Get just the content (remove header and footer)
content = writing_svg.split('<svg')[1].split('</svg>')[0]
content = '<svg' + content  # Keep svg tag portion for parsing

# Add border around it
bordered_writing = OrnamentalBorder(style='floral', margin=40, inner_content=content)
bordered_writing.save('bordered_writing_paper.svg')
