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


class TrianglePaper(PaperTemplate):
    """Generate equilateral triangle grid paper"""
    
    def __init__(self, size='letter', width=None, height=None,
                 triangle_size=30, margin=36):
        """
        Args:
            triangle_size: Side length of triangles in points
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.triangle_size = triangle_size
        self.margin = margin
    
    def generate(self):
        """Generate triangle grid paper SVG"""
        svg = self.svg_header()
        
        # Triangle dimensions
        height = self.triangle_size * math.sqrt(3) / 2
        
        start_x = self.margin
        start_y = self.margin
        
        row = 0
        y = start_y
        while y < self.height - self.margin:
            x = start_x
            if row % 2 == 1:
                x += self.triangle_size / 2
            
            while x < self.width - self.margin:
                # Draw upward-pointing triangle
                x1 = x
                y1 = y + height
                x2 = x + self.triangle_size / 2
                y2 = y
                x3 = x + self.triangle_size
                y3 = y + height
                
                svg += f'  <polygon points="{x1},{y1} {x2},{y2} {x3},{y3}" '
                svg += f'fill="none" stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
                
                # Draw downward-pointing triangle (if not at edge)
                if row % 2 == 0 and x + self.triangle_size * 1.5 < self.width - self.margin:
                    x1 = x + self.triangle_size / 2
                    y1 = y
                    x2 = x + self.triangle_size
                    y2 = y + height
                    x3 = x + self.triangle_size * 1.5
                    y3 = y
                    
                    svg += f'  <polygon points="{x1},{y1} {x2},{y2} {x3},{y3}" '
                    svg += f'fill="none" stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
                
                x += self.triangle_size
            
            y += height
            row += 1
        
        svg += self.svg_footer()
        return svg


class OctagonSquarePaper(PaperTemplate):
    """Generate octagon-square tessellation (classic tile pattern)"""
    
    def __init__(self, size='letter', width=None, height=None,
                 octagon_size=30, margin=36):
        """
        Args:
            octagon_size: Distance from octagon center to edge center
            margin: Margin around edges
              ___________
             .        .  |
            .          . | a / sqrt(2)
           .            .|
           |          .  |
           |        .    |  a
           |      .______|
           |         r   |
           .            .
            .          .
             .________.
           |            |
           |            |
           |____________|
               S = 2r

           a = side length
           R = circumradius
           r = center to edge
           S = Span, edge to edge = 2r    <- what we call in-code as octagon_size

           S = a / sqrt(2) + a + a / sqrt(2)
             = ( 1 + sqrt(2) ) a              =~ 2.414 a
           r = ( 1 + sqrt(2) ) / 2            ≈~ 1.207 a
           R = ( sqrt( 4 + 2 * sqrt(2)) ) / 2 ≈~ 1.307 a
           R/r = (sqrt( 4 + 2 * sqrt(2) ) / ( 1 + sqrt(2)) =~ 1.08239922  

           a = S / ( 1 + sqrt(2))
        """
        super().__init__(size, width, height)
        self.octagon_size = octagon_size
        self.margin = margin
    
    def generate(self):
        """Generate octagon-square tessellation SVG"""
        svg = self.svg_header()
        
        # Calculate spacing
        # For regular octagon with unit circumradius, side length = 2*sin(π/8)*r
        root_2 = math.sqrt(2)
        side_length = 2 * self.octagon_size / ( 1 + root_2 )
        square_size = side_length
        
        # Spacing between octagon centers
        spacing = 2 * self.octagon_size + square_size
        
        start_x = self.margin + self.octagon_size
        start_y = self.margin + self.octagon_size
        
        y = start_y
        while y < self.height - self.margin:
            x = start_x
            while x < self.width - self.margin:
                # Draw octagon
                svg += self._draw_octagon(x, y, self.octagon_size * 1.0823922)
                
                # Draw squares between octagons (if not at edges)
                # Right square
                if x + spacing < self.width - self.margin:
                    square_x = x + self.octagon_size + side_length / 2
                    square_y = y
                    svg += self._draw_square(square_x, square_y, square_size)
                
                # Bottom square
                if y + spacing < self.height - self.margin:
                    square_x = x
                    square_y = y + self.octagon_size + side_length / 2
                    svg += self._draw_square(square_x, square_y, square_size)
                
                x += spacing
            y += spacing
        
        svg += self.svg_footer()
        return svg
    
    def _draw_octagon(self, cx, cy, radius):
        """Draw a regular octagon"""
        points = []
        for i in range(8):
            angle = math.radians(i * 45 - 22.5)  # Start at top-right
            px = cx + radius * math.cos(angle)
            py = cy + radius * math.sin(angle)
            points.append(f"{px},{py}")
        
        return f'  <polygon points="{" ".join(points)}" ' \
               f'fill="none" stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
         
    
    def _draw_square(self, cx, cy, size):
        """Draw a square centered at cx, cy"""
        half = size / 2
        # Rotate 45 degrees for diamond orientation
        angle = math.radians(45)
        points = []
        # points.append(f"{cx},{cy}")
        for i in range(4):
            a = angle + i * math.pi / 2
            px = cx + half * math.sqrt(2) * math.cos(a)
            py = cy + half * math.sqrt(2) * math.sin(a)
            points.append(f"{px},{py}")
        
        return f'  <polygon points="{" ".join(points)}" ' \
               f'fill="none" stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'


class CairoPentagonalPaper(PaperTemplate):
    """Generate Cairo pentagonal tessellation"""
    
    def __init__(self, size='letter', width=None, height=None,
                 pentagon_size=30, margin=36):
        """
        Args:
            pentagon_size: Base size of pentagons in points
            margin: Margin around edges
        """
        super().__init__(size, width, height)
        self.pentagon_size = pentagon_size
        self.margin        = margin
        self.stroke        = f"#0066cc"
        self.stroke_width  = f"0.3"
        self.fill          = f"none"
    
    def generate(self):
        """Generate Cairo pentagonal tessellation SVG"""
        svg = self.svg_header()
        
        # Cairo pentagonal tiling uses irregular pentagons
        # Simplified pattern for printable paper
        h = self.pentagon_size
        w = h 

        # Draw Cairo pentagon (simplified)
        # This creates the distinctive "dual hexagonal" pattern

        start_x = self.margin + 0.5 * w
        x = start_x
        col = 1
        while x < self.width - self.margin - w / 2:
            if ( col % 2 == 0 ):
                y = self.margin + 1.5 * w
            else: 
                y = self.margin
            while y < self.height - self.margin - h:
#               svg += f'<circle cx="{x}" cy="{y}" r="1.0" />\n'
                self.stroke = f"#dd0000"
                svg += self._draw_cairo_pentagon(x, y, h, 'up')
                y += 3 * h
            col = col + 1
            x += 1.5 * w

        start_x = self.margin + 0.5 * w
        x = start_x
        col = 1
        while x < self.width - self.margin - w / 2:
            if ( col % 2 == 0 ):
                y = self.margin + 3.5 * w
            else: 
                y = self.margin + 2.0 * h
            while y < self.height - self.margin - h:
#               svg += f'<circle cx="{x}" cy="{y}" r="1.0" />\n'
                self.stroke = f"#00dd00"
                svg += self._draw_cairo_pentagon(x, y, h, 'down')
                y += 3 * w
            col = col + 1
            x += 1.5 * h

        start_y = self.margin + h
        y = start_y
        row = 1
        while y < self.height - self.margin - h / 2:
            if ( row % 2 == 0 ):
                x = self.margin + 2.5 * w
            else: 
                x = self.margin + 1.0 * w
            while x < self.width - self.margin - w:
#               svg += f'<circle cx="{x}" cy="{y}" r="1.0" />\n'
                self.stroke = f"#0000dd"
                svg += self._draw_cairo_pentagon(x, y, h, 'left')
                x += 3 * w
            row = row + 1
            y += 1.5 * h

        start_y = self.margin + h
        y = start_y
        row = 1
        while y < self.height - self.margin - h / 2:
            if ( row % 2 == 0 ):
                x = start_x + 1.0 * w
            else: 
                x = start_x + 2.5 * w
            while x < self.width - self.margin - w:
#               svg += f'<circle cx="{x}" cy="{y}" r="1.0" />\n'
                self.stroke = f"#dd00dd"
                svg += self._draw_cairo_pentagon(x, y, h, 'right')
                x += 3 * w
            row = row + 1
            y += 1.5 * h

        svg += self.svg_footer()
        return svg

    def _draw_cairo_pentagon(self, x, y, height, direction):
        """
        Draw a Cairo tiling pentagon with collinear edges.

        (x, y)        : apex vertex of the tile cell, directly opposite of base, the sqrt(3) - 1 length side
        width, height : dimensions of the tile cell, width = 3/2 * height
        direction     : ['up', 'down', 'left', 'right']: direction which the pentagon "points"
        Returns SVG polygon string.
        """

        w1 = 3 / 4 * height   # half width at widest point
        w2 = 1 / 2 * height   # half width at base
        h1 = 1 / 4 * height   # height from top to widest point line
        h2 = height           # height from top to base

        if (direction == 'down'):
            # Standard orientation, pointing up, with sqrt(3) - 1 length side as base at bottom
            points = [
                (x, y),            # apex vertex
                (x + w1, y - h1),  # mid-right 
                (x + w2, y - h2),  # base-right
                (x - w2, y - h2),  # base-left (collinear)
                (x - w1, y - h1),  # mid-left  (collinear)
            ]          
        elif (direction == 'up'):
            # Mirrored verically
            points = [
                (x, y),            # apex vertex
                (x - w1, y + h1),  # mid-left 
                (x - w2, y + h2),  # base-left
                (x + w2, y + h2),  # base-right (collinear)
                (x + w1, y + h1),  # mid-right  (collinear)
            ]
        elif (direction == 'left'):
            # Mirrored verically
            points = [
                (x, y),            # apex vertex
                (x + h1, y + w1),  # mid-left 
                (x + h2, y + w2),  # base-left
                (x + h2, y - w2),  # base-right (collinear)
                (x + h1, y - w1),  # mid-right  (collinear)
            ]
        elif (direction == 'right'):
            # Mirrored verically
            points = [
                (x, y),            # apex vertex
                (x - h1, y - w1),  # mid-left 
                (x - h2, y - w2),  # base-left
                (x - h2, y + w2),  # base-right (collinear)
                (x - h1, y + w1),  # mid-right  (collinear)
            ]

        pts = " ".join(f"{px},{py}" for px, py in points)

        return (
            f'<polygon points="{pts}" '
            f'fill="{self.fill}" stroke-width="{self.stroke_width}"  stroke="{self.stroke}" />\n'
        )


class CubePaper(PaperTemplate):
    """Generate tumbling blocks/cube optical illusion pattern"""
    
    def __init__(self, size='letter', width=None, height=None,
                 cube_size=30, margin=36, show_shading=True):
        """
        Args:
            cube_size: Size of cube edges in points
            margin: Margin around edges
            show_shading: If True, shade faces to enhance 3D effect
        """
        super().__init__(size, width, height)
        self.cube_size = cube_size
        self.margin = margin
        self.show_shading = show_shading
        self.colors = {}
        self.colors["top"]   = f"#ffffff"
        self.colors["left"]  = f"#dddddd"
        self.colors["right"] = f"#bbbbbb"
    
    def generate(self):
        """Generate cube illusion paper SVG"""
        svg = self.svg_header()
        
        # Isometric cube dimensions
        # Width of cube in 2D
        cube_width = self.cube_size * math.sqrt(3)
        cube_height = self.cube_size * 1.5
        
        start_x = self.margin + cube_width / 2
        start_y = self.margin
        
        row = 0
        y = start_y
        while y < self.height - self.margin - cube_height:
            x = start_x
            # Offset every other row
            if row % 2 == 1:
                x += cube_width / 2
            
            while x < self.width - self.margin:
                # Draw isometric cube
                svg += self._draw_isometric_cube(x, y)
                
                x += cube_width
            
            y += cube_height
            row += 1
        
        svg += self.svg_footer()
        return svg
    
    def _draw_isometric_cube(self, x, y):
        """
        Draw a single isometric cube as SVG polygons.
    
        (x, y) is the top point of the cube.
        Returns an SVG string.
        """
    
        s = self.cube_size
        dx = s * math.sqrt(3) / 2
        dy = s / 2
    
        # Top face
        top = [
            (x, y),
            (x + dx, y + dy),
            (x, y + 2 * dy),
            (x - dx, y + dy),
        ]
    
        # Left face
        left = [
            (x - dx, y + dy),
            (x, y + 2 * dy),
            (x, y + 2 * dy + s),
            (x - dx, y + dy + s),
        ]
    
        # Right face
        right = [
            (x + dx, y + dy),
            (x, y + 2 * dy),
            (x, y + 2 * dy + s),
            (x + dx, y + dy + s),
        ]
    
        def poly(points, fill):
            pts = " ".join(f"{px},{py}" for px, py in points)
            return f'<polygon points="{pts}" fill="{fill}" stroke="black" />'
    
        svg = []
        if (self.show_shading):
            svg.append(poly(top,   self.colors["top"]))
            svg.append(poly(left,  self.colors["left"]))
            svg.append(poly(right, self.colors["right"]))
        else:
            svg.append(poly(top,   "#ffffff"))
            svg.append(poly(left,  "#ffffff"))
            svg.append(poly(right, "#ffffff"))
    
        return "\n".join(svg)


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
