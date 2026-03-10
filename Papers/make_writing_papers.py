#!/usr/bin/env python3

from paper_templates import WritingPaper

# Standard types using ruling parameter
wide = WritingPaper(ruling='wide')           # Elementary school
wide.save('wide_ruled.svg')

college = WritingPaper(ruling='college')      # Standard (default)
college.save('college_ruled.svg')

narrow = WritingPaper(ruling='narrow')        # Compact
narrow.save('narrow_ruled.svg')

# With double margin line (legal pad style)
legal = WritingPaper(ruling='wide', double_margin_line=True)
legal.save('legal_pad.svg')

# Custom spacing if you want something different
custom = WritingPaper(line_spacing=22)        # Custom spacing
custom.save('custom_ruled.svg')

# Different margin positions
wide_margin = WritingPaper(ruling='college', margin_left=108)  # 1.5 inch
wide_margin.save('wide_margin.svg')
