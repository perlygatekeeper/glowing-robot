"""
Base class for all paper templates
"""

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