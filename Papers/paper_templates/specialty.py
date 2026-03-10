"""
Specialty paper templates (calligraphy, science, perspective)
"""

import math
from .base import PaperTemplate


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
            if abs(y_pos - horizon_y) > 20:
                points_left.append((self.margin, y_pos))
                points_right.append((self.width - self.margin, y_pos))
        
        # Lines to left vanishing point
        for px, py in points_left:
            if abs(px - vp1_x) > 10 or abs(py - vp_y) > 10:
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
        vp3_x = self.width / 2  # Center, below
        vp3_y = self.height - self.margin * 2  # Bottom (for looking down)
        
        # Draw horizon line
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