#!/usr/bin/env python3

import math

def generate_spokes(center_x, center_y, radius1, radius2, num_spokes):
    """
    Generate points equally distributed around a circle.
    
    Args:
        center_x: X coordinate of circle center
        center_y: Y coordinate of circle center
        radius1: Radius of the inner circle
        radius2: Radius of the outer circle
        num_points: Number of points to generate
    
    Returns:
        List of (x, y) tuples
    """
    points = []
    angle_step = 2 * math.pi / num_spokes
    
    for i in range(num_spokes):
        # Start at top (angle = -pi/2) and go clockwise
        angle = -math.pi / 2 + i * angle_step
        x1 = center_x + radius1 * math.cos(angle)
        y1 = center_y + radius1 * math.sin(angle)
        x2 = center_x + radius2 * math.cos(angle)
        y2 = center_y + radius2 * math.sin(angle)
        points.append((x1, y1, x2, y2))
    
    return points

def generate_polygon_points(center_x, center_y, radius, num_points, shift=False):
    """
    Generate points equally distributed around a circle.
    Args:
        center_x: X coordinate of circle center
        center_y: Y coordinate of circle center
        radius: Radius of the circumscribed circle
        num_points: Number of points of polygon
        shift: If True, rotates polygon by half a step (default: False)
    Returns:
        List of (x, y) tuples
    """
    points = []
    angle_step = 2 * math.pi / num_points
    angle_offset = math.pi / num_points if shift else 0
    for i in range(num_points):
        angle = -math.pi / 2 + i * angle_step + angle_offset
        x = center_x + radius * math.cos(angle)
        y = center_y + radius * math.sin(angle)
        points.append((x, y))
    return points

def generate_polygram_points(center_x, center_y, radius, num_points):
    """
    Generate points equally distributed around a circle.
    Args:
        center_x: X coordinate of circle center
        center_y: Y coordinate of circle center
        radius: Radius of the circumscribed circle
        num_points: Number of points of polygon
    Returns:
        List of (x, y) tuples
    """
    points = []
    angle_step = 2 * math.pi / num_points
    angle_offset = math.pi / num_points # used for changing orientation from point up
    for i in range(num_points):
        # Start at top (angle = -pi/2) and go clockwise
        # angle = -math.pi / 2 + i * angle_step + angle_offset # <- this one will shift the point to a new angle
        angle = -math.pi / 2 + 2 * i * angle_step
        radius_boost = 6.7/math.fabs(i-2.5) if (num_points == 5 and (i!=0)) else 0
        x = center_x + ( radius + radius_boost) * math.cos(angle)
        y = center_y + ( radius + radius_boost) * math.sin(angle)
        points.append((x, y))
    return points

def line_intersection_point_angle(x1, y1, x2, y2, x3, y3, angle_rad):
    """
    Find intersection of two lines:
    - Line 1: passes through points (x1, y1) and (x2, y2)
    - Line 2: passes through point (x3, y3) at given angle
    
    Args:
        x1, y1: First point on line 1
        x2, y2: Second point on line 1
        x3, y3: Point on line 2
        angle_degrees: Angle of line 2 (0 = horizontal right, 90 = vertical up)
    
    Returns:
        (x, y) tuple of intersection point, or None if lines are parallel
    """
    # Line 1 direction vector
    dx1 = x2 - x1
    dy1 = y2 - y1
    
    # Line 2 direction from angle
    # angle_rad = math.radians(angle_degrees)
    dx2 = math.cos(angle_rad)
    dy2 = math.sin(angle_rad)
    
    # Check if lines are parallel (cross product near zero)
    cross = dx1 * dy2 - dy1 * dx2
    if math.fabs(cross) < 1e-10:
        return None  # Lines are parallel
    
    # Parametric line equations:
    # Line 1: P = (x1, y1) + t * (dx1, dy1)
    # Line 2: P = (x3, y3) + s * (dx2, dy2)
    
    # Solve for t:
    # x1 + t*dx1 = x3 + s*dx2
    # y1 + t*dy1 = y3 + s*dy2
    
    t = ((x3 - x1) * dy2 - (y3 - y1) * dx2) / cross
    
    # Calculate intersection point
    x = x1 + t * dx1
    y = y1 + t * dy1
    
    return (x, y)

def position_text_on_circles(text, center_x, center_y, inner_radius, outer_radius, angle_rad, font_family="serif", font_weight="normal", font_size=24):
    """
    Generate SVG text element positioned on a circle with rotation.
    Args:
        text: The text to display
        center_x: X coordinate of circle center
        center_y: Y coordinate of circle center
        radius: Distance from center to text
        angle_rad: Angle in radians (0 = right, increases clockwise)
        font_family: CSS font family
        font_size: Font size in pixels
    Returns:
        SVG text element as a string
    """
    
    # Calculate positions
    inner_x = center_x + inner_radius * math.cos(angle_rad)
    inner_y = center_y + inner_radius * math.sin(angle_rad)
    outer_x = center_x + outer_radius * math.cos(angle_rad)
    outer_y = center_y + outer_radius * math.sin(angle_rad)
    
    # Text rotation should be perpendicular to radius (tangent to circle)
    text_rotation = 90 + (angle_rad * 180 / math.pi)
    
    inner_text=text[0]
    outer_text=text[1]
    if (outer_text != ''):
        svg_text = f'<text x="{inner_x:6.2f}" y="{inner_y:6.2f}" ' \
                   f'font-family="{font_family}" font-size="{font_size}" font-weight="{font_weight}" ' \
                   f'text-anchor="middle" dominant-baseline="text-bottom" ' \
                   f'transform="rotate({text_rotation}, {inner_x:6.2f}, {inner_y:6.2f})" ' \
                   f'fill="#000">{inner_text}</text>' \
                   f'<text x="{outer_x:6.2f}" y="{outer_y:6.2f}" ' \
                   f'font-family="{font_family}" font-size="{font_size}" font-weight="{font_weight}" ' \
                   f'text-anchor="middle" dominant-baseline="text-bottom" ' \
                   f'transform="rotate({text_rotation}, {outer_x:6.2f}, {outer_y:6.2f})" ' \
                   f'fill="#000">{outer_text}</text>'
    else:
        x = (inner_x + outer_x)/2
        y = (inner_y + outer_y)/2
        bigger_font_size = font_size + 4
        svg_text = f'<text x="{x:6.2f}" y="{y:6.2f}" ' \
                   f'font-family="{font_family}" font-size="{bigger_font_size}" font-weight="{font_weight}" ' \
                   f'text-anchor="middle" dominant-baseline="text-bottom" ' \
                   f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" ' \
                   f'fill="#000">{inner_text}</text>'
    
    return svg_text

def position_text_on_circle(text, center_x, center_y, radius, angle_rad, font_family="serif", font_weight="normal", font_size=24):
    """
    Generate SVG text element positioned on a circle with rotation.
    Args:
        text: The text to display
        center_x: X coordinate of circle center
        center_y: Y coordinate of circle center
        radius: Distance from center to text
        angle_rad: Angle in radians (0 = right, increases clockwise)
        font_family: CSS font family
        font_size: Font size in pixels
    Returns:
        SVG text element as a string
    """
    # Calculate positions
    x = center_x + radius * math.cos(angle_rad)
    y = center_y + radius * math.sin(angle_rad)
    # Text rotation should be perpendicular to radius (tangent to circle)
    text_rotation = 90 + (angle_rad * 180 / math.pi)
    svg_text = f'<text x="{x:6.2f}" y="{y:6.2f}" ' \
        f'font-family="{font_family}" font-size="{font_size}" font-weight="{font_weight}" ' \
        f'text-anchor="middle" dominant-baseline="text-bottom" ' \
        f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" ' \
        f'fill="#000">{text}</text>'
    return svg_text

# -------------------------------------------------------------------------------------------

print(f'<svg viewBox="0 0 1000 1000" xmlns="http://www.w3.org/2000/svg">')
print(f'  <!-- Background -->')
print(f'  <rect width="1000" height="1000" fill="#f8f6f0"/>')

ring_seperation = 22
radius1 = 480                         # outer circle
radius2 = radius1 - ring_seperation   # inner circle
# Calculate vertex distance for a regular heptagon
# cos(π/7) ≈ 0.9009688679
#    vertex ≈  1.109 edge distance
#
# Calculate vertex distance for a regular {7/2} heptagram
# cos(2π/7) ≈ 0.62349
#    vertex ≈  1.603 edge distance
#
# Calculate vertex distance for a regular {7/3} heptagram
# cos(3π/7) ≈ 0.22252
#    vertex ≈  4.49 edge distance
# Calculate vertex distance for a regular {5/2} heptagram
# cos( 2π/5 ) = cos(72 ∘) ≈ 0.309016988
# 3.23607 =2φ (φ≈1.61803)

radius3  = radius2                             # outer heptagon
radius4  = radius3 - ring_seperation * 1.109   # inner heptagon
radius5  = radius4                             # outer {7/2} heptagram
radius6  = radius5 - ring_seperation * 1.603   # inner {7/2} heptagram
radius7  = radius6 - ring_seperation * 7.200   # inner2 heptagon
radius8  = radius7 - ring_seperation * 1.109   # inner3 heptagon
radius9  = radius8 - ring_seperation * 1.060   # outer pentagon
radius10 = radius9 - ring_seperation * 3.236   # inner pentagon

# Generate 2 circles, N with spokes from inner to outer circle
# print the circles 
print(f'<g id="circles">')
print(f'  <circle cx="500" cy="500" r="{radius1}" fill="none" stroke="#000" stroke-width="3"/>')
print(f'  <circle cx="500" cy="500" r="{radius2}" fill="none" stroke="#000" stroke-width="2"/>')
print(f'</g>')
points = generate_spokes(500, 500, radius1, radius2, 40)
# Print the spoke paths
print(f'<g id="spokes">')
print(f' <path d="')
for i, (x1, y1, x2, y2) in enumerate(points):
    print(f"  M {x1:.2f} {y1:.2f} L {x2:.2f} {y2:.2f}")
print(f'  Z" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the outer heptagon
print(f'<g id="outer heptagon">')
print('<path d="')
outer_points = generate_polygon_points(500, 500, radius3, 7)
L = "M"
for i, (x, y) in enumerate(outer_points):
    print(f"  {L} {x:6.2f} {y:6.2f}  ")
    L = "L"
print('Z" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inner heptagon
print(f'<g id="inner heptagon">')
print('  <path d="')
inner_points = generate_polygon_points(500, 500, radius4, 7)
L = "M"
for i, (x, y) in enumerate(inner_points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inter-heptagon spokes
print(f'<g id="inter-heptagon spokes">')
print('  <path d="')
for i in range(7):       # heptagon edge
    k = ( i + 1 ) % 7
    angle_edge = i * 2 * math.pi / 7 - (math.pi / 2) # shifted -90 degrees
    # print(f"<!-- i:{i} ({outer_points[i][0]}, {outer_points[i][1]}) k:{k} ({outer_points[k][0]},  {outer_points[k][1]}) -->")
    for j in range(7):   # sub-section of heptagon edge
        angle = angle_edge + j * 2 * math.pi / 49
        angle_degrees = angle * 180 / math.pi
        # print(f"<!-- angle_degrees:{angle_degrees} -->")
        inner = line_intersection_point_angle(inner_points[i][0], inner_points[i][1], inner_points[k][0],  inner_points[k][1], 500, 500, angle)
        outer = line_intersection_point_angle(outer_points[i][0], outer_points[i][1], outer_points[k][0],  outer_points[k][1], 500, 500, angle)
        print(f"  M {inner[0]:6.2f} {inner[1]:6.2f} L {outer[0]:6.2f} {outer[1]:6.2f} ")
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the outer heptagram
print(f'<g id="outer heptagram">')
print('  <path d="')
points = generate_polygram_points(500, 500, radius5, 7)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inner heptagram
print(f'<g id="inner heptagram">')
print('  <path d="')
points = generate_polygram_points(500, 500, radius6, 7)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inner2 heptagon
print(f'<g id="inner2 heptagon">')
print('  <path d="')
points = generate_polygon_points(500, 500, radius7, 7, True)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inner3 heptagon
print(f'<g id="inner3 heptagon">')
print('  <path d="')
points = generate_polygon_points(500, 500, radius8, 7, True)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the outer pentagram
print(f'<g id="outer pentagram">')
print('  <path d="')
points = generate_polygram_points(500, 500, radius9, 5)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inner pentagram
print(f'<g id="inner pentagram">')
print('  <path d="')
points = generate_polygram_points(500, 500, radius10, 5)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="miter" />')
print(f'</g>')

# Print the outer-ring text
text = (
        ('a', '6'),  ('h', ''),  ('a', '18'), ('e','26'),  ('30','e'),
        ('n', ''),   ('e','l'),  ('G','7'),   ('i', '13'), ('12','H'),
        ('og','y'),  ('15','t'), ('11','a'),  ('8','a'),   ('21','e'),
        ('b', '10'), ('A','11'), ('J','15'),  ('a', '8'),  ('16','*'),
        ('n', ''),   ('A', '6'), ('10','a'),  ('G','5'),   ('14','h'),
        ('17','a'),  ('s',''),   ('5','a'),   ('24','a'),  ('w','6'), 
        ('t', '4'),  ('G', '9'), ('n', '7'),  ('9','t'),   ('h', '22'),
        ('n', ''),   ('m','6'),  ('a','22'),  ('a', '20'), ('n','14')
             )
print(f'<g id="inner pentagram">')
for i in range(0,40):
    angle = ( 2 * math.pi / 40 ) * ( i + 0.5 )
    print(position_text_on_circles(text[i], 500, 500, 462, 471, angle, "'Brush Script MT', 'Lucida Handwriting', cursive", "bold", 11))
print(f'</g>')

print(f'<g id="Maltese Stars around heptagon">')
font_families = "'DejaVu Sans', 'DejaVu Serif', 'FreeSerif', 'Noto Sans Symbols', 'Noto Serif'"
angle_offset = 0.33
radius = ( 2 * radius3 +  3 * radius4 ) / 5
for i in range(0,7):
    base_line_angle = ( 2 * math.pi / 7 ) * ( i + 0.5 )
    text_rotation = base_line_angle * 180 / math.pi

    location_angle  = ( 2 * math.pi / 7 ) * ( i + 0.5 + angle_offset ) - math.pi/2
    x = 500 + radius * math.cos(location_angle)
    y = 500 + radius * math.sin(location_angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="24" font-weight="bold" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>&#x2720;</text>')

    location_angle  = ( 2 * math.pi / 7 ) * ( i + 0.5 - angle_offset ) - math.pi/2
    x = 500 + radius * math.cos(location_angle)
    y = 500 + radius * math.sin(location_angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="24" font-weight="bold" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>&#x2720;</text>')
print(f'</g>')

print(f'<g id="inner-most text">')
font_families = "'Brush Script MT', 'Lucida Handwriting', cursive"
font_size = 11
text = ( 'Z', 'M', 'S', 'N', 'C' )
for i in range(0,5):
    angle_degrees = i * 2 * math.pi / 5 - math.pi / 2
    print(position_text_on_circle(text[i], 500, 500, radius10 - 20, angle_degrees, "'Brush Script MT', 'Lucida Handwriting', cursive", "bold", font_size))

font_size = 13
print(f'<text x="500.0" y="475.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">VA</text>')
print(f'<text x="525.0" y="500.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">NA</text>')
print(f'<text x="500.0" y="525.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">EL</text>')
print(f'<text x="475.0" y="500.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">LE</text>')
font_families = "'DejaVu Sans', 'DejaVu Serif', 'FreeSerif', 'Noto Sans Symbols', 'Noto Serif'"
print(f'<text x="500.0" y="500.0" font-family="{font_families}" font-size="40" font-weight="bold" text-anchor="middle" dominant-baseline="middle" fill="#000">&#x2720;</text>')
# Z with tail: &#x2C8C;
# O with dot above: &#x116AB;
# O with dot below: &#x116B7;
# g superscript: &#x1D4D6;
# G with Plus-sign above: &#x1AC8;
# U+0325 ◌̥ COMBINING RING BELOW
print(f'</g>')

print(f'</svg>')
