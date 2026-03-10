"""
Music paper templates (staff paper, tablature, etc.)
"""

from .base import PaperTemplate


class MusicPaper(PaperTemplate):
    """Generate music staff paper"""
    
    def __init__(self, size='letter', width=None, height=None,
                 staves=10, margin_left=72, margin_right=36,
                 margin_top=72, margin_bottom=72):
        """
        Args:
            staves: Number of 5-line staves to draw
            margin_left/right/top/bottom: Margins in points
        """
        super().__init__(size, width, height)
        self.staves = staves
        self.margin_left = margin_left
        self.margin_right = margin_right
        self.margin_top = margin_top
        self.margin_bottom = margin_bottom
    
    def generate(self):
        """Generate music staff paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin_left
        end_x = self.width - self.margin_right
        usable_height = self.height - self.margin_top - self.margin_bottom
        
        # Calculate spacing
        staff_height = 8 * 4  # 4 spaces of 8 points each between 5 lines
        staff_spacing = (usable_height - (self.staves * staff_height)) / (self.staves + 1)
        
        # Draw each staff
        for staff_num in range(self.staves):
            staff_y = self.margin_top + staff_spacing + (staff_num * (staff_height + staff_spacing))
            
            # Draw 5 lines for this staff
            for line_num in range(5):
                y = staff_y + (line_num * 8)
                svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
                svg += f'stroke="#000000" stroke-width="1"/>\n'
        
        svg += self.svg_footer()
        return svg


class TablaturePaper(PaperTemplate):
    """Generate guitar/bass tablature paper"""
    
    def __init__(self, size='letter', width=None, height=None,
                 strings=6, sections=8, margin_left=72, margin_right=36,
                 margin_top=72, margin_bottom=72):
        """
        Args:
            strings: Number of strings (6 for guitar, 4 for bass)
            sections: Number of tab sections on the page
            margin_left/right/top/bottom: Margins in points
        """
        super().__init__(size, width, height)
        self.strings = strings
        self.sections = sections
        self.margin_left = margin_left
        self.margin_right = margin_right
        self.margin_top = margin_top
        self.margin_bottom = margin_bottom
    
    def generate(self):
        """Generate tablature paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin_left
        end_x = self.width - self.margin_right
        usable_height = self.height - self.margin_top - self.margin_bottom
        
        # Calculate spacing
        string_spacing = 12  # Space between strings
        section_height = (self.strings - 1) * string_spacing
        total_section_spacing = (usable_height - (self.sections * section_height)) / (self.sections + 1)
        
        # Draw each tablature section
        for section_num in range(self.sections):
            section_y = self.margin_top + total_section_spacing + (section_num * (section_height + total_section_spacing))
            
            # Draw lines for each string
            for string_num in range(self.strings):
                y = section_y + (string_num * string_spacing)
                svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
                svg += f'stroke="#000000" stroke-width="1"/>\n'
            
            # Draw vertical bar at start
            svg += f'  <line x1="{start_x}" y1="{section_y}" '
            svg += f'x2="{start_x}" y2="{section_y + section_height}" '
            svg += f'stroke="#000000" stroke-width="2"/>\n'
            
            # Optional: Add TAB label
            label_y = section_y + section_height / 2
            svg += f'  <text x="{start_x - 30}" y="{label_y}" '
            svg += f'font-family="sans-serif" font-size="10" '
            svg += f'text-anchor="end" dominant-baseline="middle">TAB</text>\n'
        
        svg += self.svg_footer()
        return svg


class ChordChartPaper(PaperTemplate):
    """Generate blank guitar chord diagram paper"""
    
    def __init__(self, size='letter', width=None, height=None,
                 charts_per_row=4, rows=6, margin=72):
        """
        Args:
            charts_per_row: Number of chord diagrams across
            rows: Number of rows of chord diagrams
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.charts_per_row = charts_per_row
        self.rows = rows
        self.margin = margin
    
    def generate(self):
        """Generate chord chart paper SVG"""
        svg = self.svg_header()
        
        content_width = self.width - 2 * self.margin
        content_height = self.height - 2 * self.margin
        
        chart_width = content_width / self.charts_per_row
        chart_height = content_height / self.rows
        
        # Chord diagram dimensions
        diagram_width = min(chart_width * 0.6, 60)
        diagram_height = diagram_width * 1.2
        strings = 6
        frets = 4
        
        # Draw each chord chart
        for row in range(self.rows):
            for col in range(self.charts_per_row):
                # Calculate position
                x = self.margin + col * chart_width + (chart_width - diagram_width) / 2
                y = self.margin + row * chart_height + (chart_height - diagram_height) / 2
                
                # Draw the chord diagram
                svg += self._draw_chord_diagram(x, y, diagram_width, diagram_height, strings, frets)
        
        svg += self.svg_footer()
        return svg
    
    def _draw_chord_diagram(self, x, y, width, height, strings, frets):
        """Draw a single blank chord diagram"""
        svg = ''
        
        string_spacing = width / (strings - 1)
        fret_spacing = height / frets
        
        # Draw strings (vertical lines)
        for i in range(strings):
            string_x = x + i * string_spacing
            svg += f'  <line x1="{string_x}" y1="{y}" x2="{string_x}" y2="{y + height}" '
            svg += f'stroke="#000000" stroke-width="1"/>\n'
        
        # Draw frets (horizontal lines)
        for i in range(frets + 1):
            fret_y = y + i * fret_spacing
            weight = "3" if i == 0 else "1"  # Nut is thicker
            svg += f'  <line x1="{x}" y1="{fret_y}" x2="{x + width}" y2="{fret_y}" '
            svg += f'stroke="#000000" stroke-width="{weight}"/>\n'
        
        # Draw string names below
        string_names = ['E', 'A', 'D', 'G', 'B', 'e']
        for i, name in enumerate(string_names):
            string_x = x + i * string_spacing
            svg += f'  <text x="{string_x}" y="{y + height + 15}" '
            svg += f'font-family="sans-serif" font-size="10" text-anchor="middle">{name}</text>\n'
        
        return svg