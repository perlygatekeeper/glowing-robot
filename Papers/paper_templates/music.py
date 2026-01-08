"""
Specialty paper templates (music, calligraphy, science, perspective)
"""

import math
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
        
        # Calculate line spacing
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
        
        svg += self.svg_footer()
        return svg
    
    def _generate_one_point(self, horizon_y):
        """Generate 1-point perspective grid"""
        svg = ''
        
        vp_x = self.width / 2
        vp_y = horizon_y
        
        # Draw horizon line
        svg += f'  <line x1="{self.margin}" y1="{horizon_y}" '
        svg += f'x2="{self.width - self.margin}" y2="{horizon_y}" '
        svg += f'stroke="#cc0000" stroke-width="1.5" opacity="0.7"/>\n'
        
        # Draw vanishing point
        svg += f'  <circle cx="{vp_x}" cy="{vp_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        
        # Vertical and horizontal grid lines
        x = self.margin
        while x <= self.width - self.margin:
            svg += f'  <line x1="{x}" y1="{self.margin}" x2="{x}" y2="{self.height - self.margin}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            x += self.grid_spacing
        
        y = self.margin
        while y <= self.height - self.margin:
            if abs(y - horizon_y) > 5:
                svg += f'  <line x1="{self.margin}" y1="{y}" x2="{self.width - self.margin}" y2="{y}" '
                svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            y += self.grid_spacing
        
        # Radial lines to vanishing point
        corners = [
            (self.margin, self.margin),
            (self.width - self.margin, self.margin),
            (self.margin, self.height - self.margin),
            (self.width - self.margin, self.height - self.margin)
        ]
        
        num_divisions = 8
        for i in range(num_divisions + 1):
            t = i / num_divisions
            corners.append((self.margin + t * (self.width - 2 * self.margin), self.margin))
            corners.append((self.margin + t * (self.width - 2 * self.margin), self.height - self.margin))
            y_pos = self.margin + t * (self.height - 2 * self.margin)
            if abs(y_pos - horizon_y) > 20:
                corners.append((self.margin, y_pos))
                corners.append((self.width - self.margin, y_pos))
        
        for corner_x, corner_y in corners:
            svg += f'  <line x1="{vp_x}" y1="{vp_y}" x2="{corner_x}" y2="{corner_y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.2"/>\n'
        
        return svg
    
    def _generate_two_point(self, horizon_y):
        """Generate 2-point perspective grid"""
        # Implementation similar to 1-point but with two vanishing points
        svg = ''
        
        vp1_x = self.margin + (self.width - 2 * self.margin) * 0.15
        vp2_x = self.margin + (self.width - 2 * self.margin) * 0.85
        vp_y = horizon_y
        
        # Draw horizon line
        svg += f'  <line x1="{self.margin}" y1="{horizon_y}" '
        svg += f'x2="{self.width - self.margin}" y2="{horizon_y}" '
        svg += f'stroke="#cc0000" stroke-width="1.5" opacity="0.7"/>\n'
        
        # Draw vanishing points
        svg += f'  <circle cx="{vp1_x}" cy="{vp_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        svg += f'  <circle cx="{vp2_x}" cy="{vp_y}" r="4" fill="#cc0000" opacity="0.7"/>\n'
        
        # Vertical lines
        x = self.margin
        while x <= self.width - self.margin:
            svg += f'  <line x1="{x}" y1="{self.margin}" x2="{x}" y2="{self.height - self.margin}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            x += self.grid_spacing
        
        # Simplified radial lines (in real implementation, add more detail)
        return svg
    
    def _generate_three_point(self, horizon_y):
        """Generate 3-point perspective grid"""
        # Simplified implementation
        return self._generate_two_point(horizon_y)