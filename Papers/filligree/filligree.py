import math
import svgwrite

def create_corner_flourish(dwg, x, y, size, rotation=0):
    """Create an ornate corner flourish"""
    g = dwg.g(transform=f'translate({x},{y}) rotate({rotation})')
    
    # Main spiral curve
    path_data = f'M 0,0 Q {size*0.3},{size*0.1} {size*0.5},{size*0.3} T {size*0.8},{size*0.6}'
    g.add(dwg.path(d=path_data, stroke='#8B7355', fill='none', stroke_width=2))
    
    # Inner decorative curves
    path_data2 = f'M {size*0.1},{size*0.05} Q {size*0.25},{size*0.15} {size*0.4},{size*0.35}'
    g.add(dwg.path(d=path_data2, stroke='#8B7355', fill='none', stroke_width=1.5))
    
    # Leaf-like elements
    for i in range(3):
        offset = i * size * 0.25
        leaf = f'M {offset},{offset*0.3} q {size*0.08},{size*0.12} 0,{size*0.15} q {-size*0.08},{-size*0.03} 0,{-size*0.15}'
        g.add(dwg.path(d=leaf, stroke='#8B7355', fill='#D4C4B0', fill_opacity=0.3, stroke_width=1))
    
    # Small dots/rosettes
    for i in range(4):
        angle = i * math.pi / 6
        rx = size * 0.6 * math.cos(angle)
        ry = size * 0.6 * math.sin(angle)
        g.add(dwg.circle(center=(rx, ry), r=2, fill='#8B7355'))
    
    return g

def create_border_segment(dwg, x1, y1, x2, y2, num_flourishes=5):
    """Create decorative elements along a border edge"""
    g = dwg.g()
    
    # Calculate direction and length
    dx = x2 - x1
    dy = y2 - y1
    length = math.sqrt(dx**2 + dy**2)
    angle = math.atan2(dy, dx) * 180 / math.pi
    
    # Main border line with double stroke
    g.add(dwg.line(start=(x1, y1), end=(x2, y2), stroke='#8B7355', stroke_width=3))
    
    # Inner parallel line
    offset = 8
    if dy == 0:  # Horizontal line
        y_offset = offset if y1 > 300 else -offset
        g.add(dwg.line(start=(x1, y1 + y_offset), end=(x2, y2 + y_offset), 
                      stroke='#8B7355', stroke_width=1))
    else:  # Vertical line
        x_offset = offset if x1 > 400 else -offset
        g.add(dwg.line(start=(x1 + x_offset, y1), end=(x2 + x_offset, y2), 
                      stroke='#8B7355', stroke_width=1))
    
    # Add small decorative elements along the line
    for i in range(num_flourishes):
        t = (i + 1) / (num_flourishes + 1)
        x = x1 + t * dx
        y = y1 + t * dy
        
        # Small ornamental circles
        g.add(dwg.circle(center=(x, y), r=3, fill='#8B7355', opacity=0.6))
        
        # Tiny flourishes perpendicular to the line
        perp_angle = angle + 90
        perp_x = x + 6 * math.cos(perp_angle * math.pi / 180)
        perp_y = y + 6 * math.sin(perp_angle * math.pi / 180)
        g.add(dwg.line(start=(x, y), end=(perp_x, perp_y), 
                      stroke='#8B7355', stroke_width=0.5, opacity=0.4))
    
    return g

def create_filigree_border(filename='filigree_border.svg', width=800, height=600):
    """Create a complete ornate filigree border"""
    dwg = svgwrite.Drawing(filename, size=(width, height))
    
    # Background
    dwg.add(dwg.rect(insert=(0, 0), size=(width, height), fill='#FFF9F0'))
    
    # Border margins
    margin = 40
    inner_margin = 60
    
    # Outer frame
    dwg.add(dwg.rect(insert=(margin, margin), 
                     size=(width - 2*margin, height - 2*margin),
                     fill='none', stroke='#8B7355', stroke_width=2))
    
    # Corner flourishes
    corner_size = 80
    dwg.add(create_corner_flourish(dwg, margin + 10, margin + 10, corner_size, 0))
    dwg.add(create_corner_flourish(dwg, width - margin - 10, margin + 10, corner_size, 90))
    dwg.add(create_corner_flourish(dwg, width - margin - 10, height - margin - 10, corner_size, 180))
    dwg.add(create_corner_flourish(dwg, margin + 10, height - margin - 10, corner_size, 270))
    
    # Decorative border segments
    # Top
    dwg.add(create_border_segment(dwg, margin + corner_size, margin + 5, 
                                  width - margin - corner_size, margin + 5, 6))
    # Bottom
    dwg.add(create_border_segment(dwg, margin + corner_size, height - margin - 5, 
                                  width - margin - corner_size, height - margin - 5, 6))
    # Left
    dwg.add(create_border_segment(dwg, margin + 5, margin + corner_size, 
                                  margin + 5, height - margin - corner_size, 4))
    # Right
    dwg.add(create_border_segment(dwg, width - margin - 5, margin + corner_size, 
                                  width - margin - 5, height - margin - corner_size, 4))
    
    # Central decorative elements (top and bottom)
    center_x = width / 2
    
    # Top center medallion
    dwg.add(dwg.circle(center=(center_x, margin + 5), r=15, 
                      fill='none', stroke='#8B7355', stroke_width=2))
    dwg.add(dwg.circle(center=(center_x, margin + 5), r=10, 
                      fill='#D4C4B0', fill_opacity=0.3))
    
    # Bottom center medallion
    dwg.add(dwg.circle(center=(center_x, height - margin - 5), r=15, 
                      fill='none', stroke='#8B7355', stroke_width=2))
    dwg.add(dwg.circle(center=(center_x, height - margin - 5), r=10, 
                      fill='#D4C4B0', fill_opacity=0.3))
    
    # Add some rosettes along borders
    for i in range(8):
        angle = i * math.pi / 4
        offset = 25
        x = center_x + (width/2 - 100) * math.cos(angle)
        y = height/2 + (height/2 - 100) * math.sin(angle)
        dwg.add(dwg.circle(center=(x, y), r=4, fill='#8B7355', opacity=0.5))
    
    # Sample text area indicator
    text_box = dwg.g()
    text_box.add(dwg.rect(insert=(inner_margin + 20, inner_margin + 20),
                         size=(width - 2*inner_margin - 40, height - 2*inner_margin - 40),
                         fill='none', stroke='#D4AF37', stroke_width=1, 
                         stroke_dasharray='5,5', opacity=0.3))
    text_box.add(dwg.text('Certificate Text Area', 
                         insert=(width/2, height/2),
                         text_anchor='middle',
                         font_size='24px',
                         fill='#CCC',
                         font_family='serif',
                         font_style='italic'))
    dwg.add(text_box)
    
    dwg.save()
    print(f"Filigree border saved to {filename}")
    return dwg

# Generate the filigree border
if __name__ == '__main__':
    create_filigree_border()
    
    # You can also create custom sizes:
    # create_filigree_border('certificate.svg', width=1000, height=750)