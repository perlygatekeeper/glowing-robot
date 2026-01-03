"""
Printable Paper Templates Library
Generate SVG files for various types of ruled/lined paper
"""

import math
import calendar
from datetime import datetime

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
    
    def __init__(self, size='letter', width=None, height=None, 
                 line_spacing=24, margin_left=72, margin_right=72,
                 margin_top=72, margin_bottom=72):
        """
        Args:
            line_spacing: Space between lines in points (default 24 = 1/3 inch)
            margin_left/right/top/bottom: Margins in points (default 72 = 1 inch)
        """
        super().__init__(size, width, height)
        self.line_spacing = line_spacing
        self.margin_left = margin_left
        self.margin_right = margin_right
        self.margin_top = margin_top
        self.margin_bottom = margin_bottom
    
    def generate(self):
        """Generate lined paper SVG"""
        svg = self.svg_header()
        
        # Calculate usable area
        start_y = self.margin_top
        end_y = self.height - self.margin_bottom
        start_x = self.margin_left
        end_x = self.width - self.margin_right
        
        # Draw horizontal lines
        y = start_y
        while y <= end_y:
            svg += f'  <line x1="{start_x}" y1="{y}" x2="{end_x}" y2="{y}" '
            svg += f'stroke="#0066cc" stroke-width="0.5" opacity="0.3"/>\n'
            y += self.line_spacing
        
        # Draw left margin line (red)
        svg += f'  <line x1="{self.margin_left}" y1="{self.margin_top}" '
        svg += f'x2="{self.margin_left}" y2="{end_y}" '
        svg += f'stroke="#cc0000" stroke-width="1" opacity="0.5"/>\n'
        
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
    
    print("\nTo save any template, use: template.save('filename.svg')")
    print("\nExample:")
    print("  calendar = CalendarPaper(year=2026, month=3, show_week_numbers=True)")
    print("  calendar.save('march_2026.svg')")