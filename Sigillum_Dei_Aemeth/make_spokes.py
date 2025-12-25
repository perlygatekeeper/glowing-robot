#!/usr/bin/env python3

import math

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

# Generate 40 points around a circle
radius1 = 460  # Adjust this as needed
radius2 = 480  # Adjust this as needed
points = generate_circle_points(500, 500, radius1, radius2, 40)

# Print the points
for i, (x1, y1, x2, y2) in enumerate(points):
    print(f"M {x1:.2f} {y1:.2f} L {x2:.2f} {y2:.2f}")

# Optional: Print as SVG circle elements
# print("\n--- SVG Circle Elements ---")
# for x, y in points:
#     print(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="15"/>')
