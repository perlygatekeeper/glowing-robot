#!/usr/bin/env python3

import math

def generate_circles_with_spokes(center_x, center_y, radius1, radius2, num_spokes):

def generate_circle_points(center_x, center_y, radius1, radius2, num_points):
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
    angle_step = 2 * math.pi / num_points
    
    for i in range(num_points):
        # Start at top (angle = -pi/2) and go clockwise
        angle = -math.pi / 2 + i * angle_step
        x1 = center_x + radius1 * math.cos(angle)
        y1 = center_y + radius1 * math.sin(angle)
        x2 = center_x + radius2 * math.cos(angle)
        y2 = center_y + radius2 * math.sin(angle)
        points.append((x1, y1, x2, y2))
    
    return points

# Generate 2 circles, N with spokes from inner to outer circle
radius2 = 480  # Adjust this as needed
radius1 = 460  # Adjust this as needed
points = generate_circle_points(500, 500, radius1, radius2, 40)

# print the cicles 
# Print the spoke paths
for i, (x1, y1, x2, y2) in enumerate(points):
    print(f"M {x1:.2f} {y1:.2f} L {x2:.2f} {y2:.2f}")

def generate_heptagon_points(center_x, center_y, radius, num_points):
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
    angle_step = 2 * math.pi / num_points
    
    angle_offset = math.pi / num_points
    for i in range(num_points):
        # Start at top (angle = -pi/2) and go clockwise
        # angle = -math.pi / 2 + i * angle_step + angle_offset
        angle = -math.pi / 2 + i * angle_step
        x = center_x + radius * math.cos(angle)
        y = center_y + radius * math.sin(angle)
        points.append((x, y))
    
    return points

# Generate 7 points around a circle
# radius1 = 460  # Adjust this as needed
# radius2 = 440  # Adjust this as needed
radius1 = 440  # Adjust this as needed
radius2 = 394  # Adjust this as needed
# radius1 = 275  # Adjust this as needed
# radius2 = 255  # Adjust this as needed

# Print the inner heptagon
print('<path d="')
points = generate_heptagon_points(500, 500, radius1, 7)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"{L} {x:6.2f} {y:6.2f}  ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3"/>')


# Print the outer heptagon
print('<path d="')
points = generate_circle_points(500, 500, radius2, 7)
L = "M"
for i, (x, y) in enumerate(points):
    print(f"{L} {x:6.2f} {y:6.2f} ")
    L = "L"
print("Z")
print('" fill="none" stroke="#000" stroke-width="3"/>')

