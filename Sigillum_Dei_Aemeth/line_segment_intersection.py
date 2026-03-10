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


# Example usage
print("--- Example 1: Perpendicular lines ---")
# Line 1: horizontal from (0, 100) to (200, 100)
# Line 2: vertical from (100, 0) to (100, 200)
result = line_intersection((0, 100), (200, 100), (100, 0), (100, 200))
if result:
    print(f"Intersection at: ({result[0]:.2f}, {result[1]:.2f})")
else:
    print("Lines are parallel")

print("\n--- Example 2: Diagonal lines ---")
# Line 1: from (0, 0) to (100, 100)
# Line 2: from (0, 100) to (100, 0)
result = line_intersection((0, 0), (100, 100), (0, 100), (100, 0))
if result:
    print(f"Intersection at: ({result[0]:.2f}, {result[1]:.2f})")
else:
    print("Lines are parallel")

print("\n--- Example 3: Parallel lines (no intersection) ---")
# Line 1: from (0, 0) to (100, 0)
# Line 2: from (0, 50) to (100, 50)
result = line_intersection((0, 0), (100, 0), (0, 50), (100, 50))
if result:
    print(f"Intersection at: ({result[0]:.2f}, {result[1]:.2f})")
else:
    print("Lines are parallel")

print("\n--- Example 4: For Sigillum Dei ---")
# Heptagon edge
edge_start = (300, 200)
edge_end = (600, 300)
# Radial spoke from center
spoke_start = (500, 500)
spoke_end = (500, 100)

result = line_intersection(edge_start, edge_end, spoke_start, spoke_end)
if result:
    print(f"Intersection at: ({result[0]:.2f}, {result[1]:.2f})")

print("\n--- Example 5: Using with point lists ---")
heptagon_vertices = [(500, 100), (700, 250), (750, 500), (600, 700)]
center = (500, 500)

# Find where line from center to first vertex intersects with an edge
result = line_intersection(center, heptagon_vertices[0], 
                          heptagon_vertices[1], heptagon_vertices[2])
if result:
    print(f"Intersection at: ({result[0]:.2f}, {result[1]:.2f})")
