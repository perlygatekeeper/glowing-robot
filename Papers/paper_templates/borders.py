"""
Ornamental border templates
"""

from .base import PaperTemplate


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
        'folded-corner',    # Page with folded corner effect
        'looped-corner',    # Page with looped corner effect
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
        elif self.style == 'folded-corner':
            svg += self._draw_folded_corner()
        elif self.style == 'looped-corner':
            svg += self._draw_looped_corner()
        
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
        
        # All four corners
        svg += self._draw_deco_corner(x, y, corner_size, 'top-left')
        svg += self._draw_deco_corner(x + w, y, corner_size, 'top-right')
        svg += self._draw_deco_corner(x, y + h, corner_size, 'bottom-left')
        svg += self._draw_deco_corner(x + w, y + h, corner_size, 'bottom-right')
        
        return svg
    
    def _draw_deco_corner(self, x, y, size, position):
        """Draw Art Deco style corner element"""
        svg = ''
        
        if position == 'top-left':
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
        
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        corner_size = 40
        svg += self._draw_celtic_corner(x, y, corner_size, 'top-left')
        svg += self._draw_celtic_corner(x + w, y, corner_size, 'top-right')
        svg += self._draw_celtic_corner(x, y + h, corner_size, 'bottom-left')
        svg += self._draw_celtic_corner(x + w, y + h, corner_size, 'bottom-right')
        
        return svg
    
    def _draw_celtic_corner(self, x, y, size, position):
        """Draw simplified Celtic knot corner"""
        svg = ''
        
        if position == 'top-left':
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
        
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        size = 35
        svg += self._draw_floral_corner(x, y, size, 'top-left')
        svg += self._draw_floral_corner(x + w, y, size, 'top-right')
        svg += self._draw_floral_corner(x, y + h, size, 'bottom-left')
        svg += self._draw_floral_corner(x + w, y + h, size, 'bottom-right')
        
        return svg
    
    def _draw_floral_corner(self, x, y, size, position):
        """Draw floral corner decoration"""
        svg = ''
        
        if position == 'top-left':
            svg += f'  <path d="M {x} {y + size} Q {x + 5} {y + 15} {x + 15} {y + 5} Q {x + 25} {y} {x + size} {y}" '
            svg += f'fill="none" stroke="#000000" stroke-width="1.5"/>\n'
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
        
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness * 0.5}"/>\n'
        
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
    
    def _draw_folded_corner(self):
        """Page with folded corner effect (dog-ear)"""
        svg = ''
        
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        fold_size = 60
        
        # Draw page outline with folded corner cut out
        svg += f'  <path d="M {x} {y} '
        svg += f'L {x + w - fold_size} {y} '
        svg += f'L {x + w} {y + fold_size} '
        svg += f'L {x + w} {y + h} '
        svg += f'L {x} {y + h} '
        svg += f'Z" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        # Draw the folded corner triangle
        svg += f'  <path d="M {x + w - fold_size} {y} '
        svg += f'L {x + w} {y + fold_size} '
        svg += f'L {x + w - fold_size} {y + fold_size} '
        svg += f'Z" '
        svg += f'fill="#e0e0e0" stroke="#000000" stroke-width="{self.thickness * 0.5}"/>\n'
        
        # Add shadow/shading line
        svg += f'  <line x1="{x + w - fold_size}" y1="{y + fold_size}" '
        svg += f'x2="{x + w}" y2="{y + fold_size}" '
        svg += f'stroke="#999999" stroke-width="{self.thickness * 0.5}" '
        svg += f'stroke-dasharray="2,2" opacity="0.5"/>\n'
        
        # Crease lines
        crease_offset = fold_size * 0.3
        svg += f'  <line x1="{x + w - fold_size + crease_offset}" y1="{y}" '
        svg += f'x2="{x + w - crease_offset}" y2="{y + fold_size - crease_offset}" '
        svg += f'stroke="#cccccc" stroke-width="0.5" opacity="0.5"/>\n'
        
        return svg
    
    def _draw_looped_corner(self):
        """Page with looped corner effect"""
        svg = ''
        
        x = self.margin
        y = self.margin
        w = self.width - 2 * self.margin
        h = self.height - 2 * self.margin
        
        step = 10
        
        # Draw page outline
        svg += f'  <rect x="{x}" y="{y}" width="{w}" height="{h}" '
        svg += f'fill="none" stroke="#000000" stroke-width="{1.5*self.thickness}"/>\n'
        
        # Start at top-left, go clockwise, complete loop at each corner
        svg += f'  <path d="'
        svg += f'M {x + 0 * step} {y + 1 * step} '
        svg += f'L {x + 2 * step} {y + 1 * step} '
        svg += f'L {x + 2 * step} {y + 2 * step} '
        svg += f'L {x + 1 * step} {y + 2 * step} '
        svg += f'L {x + 1 * step} {y + 0 * step} '
        # Top-right
        svg += f'L {x + w - 1 * step} {y + 0 * step} '
        svg += f'L {x + w - 1 * step} {y + 2 * step} '
        svg += f'L {x + w - 2 * step} {y + 2 * step} '
        svg += f'L {x + w - 2 * step} {y + 1 * step} '
        svg += f'L {x + w - 0 * step} {y + 1 * step} '
        # Bottom-right
        svg += f'L {x + w - 0 * step} {y + h - 1 * step} '
        svg += f'L {x + w - 2 * step} {y + h - 1 * step} '
        svg += f'L {x + w - 2 * step} {y + h - 2 * step} '
        svg += f'L {x + w - 1 * step} {y + h - 2 * step} '
        svg += f'L {x + w - 1 * step} {y + h - 0 * step} '
        # Bottom-left
        svg += f'L {x + 1 * step} {y + h - 0 * step} '
        svg += f'L {x + 1 * step} {y + h - 2 * step} '
        svg += f'L {x + 2 * step} {y + h - 2 * step} '
        svg += f'L {x + 2 * step} {y + h - 1 * step} '
        svg += f'L {x + 0 * step} {y + h - 1 * step} '
        svg += f'L {x + 0 * step} {y + 1 * step} '
        svg += f'Z" '
        svg += f'fill="none" stroke="#000000" stroke-width="{self.thickness}"/>\n'
        
        # Inner decorative element
        svg += f'  <path d="'
        svg += f'M {x + 2 * step} {y + 4 * step} '
        svg += f'L {x + 4 * step} {y + 4 * step} '
        svg += f'L {x + 4 * step} {y + 2 * step} '
        svg += f'L {x + w - 2 * step} {y + 4 * step} '
        svg += f'L {x + w - 4 * step} {y + 4 * step} '
        svg += f'L {x + w - 4 * step} {y + 2 * step} '
        svg += f'L {x + w - 2 * step} {y + h - 4 * step} '
        svg += f'L {x + w - 4 * step} {y + h - 4 * step} '
        svg += f'L {x + w - 4 * step} {y + h - 2 * step} '
        svg += f'L {x + 2 * step} {y + h - 4 * step} '
        svg += f'L {x + 4 * step} {y + h - 4 * step} '
        svg += f'L {x + 4 * step} {y + h - 2 * step} '
        svg += f'L {x + 2 * step} {y + 4 * step} '
        svg += f'Z" '
        svg += f'fill="#e0e0e0" stroke="#000000" stroke-width="{self.thickness * 0.5}"/>\n'
        
        return svg