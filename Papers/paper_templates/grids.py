"""
Grid paper templates (graph, engineering, dot, hex, isometric, etc.)
"""

import math
from .base import PaperTemplate


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
            
            y += height_spacing
            row += 1
        
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
        
        h_spacing = self.grid_size * math.cos(math.radians(30))
        
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
            
            # Make major angles heavier
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