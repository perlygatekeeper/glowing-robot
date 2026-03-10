from maze.maze import create_maze, svg_render

# Generate a maze
maze = create_maze(width=15, height=33, density=0.7, add_a_loop=False)

# Define rendering options
options = {
    "filename": "maze.svg",   # Output file name
    "width": 8.5,             # Width of the output image (e.g., 8.5 inches for letter-size paper)
    "height": 11,             # Height of the output image (e.g., 11 inches for letter-size paper)
    "resolution": 600,        # Resolution in DPI (dots per inch)
    "use_A4": True,           # Use A4 paper
    "draw_with_curves":False, #
    "solution":False          #

}

# Save the maze as an SVG file
svg_render(maze, options)
