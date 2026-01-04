"""
Printable Paper Templates Library
Generate SVG files for various types of ruled/lined paper
"""

import math
import calendar
from datetime import datetime, timedelta

class PaperTemplate:
    """Base class for paper templates"""
    
    # Standard paper sizes in points (1 inch = 72 points)
    SIZES = {
        'letter': (612, 792),      # 8.5 x 11 inches
        'a4': (595, 842),          # 210 x 297 mm
        'legal': (612, 1008),      # 8.5 x 14 inches
        'a5': (420, 595),          # 148 x 210 mm
    }
    
    def __init__(self, size='letter', width=None, height=None):
        """
        Initialize paper template
        
        Args:
            size: Standard size name ('letter', 'a4', 'legal', 'a5')
            width: Custom width in points (overrides size)
            height: Custom height in points (overrides size)
        """
        if width and height:
            self.width = width
            self.height = height
        else:
            self.width, self.height = self.SIZES.get(size, self.SIZES['letter'])
    
    def svg_header(self):
        """Generate SVG header"""
        return f'''<svg width="{self.width}" height="{self.height}" 
     viewBox="0 0 {self.width} {self.height}" 
     xmlns="http://www.w3.org/2000/svg">
  <rect width="{self.width}" height="{self.height}" fill="white"/>
'''
    
    def svg_footer(self):
        """Generate SVG footer"""
        return '</svg>'
    
    def save(self, filename):
        """Save template to SVG file"""
        with open(filename, 'w') as f:
            f.write(self.generate())
        print(f"Saved: {filename}")


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


class OrnamentalBorder(PaperTemplate):
    """Generate ornamental borders for paper templates"""
    
    BORDER_STYLES = [
        'simple',           # Clean rectangular border
        'double-line',      # Double parallel lines
        'art-deco',         # Geometric 1920s style
        'celtic',           # Celtic knot corner elements
        'floral',           # Botanical/floral decorations
        'academic',         # Formal certificate style
        'victorian',        # Ornate scrollwork
        'corners-only',     # Decorative corners, simple sides
    ]
    
    def __init__(self, size='letter', width=None, height=None,
                 style='simple', border_width='medium', margin=36,
                 inner_content=None):
        """
        Args:
            style: Border style from BORDER_STYLES
            border_width: 'thin', 'medium', 'thick' - thickness of border
            margin: Distance from page edge to border
            inner_content: Optional SVG content to place inside border
        """
        super().__init__(size, width, height)
        self.style = style if style in self.BORDER_STYLES else 'simple'
        self.border_width = border_width
        self.margin = margin
        self.inner_content = inner_content
        
        # Border thickness values
        self.thickness = {'thin': 1, 'medium': 2, 'thick': 3}[border_width]
    
    def generate(self):
        """Generate bordered paper SVG"""
        svg = self.svg_header()
        
        # Add inner content first (if provided)
        if self.inner_content:
            svg += self.inner_content
        
        # Draw border based on style
        if self.style == 'simple':
            svg += self._draw_simple_border()
        elif self.style == 'double-line':
            svg += self._draw_double_line_border()
        elif self.style == 'art-deco':
            svg += self._draw_art_deco_border()
        elif self.style == 'celtic':
            svg += self._draw_celtic_border()
        elif self.style == 'floral':
            svg += self._draw_floral_border()
        elif self.style == 'academic':
            svg += self._draw_academic_border()
        elif self.style == 'victorian':
            svg += self._draw_victorian_border()
        elif self.style == 'corners-only':
            svg += self._draw_corners_only_border()
        
        svg += self.svg_footer()
        return svg
    
    def _draw_simple_border(self):
        """Simple rectangular border"""
        svg = ''
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        return svg
    
    def _draw_double_line_border(self):
        """Double parallel line border"""
        svg = ''
        gap = 4
        
        # Outer rectangle
        x1 = self.margin
        y1 = self.margin
        w1 = self.width - 2 * self.margin
        h1 = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x1}" y="{y1}" width="{w1}" height="{h1}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        # Inner rectangle
        x2 = self.margin + gap
        y2 = self.margin + gap
        w2 = self.width - 2 * (self.margin + gap)
        h2 = self.height - 2 * (self.margin + gap)
        
        svg += f'  <rect x="{x2}" y="{y2}" width="{w2}" height="{h2}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        return svg
    
    def _draw_art_deco_border(self):
        """Art Deco geometric border with corner elements"""
        svg = ''
        
        # Main border
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness * 1.5}"/>\n'
        
        # Art Deco corner elements (stepped rectangles)
        corner_size = 30
        
        # Top-left corner
        svg += self._draw_deco_corner(x, y, corner_size, 'top-left')
        
        # Top-right corner
        svg += self._draw_deco_corner(x + w, y, corner_size, 'top-right')
        
        # Bottom-left corner
        svg += self._draw_deco_corner(x, y + h, corner_size, 'bottom-left')
        
        # Bottom-right corner
        svg += self._draw_deco_corner(x + w, y + h, corner_size, 'bottom-right')
        
        return svg
    
    def _draw_deco_corner(self, x, y, size, position):
        """Draw Art Deco style corner element"""
        svg = ''
        
        if position == 'top-left':
            # Stepped rectangles going inward
            for i in range(3):
                s = size - i * 8
                svg += f'  <rect x="{x}" y="{y}" width="{s}" height="{s}" '
                svg += f'fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        elif position == 'top-right':
            for i in range(3):
                s = size - i * 8
                svg += f'  <rect x="{x - s}" y="{y}" width="{s}" height="{s}" '
                svg += f'fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        elif position == 'bottom-left':
            for i in range(3):
                s = size - i * 8
                svg += f'  <rect x="{x}" y="{y - s}" width="{s}" height="{s}" '
                svg += f'fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        elif position == 'bottom-right':
            for i in range(3):
                s = size - i * 8
                svg += f'  <rect x="{x - s}" y="{y - s}" width="{s}" height="{s}" '
                svg += f'fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        return svg
    
    def _draw_celtic_border(self):
        """Celtic knot style corner elements with simple borders"""
        svg = ''
        
        # Main border
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        # Celtic knot corners (simplified interwoven pattern)
        corner_size = 40
        
        # Top-left
        svg += self._draw_celtic_corner(x, y, corner_size, 'top-left')
        
        # Top-right
        svg += self._draw_celtic_corner(x + w, y, corner_size, 'top-right')
        
        # Bottom-left
        svg += self._draw_celtic_corner(x, y + h, corner_size, 'bottom-left')
        
        # Bottom-right
        svg += self._draw_celtic_corner(x + w, y + h, corner_size, 'bottom-right')
        
        return svg
    
    def _draw_celtic_corner(self, x, y, size, position):
        """Draw simplified Celtic knot corner"""
        svg = ''
        
        if position == 'top-left':
            # Circular arc pattern
            svg += f'  <path d="M {x} {y + size} Q {x} {y} {x + size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
            svg += f'  <path d="M {x + 8} {y + size} Q {x + 8} {y + 8} {x + size} {y + 8}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        elif position == 'top-right':
            svg += f'  <path d="M {x} {y} Q {x} {y} {x - size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
            svg += f'  <path d="M {x - 8} {y + 8} Q {x - 8} {y + 8} {x - size} {y + 8}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
            svg += f'  <path d="M {x} {y} L {x} {y + size}" '
            svg += f'stroke="#000000" stroke-width="2"/>\n'
        
        elif position == 'bottom-left':
            svg += f'  <path d="M {x} {y - size} Q {x} {y} {x + size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
            svg += f'  <path d="M {x + 8} {y - size} Q {x + 8} {y - 8} {x + size} {y - 8}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        elif position == 'bottom-right':
            svg += f'  <path d="M {x - size} {y} Q {x} {y} {x} {y - size}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
            svg += f'  <path d="M {x - size} {y - 8} Q {x - 8} {y - 8} {x - 8} {y - size}" '
            svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        return svg
    
    def _draw_floral_border(self):
        """Floral/botanical decorative border"""
        svg = ''
        
        # Main border
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        # Floral corner elements
        size = 35
        
        # Top-left
        svg += self._draw_floral_corner(x, y, size, 'top-left')
        
        # Top-right
        svg += self._draw_floral_corner(x + w, y, size, 'top-right')
        
        # Bottom-left
        svg += self._draw_floral_corner(x, y + h, size, 'bottom-left')
        
        # Bottom-right
        svg += self._draw_floral_corner(x + w, y + h, size, 'bottom-right')
        
        return svg
    
    def _draw_floral_corner(self, x, y, size, position):
        """Draw floral corner decoration"""
        svg = ''
        
        if position == 'top-left':
            # Leaf-like curves
            svg += f'  <path d="M {x} {y + size} Q {x + 5} {y + 15} {x + 15} {y + 5} Q {x + 25} {y} {x + size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
            # Small circles (flower buds)
            svg += f'  <circle cx="{x + 12}" cy="{y + 12}" r="3" fill="none" stroke="#000000" stroke-width="1"/>\n'
            svg += f'  <circle cx="{x + 20}" cy="{y + 8}" r="2" fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        elif position == 'top-right':
            svg += f'  <path d="M {x - size} {y} Q {x - 25} {y} {x - 15} {y + 5} Q {x - 5} {y + 15} {x} {y + size}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
            svg += f'  <circle cx="{x - 12}" cy="{y + 12}" r="3" fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        elif position == 'bottom-left':
            svg += f'  <path d="M {x + size} {y} Q {x + 25} {y} {x + 15} {y - 5} Q {x + 5} {y - 15} {x} {y - size}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
            svg += f'  <circle cx="{x + 12}" cy="{y - 12}" r="3" fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        elif position == 'bottom-right':
            svg += f'  <path d="M {x} {y - size} Q {x - 5} {y - 15} {x - 15} {y - 5} Q {x - 25} {y} {x - size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
            svg += f'  <circle cx="{x - 12}" cy="{y - 12}" r="3" fill="none" stroke="#000000" stroke-width="1"/>\n'
        
        return svg
    
    def _draw_academic_border(self):
        """Formal academic/certificate style border"""
        svg = ''
        
        # Triple line border
        for offset in [0, 6, 12]:
            x = self.margin + offset
            y = self.margin + offset
            w = self.width - 2 * (self.margin + offset)
            h = self.height - 2 * (self.margin + offset)
            
            thickness = self.thickness if offset == 6 else self.thickness * 0.5
            
            svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
            svg += f'fill="none" stroke="#000000" stroke-width="{thickness}"/>\n'
        
        # Corner rosettes
        rosette_r = 15
        svg += f'  <circle cx="{self.margin + 6}" cy="{self.margin + 6}" r="{rosette_r}" '
        svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
        svg += f'  <circle cx="{self.width - self.margin - 6}" cy="{self.margin + 6}" r="{rosette_r}" '
        svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
        svg += f'  <circle cx="{self.margin + 6}" cy="{self.height - self.margin - 6}" r="{rosette_r}" '
        svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
        svg += f'  <circle cx="{self.width - self.margin - 6}" cy="{self.height - self.margin - 6}" r="{rosette_r}" '
        svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
        
        return svg
    
    def _draw_victorian_border(self):
        """Ornate Victorian scrollwork border"""
        svg = ''
        
        # Main border
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        # Inner decorative line
        inset = 8
        svg += f'  <rect x="{x + inset}" y="{y + inset}" width="{w - 2*inset}" height="{h - 2*inset}" '
        svg += f'fill="none" stroke="#000000" stroke-width="0.5"/>\n'
        
        # Victorian scrollwork corners
        size = 50
        
        for corner in ['top-left', 'top-right', 'bottom-left', 'bottom-right']:
            if corner == 'top-left':
                cx, cy = x, y
            elif corner == 'top-right':
                cx, cy = x + w, y
            elif corner == 'bottom-left':
                cx, cy = x, y + h
            else:
                cx, cy = x + w, y + h
            
            svg += self._draw_victorian_corner(cx, cy, size, corner)
        
        return svg
    
    def _draw_victorian_corner(self, x, y, size, position):
        """Draw Victorian scrollwork corner"""
        svg = ''
        
        if position == 'top-left':
            # S-curve scroll
            svg += f'  <path d="M {x} {y + size} Q {x} {y + 20} {x + 10} {y + 15} T {x + size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
            svg += f'  <path d="M {x + 5} {y + size - 5} Q {x + 5} {y + 15} {x + size - 5} {y + 5}" '
            svg += f'fill="none" stroke="#000000" stroke-width="0.75"/>\n'
        
        elif position == 'top-right':
            svg += f'  <path d="M {x - size} {y} Q {x - 20} {y} {x - 15} {y + 10} T {x} {y + size}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
        
        elif position == 'bottom-left':
            svg += f'  <path d="M {x + size} {y} Q {x + 20} {y} {x + 15} {y - 10} T {x} {y - size}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
        
        elif position == 'bottom-right':
            svg += f'  <path d="M {x} {y - size} Q {x} {y - 20} {x - 10} {y - 15} T {x - size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
        
        return svg
    
    def _draw_corners_only_border(self):
        """Decorative corners with simple side lines"""
        svg = ''
        
        # Simple border lines
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness * 0.5}"/>\n'
        
        # Bold corner brackets
        bracket_size = 40
        
        # Top-left
        svg += f'  <line x1="{x}" y1="{y}" x2="{x + bracket_size}" y2="{y}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        svg += f'  <line x1="{x}" y1="{y}" x2="{x}" y2="{y + bracket_size}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        
        # Top-right
        svg += f'  <line x1="{x + w - bracket_size}" y1="{y}" x2="{x + w}" y2="{y}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        svg += f'  <line x1="{x + w}" y1="{y}" x2="{x + w}" y2="{y + bracket_size}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        
        # Bottom-left
        svg += f'  <line x1="{x}" y1="{y + h - bracket_size}" x2="{x}" y2="{y + h}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        svg += f'  <line x1="{x}" y1="{y + h}" x2="{x + bracket_size}" y2="{y + h}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        
        # Bottom-right
        svg += f'  <line x1="{x + w}" y1="{y + h - bracket_size}" x2="{x + w}" y2="{y + h}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        svg += f'  <line x1="{x + w - bracket_size}" y1="{y + h}" x2="{x + w}" y2="{y + h}" '
        svg += f'stroke="#000000" stroke-width="{self.thickness * 2}"/>\n'
        
        return svg


class WeeklyPlannerPaper(PaperTemplate):
    """Generate weekly planner with time slots"""
    
    def __init__(self, size='letter', width=None, height=None,
                 year=None, week=None, margin=36,
                 start_hour=7, end_hour=22, hour_interval=1,
                 start_monday=True):
        """
        Args:
            year: Year for planner (default: current year)
            week: ISO week number 1-53 (default: current week)
            margin: Margin around edges
            start_hour: First hour to show (0-23)
            end_hour: Last hour to show (0-23)
            hour_interval: Hours between time slots (0.5, 1, 2, etc.)
            start_monday: Start week on Monday (False = Sunday)
        """
        super().__init__(size, width, height)
        now = datetime.now()
        self.year = year if year else now.year
        self.week = week if week else now.isocalendar()[1]
        self.margin = margin
        self.start_hour = start_hour
        self.end_hour = end_hour
        self.hour_interval = hour_interval
        self.start_monday = start_monday
    
    def generate(self):
        """Generate weekly planner SVG"""
        svg = self.svg_header()
        
        # Get dates for the week
        dates = self._get_week_dates()
        
        # Calculate dimensions
        content_width = self.width - 2 * self.margin
        content_height = self.height - 2 * self.margin
        
        title_height = 50
        grid_top = self.margin + title_height
        grid_height = content_height - title_height
        
        time_col_width = 60
        day_col_width = (content_width - time_col_width) / 7
        
        # Calculate number of time slots
        num_slots = int((self.end_hour - self.start_hour) / self.hour_interval)
        slot_height = grid_height / num_slots
        
        # Draw title
        first_date = dates[0]
        last_date = dates[-1]
        title = f"Week {self.week}, {self.year}: {first_date.strftime('%b %d')} - {last_date.strftime('%b %d')}"
        svg += f'  <text x="{self.width / 2}" y="{self.margin + 30}" '
        svg += f'font-family="sans-serif" font-size="20" font-weight="bold" '
        svg += f'text-anchor="middle">{title}</text>\n'
        
        # Draw grid border
        svg += f'  <rect x="{self.margin}" y="{grid_top}" '
        svg += f'width="{content_width}" height="{grid_height}" '
        svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        # Draw day headers
        day_names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] if self.start_monday else \
                   ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        
        for i, (day_name, date) in enumerate(zip(day_names, dates)):
            x = self.margin + time_col_width + (i + 0.5) * day_col_width
            
            # Day name
            svg += f'  <text x="{x}" y="{grid_top - 15}" '
            svg += f'font-family="sans-serif" font-size="12" font-weight="bold" '
            svg += f'text-anchor="middle">{day_name}</text>\n'
            
            # Date
            svg += f'  <text x="{x}" y="{grid_top - 2}" '
            svg += f'font-family="sans-serif" font-size="10" '
            svg += f'text-anchor="middle" fill="#666666">{date.strftime("%m/%d")}</text>\n'
        
        # Draw vertical lines (days)
        for i in range(8):
            x = self.margin + time_col_width + i * day_col_width
            svg += f'  <line x1="{x}" y1="{grid_top}" x2="{x}" y2="{grid_top + grid_height}" '
            svg += f'stroke="#000000" stroke-width="1"/>\n'
        
        # Draw time column separator
        svg += f'  <line x1="{self.margin + time_col_width}" y1="{grid_top}" '
        svg += f'x2="{self.margin + time_col_width}" y2="{grid_top + grid_height}" '
        svg += f'stroke="#000000" stroke-width="2"/>\n'
        
        # Draw horizontal lines (time slots) and time labels
        for i in range(num_slots + 1):
            y = grid_top + i * slot_height
            hour = self.start_hour + i * self.hour_interval
            
            # Heavier line every hour
            weight = "1.5" if hour % 1 == 0 else "0.5"
            opacity = "1" if hour % 1 == 0 else "0.3"
            
            svg += f'  <line x1="{self.margin + time_col_width}" y1="{y}" '
            svg += f'x2="{self.margin + content_width}" y2="{y}" '
            svg += f'stroke="#666666" stroke-width="{weight}" opacity="{opacity}"/>\n'
            
            # Time label
            if hour < self.end_hour:
                hour_int = int(hour)
                minute = int((hour - hour_int) * 60)
                time_str = f"{hour_int:02d}:{minute:02d}"
                
                svg += f'  <text x="{self.margin + time_col_width - 5}" y="{y + 15}" '
                svg += f'font-family="sans-serif" font-size="10" '
                svg += f'text-anchor="end" fill="#666666">{time_str}</text>\n'
        
        svg += self.svg_footer()
        return svg
    
    def _get_week_dates(self):
        """Get list of dates for the specified week"""
        # Get first day of the week
        jan1 = datetime(self.year, 1, 1)
        week_start = jan1 + timedelta(days=(self.week - 1) * 7)
        
        # Adjust to Monday if needed
        days_since_monday = week_start.weekday()
        week_start = week_start - timedelta(days=days_since_monday)
        
        # Generate 7 dates
        if self.start_monday:
            return [week_start + timedelta(days=i) for i in range(7)]
        else:
            # Start on Sunday
            sunday_start = week_start - timedelta(days=1)
            return [sunday_start + timedelta(days=i) for i in range(7)]


class YearlyCalendarPaper(PaperTemplate):
    """Generate year-at-a-glance calendar"""
    
    def __init__(self, size='letter', width=None, height=None,
                 year=None, margin=36, start_monday=False,
                 landscape=True):
        """
        Args:
            year: Year for calendar (default: current year)
            margin: Margin around edges
            start_monday: Start week on Monday (False = Sunday)
            landscape: Use landscape orientation (recommended)
        """
        super().__init__(size, width, height)
        self.year = year if year else datetime.now().year
        self.margin = margin
        self.start_monday = start_monday
        
        # Swap dimensions for landscape
        if landscape and self.width < self.height:
            self.width, self.height = self.height, self.width
    
    def generate(self):
        """Generate yearly calendar SVG"""
        svg = self.svg_header()
        
        # Calculate dimensions
        content_width = self.width - 2 * self.margin
        content_height = self.height - 2 * self.margin
        
        title_height = 60
        grid_top = self.margin + title_height
        available_height = content_height - title_height
        
        # 3 rows x 4 columns
        month_width = content_width / 4
        month_height = available_height / 3
        
        # Draw title
        svg += f'  <text x="{self.width / 2}" y="{self.margin + 40}" '
        svg += f'font-family="serif" font-size="48" font-weight="bold" '
        svg += f'text-anchor="middle">{self.year}</text>\n'
        
        # Draw each month
        for month_num in range(1, 13):
            row = (month_num - 1) // 4
            col = (month_num - 1) % 4
            
            month_x = self.margin + col * month_width
            month_y = grid_top + row * month_height
            
            svg += self._draw_mini_month(month_num, month_x, month_y, 
                                        month_width, month_height)
        
        svg += self.svg_footer()
        return svg
    
    def _draw_mini_month(self, month_num, x, y, width, height):
        """Draw a small monthly calendar"""
        svg = ''
        
        month_name = calendar.month_name[month_num]
        cal = calendar.monthcalendar(self.year, month_num)
        
        # Month title
        title_height = 25
        svg += f'  <text x="{x + width / 2}" y="{y + 18}" '
        svg += f'font-family="sans-serif" font-size="14" font-weight="bold" '
        svg += f'text-anchor="middle">{month_name}</text>\n'
        
        # Grid dimensions
        grid_y = y + title_height
        grid_height = height - title_height - 5
        
        cell_width = (width - 10) / 7
        num_weeks = len(cal)
        cell_height = grid_height / (num_weeks + 1)  # +1 for header
        
        # Day names
        day_names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'] if self.start_monday else \
                   ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        
        for i, day_name in enumerate(day_names):
            dx = x + 5 + (i + 0.5) * cell_width
            dy = grid_y + cell_height * 0.6
            svg += f'  <text x="{dx}" y="{dy}" font-family="sans-serif" '
            svg += f'font-size="7" text-anchor="middle" fill="#666666">{day_name}</text>\n'
        
        # Dates
        for week_num, week in enumerate(cal):
            for day_num, day in enumerate(week):
                if day != 0:
                    dx = x + 5 + (day_num + 0.5) * cell_width
                    dy = grid_y + (week_num + 1.6) * cell_height
                    
                    # Check if today
                    is_today = (day == datetime.now().day and 
                               month_num == datetime.now().month and 
                               self.year == datetime.now().year)
                    
                    if is_today:
                        svg += f'  <circle cx="{dx}" cy="{dy - 2}" r="7" '
                        svg += f'fill="#ffcc00" stroke="none"/>\n'
                    
                    weight = "bold" if is_today else "normal"
                    svg += f'  <text x="{dx}" y="{dy}" font-family="sans-serif" '
                    svg += f'font-size="8" font-weight="{weight}" text-anchor="middle">{day}</text>\n'
        
        # Border
        svg += f'  <rect x="{x + 2}" y="{y + 2}" width="{width - 4}" height="{height - 4}" '
        svg += f'fill="none" stroke="#cccccc" stroke-width="1"/>\n'
        
        return svg


class HabitTrackerPaper(PaperTemplate):
    """Generate habit tracker grid"""
    
    def __init__(self, size='letter', width=None, height=None,
                 year=None, month=None, margin=36,
                 num_habits=15):
        """
        Args:
            year: Year for tracker (default: current year)
            month: Month number 1-12 (default: current month)
            margin: Margin around edges
            num_habits: Number of habit rows to include
        """
        super().__init__(size, width, height)
        self.year = year if year else datetime.now().year
        self.month = month if month else datetime.now().month
        self.margin = margin
        self.num_habits = num_habits
    
    def generate(self):
        """Generate habit tracker SVG"""
        svg = self.svg_header()
        
        month_name = calendar.month_name[self.month]
        days_in_month = calendar.monthrange(self.year, self.month)[1]
        
        # Calculate dimensions
        content_width = self.width - 2 * self.margin
        content_height = self.height - 2 * self.margin
        
        title_height = 50
        grid_top = self.margin + title_height + 10
        grid_height = content_height - title_height - 10
        
        habit_col_width = 150
        day_col_width = (content_width - habit_col_width) / days_in_month
        row_height = grid_height / (self.num_habits + 1)  # +1 for header
        
        # Draw title
        svg += f'  <text x="{self.width / 2}" y="{self.margin + 35}" '
        svg += f'font-family="sans-serif" font-size="28" font-weight="bold" '
        svg += f'text-anchor="middle">{month_name} {self.year} - Habit Tracker</text>\n'
        
        # Draw grid border
        svg += f'  <rect x="{self.margin}" y="{grid_top}" '
        svg += f'width="{content_width}" height="{grid_height}" '
        svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        # Draw habit column separator
        svg += f'  <line x1="{self.margin + habit_col_width}" y1="{grid_top}" '
        svg += f'x2="{self.margin + habit_col_width}" y2="{grid_top + grid_height}" '
        svg += f'stroke="#000000" stroke-width="2"/>\n'
        
        # Draw header row separator
        svg += f'  <line x1="{self.margin}" y1="{grid_top + row_height}" '
        svg += f'x2="{self.margin + content_width}" y2="{grid_top + row_height}" '
        svg += f'stroke="#000000" stroke-width="2"/>\n'
        
        # Draw day numbers in header
        for day in range(1, days_in_month + 1):
            x = self.margin + habit_col_width + (day - 0.5) * day_col_width
            y = grid_top + row_height * 0.6
            
            font_size = "10" if day_col_width > 15 else "8"
            svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
            svg += f'font-size="{font_size}" text-anchor="middle">{day}</text>\n'
        
        # Draw vertical lines for days
        for day in range(days_in_month + 1):
            x = self.margin + habit_col_width + day * day_col_width
            weight = "0.5"
            svg += f'  <line x1="{x}" y1="{grid_top + row_height}" '
            svg += f'x2="{x}" y2="{grid_top + grid_height}" '
            svg += f'stroke="#cccccc" stroke-width="{weight}"/>\n'
        
        # Draw horizontal lines for habits
        for i in range(self.num_habits + 1):
            y = grid_top + (i + 1) * row_height
            svg += f'  <line x1="{self.margin}" y1="{y}" '
            svg += f'x2="{self.margin + content_width}" y2="{y}" '
            svg += f'stroke="#cccccc" stroke-width="0.5"/>\n'
        
        # Habit label column header
        svg += f'  <text x="{self.margin + 5}" y="{grid_top + row_height * 0.6}" '
        svg += f'font-family="sans-serif" font-size="12" font-weight="bold">Habit</text>\n'
        
        # Placeholder habit labels
        for i in range(self.num_habits):
            y = grid_top + (i + 1.6) * row_height
            svg += f'  <text x="{self.margin + 5}" y="{y}" '
            svg += f'font-family="sans-serif" font-size="10" fill="#999999">Habit {i + 1}</text>\n'
        
        svg += self.svg_footer()
        return svg


class CalendarPaper(PaperTemplate):
    """Generate monthly calendar pages"""
    
    def __init__(self, size='letter', width=None, height=None,
                 year=None, month=None, margin=36, 
                 show_week_numbers=False, start_monday=False):
        """
        Args:
            year: Year for calendar (default: current year)
            month: Month number 1-12 (default: current month)
            margin: Margin around edges
            show_week_numbers: Show week numbers in left column
            start_monday: Start week on Monday (False = Sunday)
        """
        super().__init__(size, width, height)
        self.year = year if year else datetime.now().year
        self.month = month if month else datetime.now().month
        self.margin = margin
        self.show_week_numbers = show_week_numbers
        self.start_monday = start_monday
    
    def generate(self):
        """Generate monthly calendar SVG"""
        svg = self.svg_header()
        
        # Get calendar data
        cal = calendar.monthcalendar(self.year, self.month)
        month_name = calendar.month_name[self.month]
        
        # Calculate dimensions
        content_width = self.width - 2 * self.margin
        content_height = self.height - 2 * self.margin
        
        # Title area
        title_height = 60
        
        # Calendar grid
        grid_top = self.margin + title_height + 20
        grid_height = content_height - title_height - 20
        
        # Number of columns (7 days + optional week number column)
        num_cols = 8 if self.show_week_numbers else 7
        col_width = content_width / num_cols
        
        # Number of rows (header + weeks)
        num_rows = len(cal) + 1  # +1 for day names header
        row_height = grid_height / num_rows
        
        # Draw title
        title_y = self.margin + 40
        svg += f'  <text x="{self.width / 2}" y="{title_y}" '
        svg += f'font-family="serif" font-size="36" font-weight="bold" '
        svg += f'text-anchor="middle" fill="#000000">'
        svg += f'{month_name} {self.year}</text>\n'
        
        # Draw grid border
        svg += f'  <rect x="{self.margin}" y="{grid_top}" '
        svg += f'width="{content_width}" height="{grid_height}" '
        svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        # Draw column lines
        for i in range(num_cols + 1):
            x = self.margin + i * col_width
            weight = "2" if i == 0 or i == num_cols else "1"
            svg += f'  <line x1="{x}" y1="{grid_top}" x2="{x}" y2="{grid_top + grid_height}" '
            svg += f'stroke="#000000" stroke-width="{weight}"/>\n'
        
        # Draw row lines
        for i in range(num_rows + 1):
            y = grid_top + i * row_height
            weight = "2" if i == 0 or i == 1 or i == num_rows else "1"
            svg += f'  <line x1="{self.margin}" y1="{y}" x2="{self.margin + content_width}" y2="{y}" '
            svg += f'stroke="#000000" stroke-width="{weight}"/>\n'
        
        # Day names header
        day_names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] if self.start_monday else \
                   ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        
        col_offset = 1 if self.show_week_numbers else 0
        
        # Week number header
        if self.show_week_numbers:
            x = self.margin + col_width / 2
            y = grid_top + row_height * 0.6
            svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
            svg += f'font-size="12" font-weight="bold" text-anchor="middle" fill="#666666">'
            svg += f'Wk</text>\n'
        
        # Draw day names
        for i, day_name in enumerate(day_names):
            x = self.margin + (i + col_offset + 0.5) * col_width
            y = grid_top + row_height * 0.6
            svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
            svg += f'font-size="14" font-weight="bold" text-anchor="middle" fill="#000000">'
            svg += f'{day_name}</text>\n'
        
        # Draw calendar dates
        for week_num, week in enumerate(cal):
            row_y = grid_top + (week_num + 1) * row_height
            
            # Week number
            if self.show_week_numbers:
                # Calculate ISO week number
                first_day = next((d for d in week if d != 0), 1)
                date_obj = datetime(self.year, self.month, first_day)
                iso_week = date_obj.isocalendar()[1]
                
                x = self.margin + col_width / 2
                y = row_y + row_height * 0.25
                svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
                svg += f'font-size="10" text-anchor="middle" fill="#999999">'
                svg += f'{iso_week}</text>\n'
            
            # Days
            for day_num, day in enumerate(week):
                if day != 0:  # 0 means no day in this cell
                    x = self.margin + (day_num + col_offset) * col_width + 8
                    y = row_y + 20
                    
                    # Check if weekend (Saturday=5, Sunday=6 in 0-indexed week starting Monday)
                    # Or (Saturday=6, Sunday=0 in 0-indexed week starting Sunday)
                    is_weekend = False
                    if self.start_monday:
                        is_weekend = day_num >= 5
                    else:
                        is_weekend = day_num == 0 or day_num == 6
                    
                    # Check if today
                    is_today = (day == datetime.now().day and 
                               self.month == datetime.now().month and 
                               self.year == datetime.now().year)
                    
                    # Highlight today
                    if is_today:
                        cell_x = self.margin + (day_num + col_offset) * col_width
                        svg += f'  <rect x="{cell_x + 2}" y="{row_y + 2}" '
                        svg += f'width="{col_width - 4}" height="{row_height - 4}" '
                        svg += f'fill="#ffffcc" stroke="none"/>\n'
                    
                    # Day number
                    color = "#cc0000" if is_weekend else "#000000"
                    weight = "bold" if is_today else "normal"
                    
                    svg += f'  <text x="{x}" y="{y}" font-family="sans-serif" '
                    svg += f'font-size="16" font-weight="{weight}" fill="{color}">'
                    svg += f'{day}</text>\n'
        
        svg += self.svg_footer()
        return svg


class MathPaper(PaperTemplate):
    """Generate graph/grid paper for math"""
    
    def __init__(self, size='letter', width=None, height=None,
                 grid_size=18, margin=36, heavy_every=5):
        """
        Args:
            grid_size: Size of grid squares in points (default 18 = 1/4 inch)
            margin: Margin around edges in points
            heavy_every: Draw heavy line every N squares (0 = no heavy lines)
        """
        super().__init__(size, width, height)
        self.grid_size = grid_size
        self.margin = margin
        self.heavy_every = heavy_every
    
    def generate(self):
        """Generate grid paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin
        start_y = self.margin
        end_x = self.width - self.margin
        end_y = self.height - self.margin
        
        # Vertical lines
        x = start_x
        count = 0
        while x <= end_x:
            if self.heavy_every > 0 and count % self.heavy_every == 0:
                weight = "1.5"
                opacity = "0.6"
            else:
                weight = "0.5"
                opacity = "0.3"
            
            svg += f'  <line x1="{x}" y1="{start_y}" x2="{x}" y2="{end_y}" '
            svg += f'stroke="#0066cc" stroke-width="{weight}" opacity="{opacity}"/>\n'
            x += self.grid_size
            count += 1
        
        # Horizontal lines
        y = start_y
        count = 0
        while y <= end_y:
            if self.heavy_every > 0 and count % self.heavy_every == 0:
                weight = "1.5"
                opacity = "0.6"
            else:
                weight = "0.5"
                opacity = "0.3"
            
            svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
            svg += f'stroke="#0066cc" stroke-width="{weight}" opacity="{opacity}"/>\n'
            y += self.grid_size
            count += 1
        
        svg += self.svg_footer()
        return svg


class SciencePaper(PaperTemplate):
    """Generate lab notebook paper (lines with left column for notes)"""
    
    def __init__(self, size='letter', width=None, height=None,
                 line_spacing=24, margin=72, column_width=144):
        """
        Args:
            line_spacing: Space between lines in points
            margin: Margin around edges
            column_width: Width of left column for labels/notes
        """
        super().__init__(size, width, height)
        self.line_spacing = line_spacing
        self.margin = margin
        self.column_width = column_width
    
    def generate(self):
        """Generate lab notebook paper SVG"""
        svg = self.svg_header()
        
        start_y = self.margin
        end_y = self.height - self.margin
        start_x = self.margin
        end_x = self.width - self.margin
        column_x = start_x + self.column_width
        
        # Draw horizontal lines
        y = start_y
        while y <= end_y:
            svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            y += self.line_spacing
        
        # Draw column separator (heavier line)
        svg += f'  <line x1="{column_x}" y1="{start_y}" '
        svg += f'x2="{column_x}" y2="{end_y}" '
        svg += f'stroke="#cc0000" stroke-width="1.5" opacity="0.5"/>\n'
        
        # Draw border
        svg += f'  <rect x="{start_x}" y="{start_y}" '
        svg += f'width="{end_x - start_x}" height="{end_y - start_y}" '
        svg += f'fill="none" stroke="#000000" stroke-width="2" opacity="0.3"/>\n'
        
        svg += self.svg_footer()
        return svg


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


class CalligraphyPaper(PaperTemplate):
    """Generate calligraphy practice paper with guide lines"""
    
    def __init__(self, size='letter', width=None, height=None,
                 x_height=36, margin_left=72, margin_right=72,
                 margin_top=72, margin_bottom=72):
        """
        Args:
            x_height: Height of lowercase letters in points (default 36 = 0.5 inch)
            margin_left/right/top/bottom: Margins in points
        """
        super().__init__(size, width, height)
        self.x_height = x_height
        self.margin_left = margin_left
        self.margin_right = margin_right
        self.margin_top = margin_top
        self.margin_bottom = margin_bottom
    
    def generate(self):
        """Generate calligraphy practice paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin_left
        end_x = self.width - self.margin_right
        start_y = self.margin_top
        end_y = self.height - self.margin_bottom
        
        # Calculate line spacing (ascender + x-height + descender + gap)
        ascender = self.x_height * 0.75
        descender = self.x_height * 0.75
        gap = self.x_height * 0.5
        line_set_height = ascender + self.x_height + descender + gap
        
        y = start_y
        while y + ascender + self.x_height + descender <= end_y:
            # Ascender line (light)
            svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.2"/>\n'
            
            # Cap line (medium)
            cap_y = y + ascender * 0.3
            svg += f'  <line x1="{start_x}" y1="{cap_y}" x2="{end_x}" y2="{cap_y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            
            # Waist line (heavy - top of x-height)
            waist_y = y + ascender
            svg += f'  <line x1="{start_x}" y1="{waist_y}" x2="{end_x}" y2="{waist_y}" '
            svg += f'stroke="#000000" stroke-width="1" opacity="0.5"/>\n'
            
            # Base line (heavy - bottom of x-height)
            base_y = waist_y + self.x_height
            svg += f'  <line x1="{start_x}" y1="{base_y}" x2="{end_x}" y2="{base_y}" '
            svg += f'stroke="#000000" stroke-width="1.5" opacity="0.7"/>\n'
            
            # Descender line (light)
            descender_y = base_y + descender
            svg += f'  <line x1="{start_x}" y1="{descender_y}" x2="{end_x}" y2="{descender_y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.2"/>\n'
            
            # Optional: 55-degree slant lines for italic practice
            slant_spacing = 36
            x = start_x
            while x <= end_x:
                x1 = x
                y1 = waist_y
                x2 = x + (self.x_height / math.tan(math.radians(55)))
                y2 = base_y
                svg += f'  <line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
                svg += f'stroke="#cc0000" stroke-width="0.3" opacity="0.15"/>\n'
                x += slant_spacing
            
            y += line_set_height
        
        svg += self.svg_footer()
        return svg


class EngineeringPaper(PaperTemplate):
    """Generate engineering paper with major and minor grid lines"""
    
    def __init__(self, size='letter', width=None, height=None,
                 minor_grid=9, major_grid=5, margin=36):
        """
        Args:
            minor_grid: Size of minor grid squares in points (default 9 = 1/8 inch)
            major_grid: Number of minor squares per major grid (default 5)
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.minor_grid = minor_grid
        self.major_grid = major_grid
        self.margin = margin
    
    def generate(self):
        """Generate engineering grid paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin
        start_y = self.margin
        end_x = self.width - self.margin
        end_y = self.height - self.margin
        
        # Vertical lines
        x = start_x
        count = 0
        while x <= end_x:
            if count % self.major_grid == 0:
                weight = "2"
                opacity = "0.7"
                color = "#000000"
            else:
                weight = "0.5"
                opacity = "0.3"
                color = "#0066cc"
            
            svg += f'  <line x1="{x}" y1="{start_y}" x2="{x}" y2="{end_y}" '
            svg += f'stroke="{color}" stroke-width="{weight}" opacity="{opacity}"/>\n'
            x += self.minor_grid
            count += 1
        
        # Horizontal lines
        y = start_y
        count = 0
        while y <= end_y:
            if count % self.major_grid == 0:
                weight = "2"
                opacity = "0.7"
                color = "#000000"
            else:
                weight = "0.5"
                opacity = "0.3"
                color = "#0066cc"
            
            svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
            svg += f'stroke="{color}" stroke-width="{weight}" opacity="{opacity}"/>\n'
            y += self.minor_grid
            count += 1
        
        svg += self.svg_footer()
        return svg


class IsometricPaper(PaperTemplate):
    """Generate isometric grid for 3D drawings"""
    
    def __init__(self, size='letter', width=None, height=None,
                 grid_size=18, margin=36):
        """
        Args:
            grid_size: Distance between grid lines in points
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.grid_size = grid_size
        self.margin = margin
    
    def generate(self):
        """Generate isometric grid paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin
        start_y = self.margin
        end_x = self.width - self.margin
        end_y = self.height - self.margin
        
        # Isometric grid uses three angles: 30°, 90° (vertical), 150°
        h_spacing = self.grid_size * math.cos(math.radians(30))
        v_spacing = self.grid_size * math.sin(math.radians(30))
        
        # Draw lines at 30° (right-leaning)
        x = start_x
        while x <= end_x + end_y:
            y_start = max(start_y, start_y + (start_x - x) * math.tan(math.radians(30)))
            y_end = min(end_y, start_y + (end_x - x) * math.tan(math.radians(30)))
            x_start = x if x >= start_x else start_x
            x_end = x + (end_y - start_y) / math.tan(math.radians(30))
            x_end = min(x_end, end_x)
            
            if x_start <= end_x and y_start <= end_y:
                svg += f'  <line x1="{x_start}" y1="{y_start}" x2="{x_end}" y2="{y_end}" '
                svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            x += h_spacing
        
        # Draw lines at 150° (left-leaning)
        x = start_x - end_y
        while x <= end_x:
            x_start = max(start_x, x)
            x_end = min(end_x, x + (end_y - start_y) / math.tan(math.radians(30)))
            y_start = start_y + (x_start - x) * math.tan(math.radians(30))
            y_end = end_y
            
            if x_start <= end_x and x_end >= start_x:
                svg += f'  <line x1="{x_start}" y1="{y_start}" x2="{x_end}" y2="{y_end}" '
                svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            x += h_spacing
        
        # Draw vertical lines
        x = start_x
        while x <= end_x:
            svg += f'  <line x1="{x}" y1="{start_y}" x2="{x}" y2="{end_y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            x += h_spacing
        
        svg += self.svg_footer()
        return svg


class DotGridPaper(PaperTemplate):
    """Generate dot grid paper (popular for bullet journals)"""
    
    def __init__(self, size='letter', width=None, height=None,
                 dot_spacing=18, margin=36, dot_size=1):
        """
        Args:
            dot_spacing: Space between dots in points (default 18 = 1/4 inch)
            margin: Margin around edges
            dot_size: Radius of dots in points
        """
        super().__init__(size, width, height)
        self.dot_spacing = dot_spacing
        self.margin = margin
        self.dot_size = dot_size
    
    def generate(self):
        """Generate dot grid paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin
        start_y = self.margin
        end_x = self.width - self.margin
        end_y = self.height - self.margin
        
        # Draw dots
        y = start_y
        while y <= end_y:
            x = start_x
            while x <= end_x:
                svg += f'  <circle cx="{x}" cy="{y}" r="{self.dot_size}" '
                svg += f'fill="#0066cc" opacity="0.3"/>\n'
                x += self.dot_spacing
            y += self.dot_spacing
        
        svg += self.svg_footer()
        return svg


class PolarPaper(PaperTemplate):
    """Generate polar coordinate graph paper"""
    
    def __init__(self, size='letter', width=None, height=None,
                 circles=10, divisions=12, margin=36):
        """
        Args:
            circles: Number of concentric circles
            divisions: Number of angular divisions (12 = 30° each)
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.circles = circles
        self.divisions = divisions
        self.margin = margin
    
    def generate(self):
        """Generate polar graph paper SVG"""
        svg = self.svg_header()
        
        # Center of the polar grid
        center_x = self.width / 2
        center_y = self.height / 2
        max_radius = min(self.width, self.height) / 2 - self.margin
        
        # Draw concentric circles
        for i in range(1, self.circles + 1):
            radius = (i / self.circles) * max_radius
            svg += f'  <circle cx="{center_x}" cy="{center_y}" r="{radius}" '
            svg += f'fill="none" stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
        
        # Draw radial lines
        for i in range(self.divisions):
            angle = (i * 360 / self.divisions) - 90
            angle_rad = math.radians(angle)
            x_end = center_x + max_radius * math.cos(angle_rad)
            y_end = center_y + max_radius * math.sin(angle_rad)
            
            # Make major angles (0°, 90°, 180°, 270°) heavier
            if i % (self.divisions // 4) == 0:
                weight = "1.5"
                opacity = "0.5"
            else:
                weight = "0.5"
                opacity = "0.3"
            
            svg += f'  <line x1="{center_x}" y1="{center_y}" x2="{x_end}" y2="{y_end}" '
            svg += f'stroke="#0066cc" stroke-width="{weight}" opacity="{opacity}"/>\n'
        
        svg += self.svg_footer()
        return svg


class LogarithmicPaper(PaperTemplate):
    """Generate logarithmic (semi-log or log-log) graph paper"""
    
    def __init__(self, size='letter', width=None, height=None,
                 x_log=False, y_log=True, cycles=3, margin=72):
        """
        Args:
            x_log: Use logarithmic scale for x-axis
            y_log: Use logarithmic scale for y-axis
            cycles: Number of log cycles to show
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.x_log = x_log
        self.y_log = y_log
        self.cycles = cycles
        self.margin = margin
    
    def generate(self):
        """Generate logarithmic graph paper SVG"""
        svg = self.svg_header()
        
        start_x = self.margin
        start_y = self.margin
        end_x = self.width - self.margin
        end_y = self.height - self.margin
        
        width = end_x - start_x
        height = end_y - start_y
        
        # Draw vertical lines (x-axis)
        if self.x_log:
            for cycle in range(self.cycles):
                cycle_width = width / self.cycles
                cycle_start = start_x + cycle * cycle_width
                for i in range(1, 10):
                    x = cycle_start + math.log10(i) * cycle_width
                    weight = "1.5" if i == 1 else "0.5"
                    opacity = "0.5" if i == 1 else "0.3"
                    svg += f'  <line x1="{x}" y1="{start_y}" x2="{x}" y2="{end_y}" '
                    svg += f'stroke="#0066cc" stroke-width="{weight}" opacity="{opacity}"/>\n'
        else:
            # Linear x-axis
            divisions = 10
            for i in range(divisions + 1):
                x = start_x + (i / divisions) * width
                weight = "1.5" if i % 5 == 0 else "0.5"
                opacity = "0.5" if i % 5 == 0 else "0.3"
                svg += f'  <line x1="{x}" y1="{start_y}" x2="{x}" y2="{end_y}" '
                svg += f'stroke="#0066cc" stroke-width="{weight}" opacity="{opacity}"/>\n'
        
        # Draw horizontal lines (y-axis)
        if self.y_log:
            for cycle in range(self.cycles):
                cycle_height = height / self.cycles
                cycle_start = end_y - (cycle + 1) * cycle_height
                for i in range(1, 10):
                    y = cycle_start + cycle_height - (math.log10(i) * cycle_height)
                    weight = "1.5" if i == 1 else "0.5"
                    opacity = "0.5" if i == 1 else "0.3"
                    svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
                    svg += f'stroke="#0066cc" stroke-width="{weight}" opacity="{opacity}"/>\n'
        else:
            # Linear y-axis
            divisions = 10
            for i in range(divisions + 1):
                y = start_y + (i / divisions) * height
                weight = "1.5" if i % 5 == 0 else "0.5"
                opacity = "0.5" if i % 5 == 0 else "0.3"
                svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
                svg += f'stroke="#0066cc" stroke-width="{weight}" opacity="{opacity}"/>\n'
        
        # Draw border
        svg += f'  <rect x="{start_x}" y="{start_y}" width="{width}" height="{height}" '
        svg += f'fill="none" stroke="#000000" stroke-width="2"/>\n'
        
        svg += self.svg_footer()
        return svg


class HexPaper(PaperTemplate):
    """Generate hexagonal grid paper"""
    
    def __init__(self, size='letter', width=None, height=None,
                 hex_size=18, margin=36):
        """
        Args:
            hex_size: Distance from center to vertex in points
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.hex_size = hex_size
        self.margin = margin
    
    def generate(self):
        """Generate hexagonal grid paper SVG"""
        svg = self.svg_header()
        
        # Hexagon dimensions
        width_spacing = self.hex_size * math.sqrt(3)
        height_spacing = self.hex_size * 1.5
        
        start_x = self.margin
        start_y = self.margin
        
        row = 0
        y = start_y
        while y < self.height - self.margin:
            x = start_x
            if row % 2 == 1:
                x += width_spacing / 2
            
            col = 0
            while x < self.width - self.margin:
                # Draw hexagon
                points = []
                for i in range(6):
                    angle = math.radians(60 * i - 30)
                    px = x + self.hex_size * math.cos(angle)
                    py = y + self.hex_size * math.sin(angle)
                    points.append(f"{px},{py}")
                
                svg += f'  <polygon points="{" ".join(points)}" '
                svg += f'fill="none" stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
                
                x += width_spacing
                col += 1
            
            y += height_spacing
            row += 1
        
        svg += self.svg_footer()
        return svg


class PerspectivePaper(PaperTemplate):
    """Generate perspective grid paper for technical drawing"""
    
    def __init__(self, size='letter', width=None, height=None,
                 perspective_type='1-point', margin=36, 
                 horizon_ratio=0.5, grid_spacing=36):
        """
        Args:
            perspective_type: '1-point', '2-point', or '3-point'
            margin: Margin around edges
            horizon_ratio: Position of horizon line (0.0 = top, 1.0 = bottom, 0.5 = middle)
            grid_spacing: Spacing of grid lines in points
        """
        super().__init__(size, width, height)
        self.perspective_type = perspective_type
        self.margin = margin
        self.horizon_ratio = horizon_ratio
        self.grid_spacing = grid_spacing
    
    def generate(self):
        """Generate perspective grid paper SVG"""
        svg = self.svg_header()
        
        # Calculate horizon line position
        horizon_y = self.margin + (self.height - 2 * self.margin) * self.horizon_ratio
        
        if self.perspective_type == '1-point':
            svg += self._generate_one_point(horizon_y)
        elif self.perspective_type == '2-point':
            svg += self._generate_two_point(horizon_y)
        elif self.perspective_type == '3-point':
            svg += self._generate_three_point(horizon_y)
        else:
            raise ValueError("perspective_type must be '1-point', '2-point', or '3-point'")
        
        svg += self.svg_footer()
        return svg
    
    def _generate_one_point(self, horizon_y):
        """Generate 1-point perspective grid"""
        svg = ''
        
        # Vanishing point at center of horizon
        vp_x = self.width / 2
        vp_y = horizon_y
        
        # Draw horizon line (heavy)
        svg += f'  <line x1="{self.margin}" y1="{horizon_y}" '
        svg += f'x2="{self.width - self.margin}" y2="{horizon_y}" '
        svg += f'stroke="#cc0000" stroke-width="1.5" opacity="0.7"/>\n'
        
        # Draw vanishing point
        svg += f'  <circle cx="{vp_x}" cy="{vp_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        
        # Vertical grid lines (parallel to picture plane)
        x = self.margin
        while x <= self.width - self.margin:
            svg += f'  <line x1="{x}" y1="{self.margin}" x2="{x}" y2="{self.height - self.margin}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            x += self.grid_spacing
        
        # Horizontal grid lines (parallel to picture plane)
        y = self.margin
        while y <= self.height - self.margin:
            if abs(y - horizon_y) > 5:  # Skip lines too close to horizon
                svg += f'  <line x1="{self.margin}" y1="{y}" x2="{self.width - self.margin}" y2="{y}" '
                svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            y += self.grid_spacing
        
        # Radial lines to vanishing point (from corners and edges)
        corners = [
            (self.margin, self.margin),
            (self.width - self.margin, self.margin),
            (self.margin, self.height - self.margin),
            (self.width - self.margin, self.height - self.margin)
        ]
        
        # Add more points along edges for denser grid
        num_divisions = 8
        for i in range(num_divisions + 1):
            t = i / num_divisions
            # Top edge
            corners.append((self.margin + t * (self.width - 2 * self.margin), self.margin))
            # Bottom edge
            corners.append((self.margin + t * (self.width - 2 * self.margin), self.height - self.margin))
            # Left edge (skip horizon area)
            y_pos = self.margin + t * (self.height - 2 * self.margin)
            if abs(y_pos - horizon_y) > 20:
                corners.append((self.margin, y_pos))
            # Right edge (skip horizon area)
            if abs(y_pos - horizon_y) > 20:
                corners.append((self.width - self.margin, y_pos))
        
        for corner_x, corner_y in corners:
            svg += f'  <line x1="{vp_x}" y1="{vp_y}" x2="{corner_x}" y2="{corner_y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.2"/>\n'
        
        return svg
    
    def _generate_two_point(self, horizon_y):
        """Generate 2-point perspective grid"""
        svg = ''
        
        # Two vanishing points on horizon line
        vp1_x = self.margin + (self.width - 2 * self.margin) * 0.15
        vp2_x = self.margin + (self.width - 2 * self.margin) * 0.85
        vp_y = horizon_y
        
        # Draw horizon line (heavy)
        svg += f'  <line x1="{self.margin}" y1="{horizon_y}" '
        svg += f'x2="{self.width - self.margin}" y2="{horizon_y}" '
        svg += f'stroke="#cc0000" stroke-width="1.5" opacity="0.7"/>\n'
        
        # Draw vanishing points
        svg += f'  <circle cx="{vp1_x}" cy="{vp_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        svg += f'  <circle cx="{vp2_x}" cy="{vp_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        
        # Vertical grid lines (still parallel to picture plane)
        x = self.margin
        while x <= self.width - self.margin:
            svg += f'  <line x1="{x}" y1="{self.margin}" x2="{x}" y2="{self.height - self.margin}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            x += self.grid_spacing
        
        # Create grid points for perspective lines
        points_left = []
        points_right = []
        
        # Top and bottom edges
        for i in range(11):
            t = i / 10
            x_pos = self.margin + t * (self.width - 2 * self.margin)
            points_left.append((x_pos, self.margin))
            points_left.append((x_pos, self.height - self.margin))
            points_right.append((x_pos, self.margin))
            points_right.append((x_pos, self.height - self.margin))
        
        # Left and right edges
        for i in range(11):
            t = i / 10
            y_pos = self.margin + t * (self.height - 2 * self.margin)
            if abs(y_pos - horizon_y) > 20:  # Skip near horizon
                points_left.append((self.margin, y_pos))
                points_right.append((self.width - self.margin, y_pos))
        
        # Lines to left vanishing point
        for px, py in points_left:
            if abs(px - vp1_x) > 10 or abs(py - vp_y) > 10:  # Don't draw from VP to itself
                svg += f'  <line x1="{vp1_x}" y1="{vp_y}" x2="{px}" y2="{py}" '
                svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.15"/>\n'
        
        # Lines to right vanishing point
        for px, py in points_right:
            if abs(px - vp2_x) > 10 or abs(py - vp_y) > 10:
                svg += f'  <line x1="{vp2_x}" y1="{vp_y}" x2="{px}" y2="{py}" '
                svg += f'stroke="#00cc66" stroke-width="0.5" opacity="0.15"/>\n'
        
        return svg
    
    def _generate_three_point(self, horizon_y):
        """Generate 3-point perspective grid"""
        svg = ''
        
        # Three vanishing points forming a triangle
        vp1_x = self.margin + (self.width - 2 * self.margin) * 0.2  # Left on horizon
        vp1_y = horizon_y
        vp2_x = self.margin + (self.width - 2 * self.margin) * 0.8  # Right on horizon
        vp2_y = horizon_y
        vp3_x = self.width / 2  # Center, below or above
        vp3_y = self.height - self.margin * 2  # Bottom (for looking down)
        
        # Draw horizon line (heavy)
        svg += f'  <line x1="{self.margin}" y1="{horizon_y}" '
        svg += f'x2="{self.width - self.margin}" y2="{horizon_y}" '
        svg += f'stroke="#cc0000" stroke-width="1.5" opacity="0.7"/>\n'
        
        # Draw vanishing points
        svg += f'  <circle cx="{vp1_x}" cy="{vp1_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        svg += f'  <circle cx="{vp2_x}" cy="{vp2_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        svg += f'  <circle cx="{vp3_x}" cy="{vp3_y}" r="4" fill="#0000cc" opacity="0.7"/>\n'
        
        # Create grid of points
        points = []
        for i in range(7):
            for j in range(7):
                t_x = i / 6
                t_y = j / 6
                x_pos = self.margin + t_x * (self.width - 2 * self.margin)
                y_pos = self.margin + t_y * (self.height - 2 * self.margin)
                # Skip points too close to vanishing points
                if (abs(x_pos - vp1_x) > 20 or abs(y_pos - vp1_y) > 20) and \
                   (abs(x_pos - vp2_x) > 20 or abs(y_pos - vp2_y) > 20) and \
                   (abs(x_pos - vp3_x) > 20 or abs(y_pos - vp3_y) > 20):
                    points.append((x_pos, y_pos))
        
        # Lines to first vanishing point (left)
        for px, py in points[::3]:  # Use every 3rd point to avoid clutter
            svg += f'  <line x1="{vp1_x}" y1="{vp1_y}" x2="{px}" y2="{py}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.1"/>\n'
        
        # Lines to second vanishing point (right)
        for px, py in points[1::3]:
            svg += f'  <line x1="{vp2_x}" y1="{vp2_y}" x2="{px}" y2="{py}" '
            svg += f'stroke="#00cc66" stroke-width="0.5" opacity="0.1"/>\n'
        
        # Lines to third vanishing point (vertical)
        for px, py in points[2::3]:
            svg += f'  <line x1="{vp3_x}" y1="{vp3_y}" x2="{px}" y2="{py}" '
            svg += f'stroke="#cc6600" stroke-width="0.5" opacity="0.1"/>\n'
        
        return svg


# Example usage
if __name__ == "__main__":
    print("Paper Templates Library - Examples\n")
    
    # Generate writing paper
    writing = WritingPaper(size='letter', line_spacing=24)
    print("1. WritingPaper - lined paper for writing")
    
    # Generate math grid paper
    math_paper = MathPaper(size='letter', grid_size=18, heavy_every=5)
    print("2. MathPaper - basic graph paper")
    
    # Generate science lab paper
    science = SciencePaper(size='letter')
    print("3. SciencePaper - lab notebook with column")
    
    # Generate music staff paper
    music = MusicPaper(size='letter', staves=12)
    print("4. MusicPaper - staff paper")
    
    # Generate calligraphy practice paper
    calligraphy = CalligraphyPaper(size='letter', x_height=36)
    print("5. CalligraphyPaper - practice lines with guides")
    
    # Generate engineering paper
    engineering = EngineeringPaper(size='letter', minor_grid=9, major_grid=5)
    print("6. EngineeringPaper - heavy major grid lines")
    
    # Generate isometric paper
    isometric = IsometricPaper(size='letter', grid_size=18)
    print("7. IsometricPaper - triangular grid for 3D")
    
    # Generate dot grid paper
    dotgrid = DotGridPaper(size='letter', dot_spacing=18)
    print("8. DotGridPaper - bullet journal style")
    
    # Generate polar coordinate paper
    polar = PolarPaper(size='letter', circles=10, divisions=12)
    print("9. PolarPaper - circular coordinates")
    
    # Generate logarithmic paper
    semilog = LogarithmicPaper(size='letter', x_log=False, y_log=True, cycles=3)
    print("10. LogarithmicPaper - semi-log or log-log scales")
    
    # Generate hexagonal paper
    hex_paper = HexPaper(size='letter', hex_size=18)
    print("11. HexPaper - hexagonal grid")
    
    # Generate perspective grid paper
    perspective_1pt = PerspectivePaper(size='letter', perspective_type='1-point')
    print("12. PerspectivePaper (1-point) - single vanishing point")
    
    perspective_2pt = PerspectivePaper(size='letter', perspective_type='2-point')
    print("13. PerspectivePaper (2-point) - two vanishing points")
    
    perspective_3pt = PerspectivePaper(size='letter', perspective_type='3-point', horizon_ratio=0.4)
    print("14. PerspectivePaper (3-point) - three vanishing points")
    
    # Generate calendar
    cal = CalendarPaper(size='letter', year=2026, month=1)
    print("15. CalendarPaper - monthly calendar")
    
    # Generate weekly planner
    weekly = WeeklyPlannerPaper(size='letter', start_hour=8, end_hour=18)
    print("16. WeeklyPlannerPaper - week with time slots")
    
    # Generate yearly calendar
    yearly = YearlyCalendarPaper(size='letter', year=2026, landscape=True)
    print("17. YearlyCalendarPaper - year at a glance")
    
    # Generate habit tracker
    habits = HabitTrackerPaper(size='letter', year=2026, month=1, num_habits=15)
    print("18. HabitTrackerPaper - monthly habit tracking grid")
    
    # Generate ornamental borders
    simple_border = OrnamentalBorder(size='letter', style='simple')
    print("19. OrnamentalBorder - decorative borders")
    print("    Styles: simple, double-line, art-deco, celtic, floral,")
    print("            academic, victorian, corners-only")
    
    print("\nTo save any template, use: template.save('filename.svg')")
    print("\nBorder examples:")
    print("  border = OrnamentalBorder(style='art-deco', border_width='thick')")
    print("  border.save('art_deco_border.svg')")
    print("\nCalendar examples:")
    print("  monthly = CalendarPaper(year=2026, month=6)")
    print("  monthly.save('june_2026.svg')")
    print("  weekly = WeeklyPlannerPaper(year=2026, week=15, start_hour=9, end_hour=17)")
    print("  weekly.save('week_15.svg')")