"""
Writing paper templates (lined, ruled paper)
"""

from .base import PaperTemplate


class WritingPaper(PaperTemplate):
    """Generate lined writing paper"""
    
    # Standard ruling types (line spacing in points, 1 inch = 72 points)
    RULING_TYPES = {
        'wide': 72 * (11/32),      # ~24.75 points (elementary)
        'college': 72 * (9/32),     # ~20.25 points (standard)
        'narrow': 72 * (1/4),       # 18 points (compact)
        'gregg': 72 * (11/32),      # ~24.75 points (stenography)
        'pitman': 72 * (1/2),       # 36 points (stenography)
    }
    
    def __init__(self, size='letter', width=None, height=None, 
                 ruling='college', line_spacing=None,
                 margin_left=72, margin_top=72, 
                 margin_bottom=72, double_margin_line=False, 
                 margin_line_spacing=4):
        """
        Args:
            ruling: 'wide', 'college', 'narrow', 'gregg', 'pitman' (or None to use line_spacing)
            line_spacing: Custom spacing in points (overrides ruling if provided)
            margin_left: Distance of margin line from left edge (default 72 = 1 inch)
            margin_top: Top margin before lines start
            margin_bottom: Bottom margin after lines end
            double_margin_line: If True, draw two parallel red margin lines
            margin_line_spacing: Space between double margin lines if enabled
        """
        super().__init__(size, width, height)
        
        # Use custom line_spacing if provided, otherwise use ruling type
        if line_spacing is not None:
            self.line_spacing = line_spacing
        elif ruling in self.RULING_TYPES:
            self.line_spacing = self.RULING_TYPES[ruling]
        else:
            self.line_spacing = self.RULING_TYPES['college']  # default
        
        self.margin_left = margin_left
        self.margin_top = margin_top
        self.margin_bottom = margin_bottom
        self.double_margin_line = double_margin_line
        self.margin_line_spacing = margin_line_spacing
    
    def generate(self):
        """Generate lined paper SVG"""
        svg = self.svg_header()
        
        # Calculate usable area for lines
        start_y = self.margin_top
        end_y = self.height  # Lines go to bottom of page
        
        # Horizontal lines go from edge to edge
        start_x = 0
        end_x = self.width
        
        # Draw horizontal lines
        y = start_y
        while y <= end_y:
            svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            y += self.line_spacing
        
        # Draw left margin line(s) from top to bottom of page (red)
        if self.double_margin_line:
            # Two parallel lines
            margin_line_1 = self.margin_left - self.margin_line_spacing / 2
            margin_line_2 = self.margin_left + self.margin_line_spacing / 2
            
            svg += f'  <line x1="{margin_line_1}" y1="0" '
            svg += f'x2="{margin_line_1}" y2="{self.height}" '
            svg += f'stroke="#cc0000" stroke-width="0.75" opacity="0.5"/>\n'
            
            svg += f'  <line x1="{margin_line_2}" y1="0" '
            svg += f'x2="{margin_line_2}" y2="{self.height}" '
            svg += f'stroke="#cc0000" stroke-width="0.75" opacity="0.5"/>\n'
        else:
            # Single line
            svg += f'  <line x1="{self.margin_left}" y1="0" '
            svg += f'x2="{self.margin_left}" y2="{self.height}" '
            svg += f'stroke="#cc0000" stroke-width="1" opacity="0.5"/>\n'
        
        svg += self.svg_footer()
        return svg