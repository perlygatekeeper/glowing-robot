import svgwrite

def create_figure_eight_segment(start_x, start_y, width=10, height=25, horizontal_shift=5):
    """
    Creates a single figure-eight pattern using bezier curves.
    Returns the SVG path data and the ending coordinates.
    
    Args:
        start_x: Starting x coordinate
        start_y: Starting y coordinate (middle point)
        width: Width of the figure eight
        height: Height of each loop
        horizontal_shift: How far to the right the pattern shifts
    
    Returns:
        tuple: (path_data, end_x, end_y)
    """
    # Control points for the upper loop (going up and right)
    cp1_x = start_x + width * 0.5
    cp1_y = start_y - height * 0.7
    cp2_x = start_x + horizontal_shift - width * 0.5
    cp2_y = start_y - height * 0.7
    mid_x = start_x + horizontal_shift * 0.5
    mid_y = start_y
    
    # Control points for the lower loop (going down and right)
    cp3_x = start_x + horizontal_shift * 0.5 + width * 0.5
    cp3_y = start_y + height * 0.7
    cp4_x = start_x + horizontal_shift + width * 0.5
    cp4_y = start_y + height * 0.7
    end_x = start_x + horizontal_shift
    end_y = start_y
    
    # Create the path: start -> upper loop -> middle -> lower loop -> end
    path = f'M {start_x},{start_y} '
    path += f'C {cp1_x},{cp1_y} {cp2_x},{cp2_y} {mid_x},{mid_y} '
    path += f'C {cp3_x},{cp3_y} {cp4_x},{cp4_y} {end_x},{end_y}'
    
    return path, end_x, end_y


def create_repeating_figure_eight(filename='figure_eight_pattern.svg', 
                                   num_repeats=10, 
                                   start_x=50, 
                                   start_y=100,
                                   width=10,
                                   height=25,
                                   horizontal_shift=25,
                                   stroke_color='#8B7355',
                                   stroke_width=0.5):
    """
    Creates an SVG with a repeating figure-eight pattern.
    
    Args:
        filename: Output SVG filename
        num_repeats: Number of figure-eight repetitions
        start_x: Starting x coordinate
        start_y: Starting y coordinate (vertical center)
        width: Width of each figure eight
        height: Height of each loop
        horizontal_shift: Rightward shift per repetition
        stroke_color: Color of the pattern
        stroke_width: Width of the stroke
    """
    # Calculate canvas size
    canvas_width = start_x + (num_repeats * horizontal_shift) + 100
    canvas_height = start_y + height + 100
    
    dwg = svgwrite.Drawing(filename, size=(canvas_width, canvas_height))
    
    # Background
    dwg.add(dwg.rect(insert=(0, 0), size=(canvas_width, canvas_height), fill='white'))
    
    # Build the complete path by connecting all segments
    full_path = f'M {start_x},{start_y} '
    current_x = start_x
    current_y = start_y
    
    for i in range(num_repeats):
        # Control points for the upper loop (going up and right)
        cp1_x = current_x + width * 0.5
        cp1_y = current_y - height * 0.7
        cp2_x = current_x + horizontal_shift - width * 0.5
        cp2_y = current_y - height * 0.7
        mid_x = current_x + horizontal_shift * 0.5
        mid_y = current_y
        
        # Control points for the lower loop (going down and right)
        cp3_x = current_x + horizontal_shift * 0.5 + width * 0.5
        cp3_y = current_y + height * 0.7
        cp4_x = current_x + horizontal_shift - width * 0.5
        cp4_y = current_y + height * 0.7
        end_x = current_x + horizontal_shift
        end_y = current_y
        
        # Append the bezier curves
        full_path += f'C {cp1_x},{cp1_y} {cp2_x},{cp2_y} {mid_x},{mid_y} '
        full_path += f'C {cp3_x},{cp3_y} {cp4_x},{cp4_y} {end_x},{end_y} '
        
        current_x = end_x
        current_y = end_y
    
    # Add the complete path to the drawing
    dwg.add(dwg.path(d=full_path, 
                     stroke=stroke_color, 
                     fill='none', 
                     stroke_width=stroke_width,
                     stroke_linecap='round',
                     stroke_linejoin='round'))
    
    # Optional: Add dots at connection points for visualization
    x = start_x
    y = start_y
    for i in range(num_repeats + 1):
        dwg.add(dwg.circle(center=(x, y), r=3, fill=stroke_color, fill_opacity=0.5))
        x += horizontal_shift
    
    dwg.save()
    print(f"Figure-eight pattern saved to {filename}")
    print(f"Pattern: {num_repeats} repetitions, total width: {num_repeats * horizontal_shift}px")
    return dwg


if __name__ == '__main__':
    # Default pattern
    create_repeating_figure_eight()
    
    # Example: Tighter pattern
    create_repeating_figure_eight(
        filename='tight_figure_eight.svg',
        num_repeats=15,
        width=20,
        height=30,
        horizontal_shift=18,
        stroke_color='#2C5F8D',
        stroke_width=1.5
    )
    
    # Example: Wider, flowing pattern
    create_repeating_figure_eight(
        filename='flowing_figure_eight.svg',
        num_repeats=8,
        width=40,
        height=50,
        horizontal_shift=35,
        stroke_color='#D4AF37',
        stroke_width=3
    )
