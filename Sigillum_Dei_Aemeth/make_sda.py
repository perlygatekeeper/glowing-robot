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

def line_intersection(p1, p2, p3, p4):
    """
    Find intersection point of two lines.
    
    Line 1: passes through points p1 and p2
    Line 2: passes through points p3 and p4
    
    Args:
        p1: (x, y) tuple for first point on line 1
        p2: (x, y) tuple for second point on line 1
        p3: (x, y) tuple for first point on line 2
        p4: (x, y) tuple for second point on line 2
    
    Returns:
        (x, y) tuple of intersection point, or None if lines are parallel
    """
    # Unpack the tuples
    x1, y1 = p1
    x2, y2 = p2
    x3, y3 = p3
    x4, y4 = p4
    
    # Calculate denominators for the parametric equations
    denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    
    # Check if lines are parallel (denominator is zero)
    if abs(denom) < 1e-10:
        return None
    
    # Calculate intersection point using parametric line equations
    t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
    
    # Calculate the intersection coordinates
    x = x1 + t * (x2 - x1)
    y = y1 + t * (y2 - y1)
    
    return (x, y)

def polar_graph_overlay(circles=20, spokes=36):
    center_x = 500
    center_y = 500
    color    = "#0066cc"
    width    = "0.5"
    opacity  = "0.3"
    print(f'<g id="polar overlay">')
    for i in range(1, circles + 1):
        radius = i * 25
        print(f'  <circle cx="{center_x}" cy="{center_y}" r="{radius}" fill="none" stroke="{color}" stroke-width="{width}" opacity="{opacity}"/>')
    for i in range(1, spokes + 1):
        angle = ( i * 360 / spokes ) - 90
        angle_rad = math.radians(angle)
        x_end = center_x + 500 * math.cos(angle_rad)
        y_end = center_y + 500 * math.sin(angle_rad)
        print(f'  <line x1="{center_x}" y1="{center_y}" x2="{x_end}" y2="{y_end}" stroke="{color}" stroke-width="{width}" opacity="{opacity}"/>')
    print(f'</g>')


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

radius3  = radius2                              # outer heptagon
radius4  = radius3  - ring_seperation * 1.109   # inner heptagon
radius5  = radius4                              # outer {7/2} heptagram
radius6  = radius5  - ring_seperation * 1.603   # inner {7/2} heptagram
radius7  = radius6  - ring_seperation * 6.700   # inner2 heptagon
radius8  = radius7  - ring_seperation * 1.109   # inner3 heptagon
radius9  = radius8  - ring_seperation * 1.060   # outer pentagon
radius10 = radius9  - ring_seperation * 3.236   # inner pentagon
radius11 = radius6  - ring_seperation * 1.5     # inner hentagram points
radius12 = radius11 - ring_seperation * 1.0     # inside outer hentagon
radius13 = radius11 - ring_seperation * 3.9     # outside outer hentagram edge
radius14 = radius13 - ring_seperation * 1.0     # outside inner hentagram edge
radius15 = radius14 - ring_seperation * 1.0     # outside outer hentagon  edge
radius16 = radius15 - ring_seperation * 1.0     # outside inner hentagon  edge

#   ----    CIRCLES W/ SPOKES

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

#   ----    OUTER HEPTAGONS W/ SPOKES

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

#   ----    CELTIC-KNOTTED HEPTAGRAMS

# First generate verticies of outer and inner heptagrams
outer_points = generate_polygram_points(500, 500, radius5, 7)
inner_points = generate_polygram_points(500, 500, radius6, 7)
outer_skips = list()
inner_skips = list()

# Find stop and stop points along the clockward edge of each heptagram
for crossing_first_index in range(0,7):
    crossing_second_index = ( crossing_first_index + 1 ) % 7
    crossed_first_index   = ( crossing_first_index + 4 ) % 7
    crossed_second_index  = ( crossing_first_index + 5 ) % 7
    outer_skips.append( ( line_intersection(
                              outer_points[crossing_first_index], outer_points[crossing_second_index],
                              inner_points[crossed_first_index],  inner_points[crossed_second_index]
                           ),
                          line_intersection(
                              outer_points[crossing_first_index], outer_points[crossing_second_index],
                              outer_points[crossed_first_index],  outer_points[crossed_second_index]
                           )
                         )
    )
    inner_skips.append( ( line_intersection(
                              inner_points[crossing_first_index], inner_points[crossing_second_index],
                              inner_points[crossed_first_index],  inner_points[crossed_second_index]
                           ),
                          line_intersection(
                              inner_points[crossing_first_index], inner_points[crossing_second_index],
                              outer_points[crossed_first_index],  outer_points[crossed_second_index]
                           )
                         )
    )


# Print the outer heptagram
print(f'<g id="outer heptagram">')
print('  <path d="')
L = "M"
for i, (x, y) in enumerate(outer_points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    # next Line-to the stop, then Move-to the next start point ready for the next vertex
    ( (stop_x, stop_y), (start_x, start_y) ) = outer_skips[i];
    print(f"    L {stop_x:6.2f} {stop_y:6.2f} ")
    print(f"    M {start_x:6.2f} {start_y:6.2f} ")
    L = "L"
    if (i == 6):
        (x, y) = outer_points[0]
        print(f"    L {x:6.2f} {y:6.2f} ")
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inner heptagram
print(f'<g id="inner heptagram">')
print('  <path d="')
L = "M"
for i, (x, y) in enumerate(inner_points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    # next Line-to the stop, then Move-to the next start point ready for the next vertex
    ( (stop_x, stop_y), (start_x, start_y) ) = inner_skips[i];
    print(f"    L {stop_x:6.2f} {stop_y:6.2f} ")
    print(f"    M {start_x:6.2f} {start_y:6.2f} ")
    L = "L"
    if (i == 6):
        (x, y) = inner_points[0]
        print(f"    L {x:6.2f} {y:6.2f} ")
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

#   ----    INNER HEPTAGONS

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

#   ----    PENTAGONS

# First generate verticies of outer and inner heptagrams
outer_points = generate_polygram_points(500, 500, radius9, 5)
inner_points = generate_polygram_points(500, 500, radius10, 5)
outer_skips = list()
inner_skips = list()

# Find stop and stop points along the clockward edge of each pentagram
for crossing_first_index in range(0,5):
    crossing_second_index = ( crossing_first_index + 1 ) % 5
    crossed_first_index   = ( crossing_first_index + 3 ) % 5
    crossed_second_index  = ( crossing_first_index + 4 ) % 5
    outer_skips.append( ( line_intersection(
                              outer_points[crossing_first_index], outer_points[crossing_second_index],
                              inner_points[crossed_first_index],  inner_points[crossed_second_index]
                           ),
                          line_intersection(
                              outer_points[crossing_first_index], outer_points[crossing_second_index],
                              outer_points[crossed_first_index],  outer_points[crossed_second_index]
                           )
                         )
    )
    inner_skips.append( ( line_intersection(
                              inner_points[crossing_first_index], inner_points[crossing_second_index],
                              inner_points[crossed_first_index],  inner_points[crossed_second_index]
                           ),
                          line_intersection(
                              inner_points[crossing_first_index], inner_points[crossing_second_index],
                              outer_points[crossed_first_index],  outer_points[crossed_second_index]
                           )
                         )
    )

# Print the outer pentagram
print(f'<g id="outer pentagram">')
print('  <path d="')
L = "M"
for i, (x, y) in enumerate(outer_points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    # next Line-to the stop, then Move-to the next start point ready for the next vertex
    ( (stop_x, stop_y), (start_x, start_y) ) = outer_skips[i];
    print(f"    L {stop_x:6.2f} {stop_y:6.2f} ")
    print(f"    M {start_x:6.2f} {start_y:6.2f} ")
    L = "L"
    if (i == 4):
        (x, y) = outer_points[0]
        print(f"    L {x:6.2f} {y:6.2f} ")
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

# Print the inner pentagram
print(f'<g id="inner pentagram">')
print('  <path d="')
L = "M"
for i, (x, y) in enumerate(inner_points):
    print(f"    {L} {x:6.2f} {y:6.2f} ")
    # next Line-to the stop, then Move-to the next start point ready for the next vertex
    ( (stop_x, stop_y), (start_x, start_y) ) = inner_skips[i];
    print(f"    L {stop_x:6.2f} {stop_y:6.2f} ")
    print(f"    M {start_x:6.2f} {start_y:6.2f} ")
    L = "L"
    if (i == 4):
        (x, y) = inner_points[0]
        print(f"    L {x:6.2f} {y:6.2f} ")
print("Z")
print('" fill="none" stroke="#000" stroke-width="3" stroke-linejoin="bevel" />')
print(f'</g>')

#   ----   CIRCLE PATH TEXTS

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

text2 = ( ( 'El',      'T',       'S',       'E'       ),
          ( 'Me',      'Heeaa',   'Ab',      'An'      ),
          ( 'Ese',     'Th',      'Ath',     'Ave'     ),
          ( 'Tana',    'Beigia',  'Tzad',    'Liba'    ),
          ( 'Akele',   'Tlr',     'Ekiei',   'Rocle'   ),
          ( 'Ardobn',  'Stimcul', 'Madini',  'Hagonel' ),
          ( 'Stimcul', 'Dmal',    'Esemeli', 'Tlemese' ),
        )
text3 = ( 'ZllRHia', 'aZCaacb', 'paupnhr', 'hdmhlai', 'kkaaeee', 'iieelll', 'eellMG.' )
# text4 = ( 'SAAI21&#x116B7; ME8&#x116B7;', 'BTZKASE30&#x116B7;', 'HEIDENE', 'DEIMO30&#x116B7;A', 'I26&#x116AB;MEGQBE', 'ILAOT21&#x116B7;VN', 'IHRLAA21&#x116B7;' )
# text4 = ( "SAAI EMEa\u0323", 'BTZKASE ', 'HEIDENE', 'DEIMO A', 'I MEGQBE', 'ILAOT VN', 'IHRLAA ' )
text4 = ( "SAAI EME8", 'BTZKASE ', 'HEIDENE', 'DEIMO A', 'I MEGQBE', 'ILAOT VN', 'IHRLAA ' )

print(f'<g id="Maltese Stars around heptagon">')
angle_offset = 0.33
radius = ( 2 * radius3 +  3 * radius4 ) / 5
radius20 = radius   - ring_seperation * 2.0
radius21 = radius20 - ring_seperation * 1.0
for i in range(0,7):
    font_families = "'DejaVu Sans', 'DejaVu Serif', 'FreeSerif', 'Noto Sans Symbols', 'Noto Serif'"
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

    font_families = "'Brush Script MT', 'Lucida Handwriting', cursive"
    angle  = ( 2 * math.pi / 7 ) * ( i + 0.5 ) - math.pi/2
    x = 500 + radius20 * math.cos(angle)
    y = 500 + radius20 * math.sin(angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" letter-spacing="46"'
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="22" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>{text3[i]}</text>')

    font_families = "'Brush Script MT', 'Lucida Handwriting', cursive"
    angle  = ( 2 * math.pi / 7 ) * ( i + 0.5 ) - math.pi/2
    x = 500 + radius21 * math.cos(angle)
    y = 500 + radius21 * math.sin(angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" letter-spacing="8"'
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="22" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>{text4[i]}</text>')

    if ( i == 6 ):
        radius = radius4 - ring_seperation / 10
        location_angle  = ( 2 * math.pi / 7 ) * ( i + 0.5 + 0.436 ) - math.pi/2
        x = 500 + radius * math.cos(location_angle)
        y = 500 + radius * math.sin(location_angle)
        transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
        print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="26" font-weight="bold" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>&#x2720;</text>')

    text_rotation = i * 360 / 7
    font_families = "'Brush Script MT', 'Lucida Handwriting', cursive"

    angle  = ( 2 * math.pi / 7 ) * i  - math.pi/2
    x = 500 + radius11 * math.cos(angle)
    y = 500 + radius11 * math.sin(angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="40" font-weight="bold" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>&#x2720;</text >')

    angle  = ( 2 * math.pi / 7 ) * i - math.pi/2
    x = 500 + radius13 * math.cos(angle)
    y = 500 + radius13 * math.sin(angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="22" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>{text2[i][0]}</text>')

    x = 500 + radius14 * math.cos(angle)
    y = 500 + radius14 * math.sin(angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="22" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>{text2[i][1]}</text>')

    x = 500 + radius15 * math.cos(angle)
    y = 500 + radius15 * math.sin(angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="22" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>{text2[i][2]}</text>')

    x = 500 + radius16 * math.cos(angle)
    y = 500 + radius16 * math.sin(angle)
    transform = f'transform="rotate({text_rotation}, {x:6.2f}, {y:6.2f})" '
    print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="22" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" {transform}>{text2[i][3]}</text>')

print(f'</g>')

print(f'<g id="inner-most text">')
font_families = "'Brush Script MT', 'Lucida Handwriting', cursive"
font_size = 11
text = ( 'Z', 'M', 'S', 'N', 'C' )
for i in range(0,5):
    angle = i * 2 * math.pi / 5 - math.pi / 2
    print(position_text_on_circle(text[i], 500, 500, radius10 - ring_seperation, angle, "'Brush Script MT', 'Lucida Handwriting', cursive", "bold", font_size))
print(f'</g>')

text5 = ( 'ADIMIEL', 'EMELIEL', 'OGAHEL', 'ORABIEL' , 'EDEKIEL' )
font_families = "'Brush Script MT', 'Lucida Handwriting', cursive"
angle_offset = 1
print(f'<g id="text on circular paths">')
print(f"  <defs>")
print(f'    <circle id="textCircle" cx="500" cy="500" r="{radius10-ring_seperation}" fill="none"/>')
print(f"  </defs>")
for i in range(0,5):
    startOffset = angle_offset + i * 20
    print(f'  <text font-size="11" fill="black" font-family="{font_families}" letter-spacing="2">')
    print(f'    <textPath href="#textCircle" startOffset="{startOffset}%">{text5[i]}</textPath>')
    print(f'  </text>')
print(f'</g>')

# NEAR PENTAGRAM POINT CHARACTERS

text = ( "Z", "A", "B", "A", "T", "H", "I" )
font_size = 20
radius = 184
print(f'<g id="Near pentagram characers">')

angle = 26.3 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 0 * 360 / 7
transform = f'rotate({text_rotation:7.3f}, {x:6.2f}, {y:6.2f})'
print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" transform="{transform}">{text[0]}</text>')

angle = 31.5 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 1 * 360 / 7
transform = f'rotate({text_rotation:7.3f}, {x:6.2f}, {y:6.2f})'
print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" transform="{transform}">{text[1]}</text>')

angle =  0.5 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 2 * 360 / 7
transform = f'rotate({text_rotation:7.3f}, {x:6.2f}, {y:6.2f})'
print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" transform="{transform}">{text[2]}</text>')

angle =  6.5 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 3 * 360 / 7
transform = f'rotate({text_rotation:7.3f}, {x:6.2f}, {y:6.2f})'
print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" transform="{transform}">{text[3]}</text>')

angle = 11.5 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 4 * 360 / 7
transform = f'rotate({text_rotation:7.3f}, {x:6.2f}, {y:6.2f})'
print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" transform="{transform}">{text[4]}</text>')

angle = 17.5 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 5 * 360 / 7
transform = f'rotate({text_rotation:7.3f}, {x:6.2f}, {y:6.2f})'
print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" transform="{transform}">{text[5]}</text>')

angle = 22.0 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 6 * 360 / 7
transform = f'rotate({text_rotation:7.3f}, {x:6.2f}, {y:6.2f})'
print(f'<text x="{x}" y="{y}" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000" transform="{transform}">{text[6]}</text>')

print(f'</g>')
 
font_size = 24
font_families="serif"
radius = 425

color = "#000"
print(f'<g id="Special Complex Symbols">')
angle = 24.5 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = -0.5 * 360 / 7
transform = f'translate({x:6.2f}, {y:6.2f}) rotate({angle:7.3f})'
text_transform = f'rotate({text_rotation:7.3f})'
print(f'  <g transform="{transform}">')
print(f'    <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="text-bottom" fill="{color}" transform="{text_transform}">G&#x1AC8;')
print(f'    <tspan font-size="{font_size-12}" dx="4" dy="0">5</tspan>')
print(f'    </text>')
print(f'  </g>')

font_size = 14
angle = 29.5 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 0.5 * 360 / 7
transform = f'translate({x:6.2f}, {y:6.2f}) rotate({angle:7.3f})'
text_transform = f'rotate({text_rotation:7.3f})'
print(f'  <g transform="{transform}">')
print(f'    <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="text-bottom" fill="{color}" transform="{text_transform}" letter-spacing="-4">')
print(f'    OG')
print(f'    <tspan font-size="12" dx="-8" dy="-11.8">+</tspan>')
print(f'    </text>')
print(f'   <ellipse cx="2.5" cy="-4.5" rx="11" ry="9" transform="rotate({text_rotation:7.3f} 0.0 0.0)" fill="none" stroke="{color}" stroke-width="0.7"/>')
print(f'  </g>')

font_size = 24
angle = 34.6 / 36  * 2 * math.pi
x = 500 + radius * math.cos(angle)
y = 500 + radius * math.sin(angle)
text_rotation = 1.5 * 360 / 7
#transform = f'translate({x:6.2f}, {y:6.2f}) rotate({angle:7.3f})'
transform = f'translate({x:6.2f}, {y:6.2f})'
text_transform = f'rotate({text_rotation:7.3f}) scale(1.8,1.0)'
print(f'  <g transform="{transform}">')
print(f'    <text font-family="{font_families}" font-size="{font_size}" font-weight="300" text-anchor="middle" dominant-baseline="text-bottom" fill="{color}" transform="{text_transform}">')
print(f'    H')
print(f'      <tspan font-size="{font_size-12}" dx="-6" dy="0" transform="scale(1/1.8,1.0)">14</tspan>')
print(f'    </text>')
text_transform = f'rotate({text_rotation:7.3f})'
print(f'    <text font-family="{font_families}" font-size="{font_size}" font-weight="300" text-anchor="middle" dominant-baseline="middle" fill="{color}" transform="{text_transform}">')
print(f'      <tspan font-size="20" dx="-24" dy="-14">\u271D</tspan>')
print(f'    </text>')
print(f'    <circle cx="3.8" cy="-13.0" r="2.0" fill="none" stroke="#000" stroke-width="1.0" opacity="1.0"/>')
print(f'  </g>')

color = "#0c0"

print(f'</g>')

font_size = 13
print(f'<g id="inner-most text">')
print(f'<text x="500.0" y="475.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">VA</text>')
print(f'<text x="525.0" y="500.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">NA</text>')
print(f'<text x="498.0" y="523.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">e</text>')
print(f'<text x="500.0" y="525.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">L</text>')
print(f'<text x="475.0" y="500.0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">LE</text>')
font_families = "'DejaVu Sans', 'DejaVu Serif', 'FreeSerif', 'Noto Sans Symbols', 'Noto Serif'"
print(f'<text x="500.0" y="500.0" font-family="{font_families}" font-size="40" font-weight="bold" text-anchor="middle" dominant-baseline="middle" fill="#000">&#x2720;</text>')
print(f'</g>')

#  NUMBERS OVER CIRCLES AND SUCH MULTI-CHARACTER SYMBOLS

# Z with tail: &#x2C8C;
# O with dot above: &#x116AB;
# O with dot below: &#x116B7;
# U+02DA ˚ COMBINING RING ABOVE
# U+0325 ◌̥ COMBINING RING BELOW
# G with Plus-sign above: &#x1AC8;
# g superscript: &#x1D4D6;
font_families = "'Brush Script MT', 'Lucida Handwriting', cursive"
font_size = 10 

angle = math.pi/2 + 0.118
x = 500 + ( radius21 + 7.3 ) * math.cos(angle)
y = 500 + ( radius21 + 7.3 ) * math.sin(angle)
text_rotation = 180
print(f'<g id="odd_text_combos" transform="translate({x},{y}) rotate({text_rotation})">')
print(f'  <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">30</text>')
print(f'  <text x="-1.3" y="9" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">\u00B0</text>')
print(f'</g>')

angle = math.pi/2 + 2 * math.pi / 7 - 0.15
x = 500 + ( radius21 + 8.0 ) * math.cos(angle)
y = 500 + ( radius21 + 8.0 ) * math.sin(angle)
text_rotation = 180 + 360/7
print(f'<g id="odd_text_combos" transform="translate({x},{y}) rotate({text_rotation})">')
print(f'  <text x="0.0" y="0" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">\u00B0</text>')
print(f'  <text x="-1.3" y="4" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">26</text>')
print(f'</g>')

angle = -0.009
x = 500 + ( radius21 + 11.7 ) * math.cos(angle)
y = 500 + ( radius21 + 11.7 ) * math.sin(angle)
text_rotation = 90 - 0.6 * 360/14
print(f'<g id="odd_text_combos" transform="translate({x},{y}) rotate({text_rotation})">')
print(f'  <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">30</text>')
print(f'  <text x="-1.3" y="9" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">\u00B0</text>')
print(f'</g>')

angle  = ( 2 * math.pi / 7 ) * ( 3.845 )
x = 500 + ( radius21 + 7.0 ) * math.cos(angle)
y = 500 + ( radius21 + 7.0 ) * math.sin(angle)
text_rotation = -3 * 360/14
print(f'<g id="odd_text_combos" transform="translate({x},{y}) rotate({text_rotation})">')
print(f'  <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">21</text>')
print(f'  <text x="0" y="4" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">\u2014</text>')
print(f'  <text x="-1.3" y="9" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">8\u0325</text>')
print(f'</g>')

angle  = ( 2 * math.pi / 7 ) * ( 4.961 )
x = 500 + ( radius21 + 11.2 ) * math.cos(angle)
y = 500 + ( radius21 + 11.2 ) * math.sin(angle)
text_rotation = -360/14
print(f'<g id="odd_text_combos" transform="translate({x},{y}) rotate({text_rotation})">')
print(f'  <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">21</text>')
print(f'  <text x="0" y="4" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">\u2014</text>')
print(f'  <text x="-1.3" y="9" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">8\u0325</text>')
print(f'</g>')

angle  = ( 2 * math.pi / 7 ) * ( 0.495 ) - math.pi/2
x = 500 + ( radius21 + 4 ) * math.cos(angle)
y = 500 + ( radius21 + 4 ) * math.sin(angle)
text_rotation = 360/14
print(f'<g id="odd_text_combos" transform="translate({x},{y}) rotate({text_rotation})">')
print(f'  <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">21</text>')
print(f'  <text x="0" y="4" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">\u2014</text>')
print(f'  <text x="-1.3" y="9" font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">8\u0325</text>')
print(f'</g>')

font_size = 12 
angle  = ( -1.153 * math.pi / 4 )
x = 500 + ( radius21 - 3.5 ) * math.cos(angle)
y = 500 + ( radius21 - 3.5 ) * math.sin(angle)
text_rotation = 360/14
print(f'<g id="odd_text_combos" transform="translate({x},{y}) rotate({text_rotation})">')
print(f'  <text font-family="{font_families}" font-size="{font_size}" font-weight="normal" text-anchor="middle" dominant-baseline="middle" fill="#000">\u00B0</text>')
print(f'</g>')

polar_graph_overlay()

print(f'</svg>')

